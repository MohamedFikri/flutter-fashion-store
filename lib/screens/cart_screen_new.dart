import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: const Text('Clear',
                  style: TextStyle(color: AppColors.secondary)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _emptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _CartItemCard(item: cart.items[i], cart: cart),
                  ),
                ),
                _OrderSummary(cart: cart),
              ],
            ),
    );
  }

  Widget _emptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 80, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          const Text('Add some items to get started',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          AppButton(
            text: 'Continue Shopping',
            onPressed: () => Navigator.pop(context),
            width: 200,
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            child: const Text('Clear',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic item;
  final CartProvider cart;

  const _CartItemCard({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
            child: SizedBox(
              width: 100,
              height: 110,
              child: item.product.images.isNotEmpty
                  ? (item.product.images[0].startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: item.product.images[0],
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          item.product.images[0],
                          fit: BoxFit.cover,
                        ))
                  : Container(color: AppColors.lightGrey),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => cart.removeItem(item.id),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.selectedSize} · ${item.selectedColor}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      _QuantityRow(item: item, cart: cart),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  final dynamic item;
  final CartProvider cart;

  const _QuantityRow({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _btn(Icons.remove,
            () => cart.updateQuantity(item.id, item.quantity - 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '${item.quantity}',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        _btn(Icons.add,
            () => cart.updateQuantity(item.id, item.quantity + 1)),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: AppColors.primary),
        ),
      );
}

class _OrderSummary extends StatelessWidget {
  final CartProvider cart;

  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        children: [
          _row('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _row(
            'Shipping',
            cart.shippingFee == 0
                ? 'FREE'
                : '\$${cart.shippingFee.toStringAsFixed(2)}',
            valueColor:
                cart.shippingFee == 0 ? AppColors.success : null,
          ),
          if (cart.subtotal < 100)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Free shipping on orders over \$100',
                style: TextStyle(
                    fontSize: 11, color: AppColors.grey),
              ),
            ),
          const Divider(height: 24),
          _row(
            'Total',
            '\$${cart.total.toStringAsFixed(2)}',
            isBold: true,
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Proceed to Checkout',
            onPressed: () {
              _showPaymentMethodDialog(context, cart);
            },
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppColors.primary : AppColors.grey,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ??
                (isBold ? AppColors.primary : AppColors.darkGrey),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  void _showPaymentMethodDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _paymentOption(
              icon: Icons.credit_card,
              title: 'Credit/Debit Card',
              subtitle: 'Visa, Mastercard, Amex',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentScreen()),
                );
              },
            ),
            _paymentOption(
              icon: Icons.account_balance_wallet,
              title: 'Digital Wallet',
              subtitle: 'PayPal, Apple Pay, Google Pay',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Digital wallet coming soon!'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
            ),
            _paymentOption(
              icon: Icons.money,
              title: 'Cash on Delivery',
              subtitle: 'Pay when you receive your order',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cash on delivery selected!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
