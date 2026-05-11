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
              'https://picsum.photos/seed/kurti1/400/300.jpg',
              'https://picsum.photos/seed/kurti2/400/300.jpg',
              'https://picsum.photos/seed/kurti3/400/300.jpg',
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
              'https://picsum.photos/seed/shirt1/400/300.jpg',
              'https://picsum.photos/seed/shirt2/400/300.jpg',
            ],
            sizes: ['S', 'M', 'L', 'XL', 'XXL'],
            colors: ['White', 'Blue', 'Black'],
            rating: 4.2,
            reviewCount: 89,
            isFeatured: false,
            stock: 15,
          ),
        ];

        for (final product in sampleProducts) {
          await saveProduct(product);
        }
      }
    } catch (e) {
      debugPrint('Error initializing products: $e');
    }
  }
}
