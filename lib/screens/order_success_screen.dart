// ─── order_success_screen.dart ────────────────────────────────
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';
import 'main_nav_screen.dart';
import 'orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 60),
                ),
                const SizedBox(height: 32),
                const Text('Order Placed!', style: AppTextStyles.heading1),
                const SizedBox(height: 12),
                const Text(
                  'Your order has been placed successfully.\nWe\'ll notify you when it ships.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Order ID: ${orderId.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AppButton(
                  text: 'View My Orders',
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OrdersScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Continue Shopping',
                  isOutlined: true,
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MainNavScreen()),
                    (r) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
