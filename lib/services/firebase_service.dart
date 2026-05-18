import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Products Collection
  static CollectionReference get productsCollection => _firestore.collection('products');
  
  // Orders Collection  
  static CollectionReference get ordersCollection => _firestore.collection('orders');
  
  // Users Collection
  static CollectionReference get usersCollection => _firestore.collection('users');

  // Stream for Products
  static Stream<List<ProductModel>> get productsStream =>
      productsCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });

  // Stream for Orders (filtered by userId)
  static Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream for single User
  static Stream<UserModel?> getUserStream(String uid) {
    return usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // Fallback Sample Products
  static List<ProductModel> get _sampleProducts => [
        ProductModel(
          id: '1',
          name: "Women's Kurti Set",
          description: 'Elegant three-piece kurti set suitable for campus events, family functions, and casual wear.',
          price: 6490.00,
          originalPrice: 7990.00,
          category: 'Women',
          images: [
            'assets/images/products/womens_kurti_set_1.jpg',
            'assets/images/products/womens_kurti_set_2.jpg',
          ],
          sizes: ['S', 'M', 'L', 'XL'],
          colors: ['Maroon', 'Navy', 'Cream'],
          rating: 4.5,
          reviewCount: 128,
          isFeatured: true,
          stock: 10,
        ),
        ProductModel(
          id: '2',
          name: "Men's Casual Shirt",
          description: 'Comfortable cotton shirt perfect for everyday wear.',
          price: 2490.00,
          originalPrice: 2990.00,
          category: 'Men',
          images: [
            'assets/images/products/mens_casual_shirt_1.jpg',
            'assets/images/products/mens_casual_shirt_2.jpg',
          ],
          sizes: ['S', 'M', 'L', 'XL', 'XXL'],
          colors: ['White', 'Blue', 'Black'],
          rating: 4.2,
          reviewCount: 89,
          isFeatured: false,
          stock: 15,
        ),
        ProductModel(
          id: '3',
          name: "Enjoy Hoodie",
          description: 'Stylish and comfortable hoodie with statement design.',
          price: 3990.00,
          originalPrice: 4990.00,
          category: 'Hoodies',
          images: [
            'assets/images/products/boys_hoodie_1.jpg',
            'assets/images/products/boys_hoodie_2.jpg',
          ],
          sizes: ['M', 'L', 'XL'],
          colors: ['Black', 'Red', 'Grey'],
          rating: 4.8,
          reviewCount: 256,
          isFeatured: true,
          stock: 20,
        ),
        ProductModel(
          id: '4',
          name: "Graphic T-Shirt",
          description: 'Premium cotton t-shirt with modern graphic prints.',
          price: 1990.00,
          originalPrice: 2490.00,
          category: 'Graphic',
          images: [
            'assets/images/products/mens_casual_shirt_3.jpg',
          ],
          sizes: ['S', 'M', 'L', 'XL'],
          colors: ['White', 'Black'],
          rating: 4.6,
          reviewCount: 142,
          isFeatured: true,
          stock: 30,
        ),
        ProductModel(
          id: '5',
          name: "Sports Shoes",
          description: 'Comfortable and stylish sports shoes for active lifestyle.',
          price: 3490.00,
          originalPrice: 4290.00,
          category: 'Shoes',
          images: [
            'assets/images/products/sports_shoes_1.jpg',
            'assets/images/products/sports_shoes_2.jpg',
          ],
          sizes: ['7', '8', '9', '10', '11'],
          colors: ['Black', 'White', 'Blue'],
          rating: 4.3,
          reviewCount: 95,
          isFeatured: true,
          stock: 25,
        ),
        ProductModel(
          id: '6',
          name: "Women's Handbag",
          description: 'Elegant handbag perfect for any occasion.',
          price: 2990.00,
          originalPrice: 3990.00,
          category: 'Accessories',
          images: [
            'assets/images/products/womens_handbag_1.jpg',
            'assets/images/products/womens_handbag_2.jpg',
          ],
          sizes: ['One Size'],
          colors: ['Black', 'Brown', 'Tan'],
          rating: 4.7,
          reviewCount: 178,
          isFeatured: false,
          stock: 18,
        ),
      ];

  // Seed products to Firestore
  static Future<void> _seedProductsToFirestore() async {
    try {
      debugPrint('Seeding products to Firestore...');
      for (final product in _sampleProducts) {
        await productsCollection.doc(product.id).set(product.toMap());
        debugPrint('Seeded product: ${product.name}');
      }
      debugPrint('Products seeded successfully!');
    } catch (e) {
      debugPrint('Error seeding products: $e');
    }
  }

  // Product Management
  static Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await productsCollection.get();
      if (snapshot.docs.isEmpty) {
        // Seed products to Firestore if empty
        await _seedProductsToFirestore();
        final newSnapshot = await productsCollection.get();
        return newSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ProductModel.fromMap(data, doc.id);
        }).toList();
      }
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return _sampleProducts; // Fallback to sample data
    }
  }

  static Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await productsCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      // Check in sample products
      return _sampleProducts.firstWhere((p) => p.id == productId);
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return _sampleProducts.firstWhere((p) => p.id == productId, orElse: () => _sampleProducts[0]);
    }
  }

  static Future<void> saveProduct(ProductModel product) async {
    try {
      await productsCollection.doc(product.id).set(product.toMap());
    } catch (e) {
      debugPrint('Error saving product: $e');
    }
  }

  static Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await productsCollection
          .where('category', isEqualTo: category)
          .get();
      if (snapshot.docs.isEmpty) {
        return _sampleProducts.where((p) => p.category == category).toList();
      }
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      return _sampleProducts.where((p) => p.category == category).toList();
    }
  }

  // Featured Products
  static Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await productsCollection
          .where('isFeatured', isEqualTo: true)
          .get();
      if (snapshot.docs.isEmpty) {
        return _sampleProducts.where((p) => p.isFeatured).toList();
      }
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching featured products: $e');
      return _sampleProducts.where((p) => p.isFeatured).toList();
    }
  }

  // Order Management
  static Future<void> saveOrder({
    required String userId,
    required List<CartItemModel> items,
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String postalCode,
    required String country,
    required double totalAmount,
    required String paymentMethod,
    String? userEmail,
  }) async {
    try {
      final orderData = {
        'userId': userId,
        'userEmail': userEmail ?? '',
        'items': items.map((item) => {
          'productId': item.product.id,
          'productName': item.product.name,
          'productImage': item.product.images.isNotEmpty ? item.product.images[0] : '',
          'quantity': item.quantity,
          'price': item.product.price,
          'selectedSize': item.selectedSize,
          'selectedColor': item.selectedColor,
          'total': item.product.price * item.quantity,
        }).toList(),
        'deliveryDetails': {
          'fullName': fullName,
          'phone': phone,
          'address': address,
          'city': city,
          'postalCode': postalCode,
          'country': country,
        },
        'subtotal': items.fold(0.0, (total, item) => total + (item.product.price * item.quantity)),
        'shippingFee': 0.0, // Default for now
        'total': totalAmount,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await ordersCollection.add(orderData);
      debugPrint('Order saved successfully with ID: ${docRef.id}');
    } catch (e) {
      debugPrint('Error saving order: $e');
      rethrow; // Re-throw to handle in UI
    }
  }

  static Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final snapshot = await ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
      
      return orders;
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
      return [];
    }
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  // User Management
  static Future<void> saveUser(UserModel user) async {
    try {
      await usersCollection.doc(user.uid).set({
        'uid': user.uid,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'profileImage': user.profileImage ?? '',
        'address': user.address ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('User saved successfully: ${user.email}');
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  static Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data, userId);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  // Initialize sample products in Firebase
  static Future<void> initializeProducts() async {
    try {
      final snapshot = await productsCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        await _seedProductsToFirestore();
      }
      await initializeOrders();
    } catch (e) {
      debugPrint('Error initializing products: $e');
    }
  }


  // Initialize sample orders in Firebase
  static Future<void> initializeOrders() async {
    try {
      final snapshot = await ordersCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        final sampleOrder = {
          'userId': 'sample_user_1',
          'items': [
            {
              'productId': '1',
              'productName': "Women's Kurti Set",
              'productImage': 'assets/images/products/womens_kurti_set_1.jpg',
              'quantity': 1,
              'price': 6490.0,
              'selectedSize': 'M',
              'selectedColor': 'Maroon',
            }
          ],
          'deliveryDetails': {
            'fullName': 'John Doe',
            'phone': '0123456789',
            'address': '123 Main St',
            'city': 'Colombo',
            'postalCode': '10100',
            'country': 'Sri Lanka',
          },
          'subtotal': 6490.0,
          'shippingFee': 0.0,
          'total': 6490.0,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await ordersCollection.add(sampleOrder);
      }
    } catch (e) {
      debugPrint('Error initializing orders: $e');
    }
  }
}
