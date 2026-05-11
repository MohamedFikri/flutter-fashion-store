import 'dart:async';
import '../models/models.dart';

class OrderService {
  // Mock data for demo purposes
  static final List<OrderModel> _mockOrders = [
    OrderModel(
      id: 'order_001',
      userId: 'demo_user_123',
      items: [
        OrderItemModel(
          productId: '1',
          productName: 'Summer Dress',
          productImage:
              'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400',
          price: 49.99,
          quantity: 2,
          selectedSize: 'M',
          selectedColor: 'Floral',
        ),
      ],
      subtotal: 99.98,
      shippingFee: 5.99,
      total: 105.97,
      status: 'delivered',
      deliveryDetails: DeliveryDetails(
        fullName: 'Demo User',
        phone: '+1234567890',
        address: '123 Fashion Street',
        city: 'Style City',
        postalCode: '12345',
        country: 'Fashionland',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    OrderModel(
      id: 'order_002',
      userId: 'demo_user_123',
      items: [
        OrderItemModel(
          productId: '2',
          productName: 'Men\'s Classic T-Shirt',
          productImage:
              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
          price: 29.99,
          quantity: 1,
          selectedSize: 'L',
          selectedColor: 'Black',
        ),
      ],
      subtotal: 29.99,
      shippingFee: 5.99,
      total: 35.98,
      status: 'processing',
      deliveryDetails: DeliveryDetails(
        fullName: 'Demo User',
        phone: '+1234567890',
        address: '123 Fashion Street',
        city: 'Style City',
        postalCode: '12345',
        country: 'Fashionland',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // ── Get User Orders ────────────────────────────────────────
  Stream<List<OrderModel>> getUserOrders(String userId) {
    // Simulate network delay and return mock data
    return Stream.value(
            _mockOrders.where((order) => order.userId == userId).toList())
        .asyncMap(
      (orders) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return orders;
      },
    );
  }

  // ── Create Order ───────────────────────────────────────────
  Future<String> createOrder({
    required String userId,
    required List<CartItemModel> items,
    required double total,
    String? deliveryAddress,
  }) async {
    // Simulate order creation
    await Future.delayed(const Duration(seconds: 1));

    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

    // In a real app, this would save to Firestore
    return orderId;
  }

  // ── Get Order Details ─────────────────────────────────────
  Future<OrderModel?> getOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockOrders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // ── Update Order Status ───────────────────────────────────
  Future<bool> updateOrderStatus(String orderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real app, this would update in Firestore
    return true;
  }
}
