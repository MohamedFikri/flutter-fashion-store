import 'package:flutter/foundation.dart';
import '../models/models.dart';

// ─── Auth Provider ────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    // Mock auto-login for demo
    _mockAutoLogin();
  }

  void _mockAutoLogin() {
    // Simulate checking for existing user session
    Future.delayed(const Duration(seconds: 1), () {
      // For demo, start with logged out state
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock login logic
    if (email.isNotEmpty && password.length >= 6) {
      _user = UserModel(
        uid: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: 'Demo User',
        phone: '+1234567890',
        address: '123 Fashion Street, Style City',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String password, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock registration logic
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6 && phone.isNotEmpty) {
      _user = UserModel(
        uid: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        phone: phone,
        address: '123 Fashion Street, Style City',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Please fill all fields correctly';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate logout delay
    await Future.delayed(const Duration(seconds: 1));
    
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_user == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    // Simulate update delay
    await Future.delayed(const Duration(seconds: 1));
    
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
}

// ─── Cart Provider ─────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get shippingFee => itemCount > 0 ? 5.99 : 0.0;
  double get total => subtotal + shippingFee;

  void addItem(ProductModel product, {int quantity = 1, String? size, String? color}) {
    final existingItem = _items.indexWhere(
      (item) => item.product.id == product.id && 
                item.selectedSize == size && 
                item.selectedColor == color,
    );

    if (existingItem != -1) {
      _items[existingItem] = CartItemModel(
        id: _items[existingItem].id,
        product: _items[existingItem].product,
        quantity: _items[existingItem].quantity + quantity,
        selectedSize: _items[existingItem].selectedSize,
        selectedColor: _items[existingItem].selectedColor,
      );
    } else {
      _items.add(CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        selectedSize: size ?? 'M',
        selectedColor: color ?? 'Black',
      ));
    }
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index] = CartItemModel(
        id: _items[index].id,
        product: _items[index].product,
        quantity: quantity,
        selectedSize: _items[index].selectedSize,
        selectedColor: _items[index].selectedColor,
      );
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> checkout() async {
    // Mock checkout process
    await Future.delayed(const Duration(seconds: 2));
    
    // Clear cart after successful checkout
    clear();
    return true;
  }
}
