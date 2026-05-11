import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    // Listen to Firebase auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _loadUserDataFromFirestore(firebaseUser);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserDataFromFirestore(User firebaseUser) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _user = UserModel(
          uid: firebaseUser.uid,
          email: userData['email'] ?? firebaseUser.email ?? '',
          name: userData['name'] ?? firebaseUser.displayName ?? 'User',
          phone: userData['phone'] ?? firebaseUser.phoneNumber ?? '',
          address: userData['address'] ?? 'Address not set',
          profileImage: userData['profileImage'] ?? '',
        );
      } else {
        // Create user data if it doesn't exist
        _user = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          phone: firebaseUser.phoneNumber ?? '',
          address: 'Address not set',
          profileImage: firebaseUser.photoURL ?? '',
        );
        await _saveUserToFirestore(firebaseUser);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'User',
        phone: firebaseUser.phoneNumber ?? '',
        address: 'Address not set',
        profileImage: firebaseUser.photoURL ?? '',
      );
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // User data will be loaded by the auth state listener
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Save user data to Firestore
      await _saveUserToFirestore(userCredential.user!, name: name, phone: phone);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Save Google user data to Firestore
      await _saveUserToFirestore(userCredential.user!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    await FirebaseAuth.instance.signOut();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_user == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Update display name in Firebase Auth if name changed
        if (name != null && name != _user!.name) {
          await currentUser.updateDisplayName(name);
        }
        
        // Update user data in Firestore
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid);
            
        await userDoc.update({
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Update local user data
        _user = UserModel(
          uid: _user!.uid,
          email: _user!.email,
          name: name ?? _user!.name,
          phone: phone ?? _user!.phone,
          address: address ?? _user!.address,
          profileImage: _user!.profileImage,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveUserToFirestore(
    User user, {
    String? name,
    String? phone,
  }) async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
          
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'name': name ?? user.displayName ?? 'User',
        'phone': phone ?? user.phoneNumber ?? '',
        'address': 'Address not set',
        'profileImage': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found for this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Try again later.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return 'An error occurred: ${error.message}';
      }
    }
    return 'An unknown error occurred.';
  }
}

// ─── Cart Provider ─────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);
  double get subtotal => _items.fold(0, (total, item) => total + item.totalPrice);
  double get shippingFee => itemCount > 0 ? 5.99 : 0.0;
  double get total => subtotal + shippingFee;

  void addItem(ProductModel product, {int quantity = 1, String? size, String? color}) {
    final existingItem = _items.indexWhere(
      (item) => item.product.id == product.id && 
                item.selectedSize == (size ?? '') && 
                item.selectedColor == (color ?? ''),
    );

    if (existingItem != -1) {
      _items[existingItem].quantity += quantity;
    } else {
      _items.add(CartItemModel(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: quantity,
        selectedSize: size ?? '',
        selectedColor: color ?? '',
      ));
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
    } else {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> checkout({
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String postalCode,
    required String country,
  }) async {
    try {
      // Simulate checkout process
      await Future.delayed(const Duration(seconds: 2));
      
      // Clear cart after successful checkout
      clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}
