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

  // Product Management
  static Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await productsCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  static Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await productsCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
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
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      return [];
    }
  }

  // Featured Products
  static Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await productsCollection
          .where('isFeatured', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching featured products: $e');
      return [];
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
  }) async {
    try {
      final orderData = {
        'userId': userId,
        'items': items.map((item) => item.toMap()).toList(),
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'postalCode': postalCode,
        'country': country,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await ordersCollection.add(orderData);
    } catch (e) {
      debugPrint('Error saving order: $e');
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

  // Initialize sample products in Firebase
  static Future<void> initializeProducts() async {
    try {
      final existingProducts = await getAllProducts();
      
      if (existingProducts.isEmpty) {
        // Add sample products to Firebase
        final sampleProducts = [
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
        ];

        for (final product in sampleProducts) {
          await saveProduct(product);
        }
      }
      
      // Also initialize sample orders if needed
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
              'name': "Women's Kurti Set",
              'quantity': 1,
              'price': 6490.0,
              'selectedSize': 'M',
              'selectedColor': 'Maroon',
            }
          ],
          'fullName': 'John Doe',
          'phone': '0123456789',
          'address': '123 Main St',
          'city': 'Colombo',
          'postalCode': '10100',
          'country': 'Sri Lanka',
          'totalAmount': 6490.0,
          'paymentMethod': 'Cash on Delivery',
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
