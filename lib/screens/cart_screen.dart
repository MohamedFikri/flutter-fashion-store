import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../widgets/payment_details_form.dart';
import 'checkout_screen.dart';

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
            child:
                const Text('Clear', style: TextStyle(color: AppColors.error)),
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
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        _btn(Icons.add, () => cart.updateQuantity(item.id, item.quantity + 1)),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            valueColor: cart.shippingFee == 0 ? AppColors.success : null,
          ),
          if (cart.subtotal < 100)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Free shipping on orders over \$100',
                style: TextStyle(fontSize: 11, color: AppColors.grey),
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
            color:
                valueColor ?? (isBold ? AppColors.primary : AppColors.darkGrey),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  void _showPaymentMethodDialog(BuildContext context, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PaymentMethodBottomSheet(cart: cart),
    );
  }
}

class _PaymentMethodBottomSheet extends StatefulWidget {
  final CartProvider cart;

  const _PaymentMethodBottomSheet({required this.cart});

  @override
  State<_PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<_PaymentMethodBottomSheet> {
  PaymentMethodModel? _selectedPaymentMethod;
  PaymentDetails? _paymentDetails;
  bool _showPaymentDetailsForm = false;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = PaymentService.getMethodById('cod');
  }

  @override
  Widget build(BuildContext context) {
    if (_showPaymentDetailsForm && _selectedPaymentMethod != null) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.white,
          ),
          child: PaymentDetailsForm(
            paymentMethod: _selectedPaymentMethod!,
            onSubmit: _onPaymentDetailsSubmitted,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Order Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal',
                        style: TextStyle(color: AppColors.grey)),
                    Text('\$${widget.cart.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shipping',
                        style: TextStyle(color: AppColors.grey)),
                    Text(
                      widget.cart.shippingFee == 0
                          ? 'FREE'
                          : '\$${widget.cart.shippingFee.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '\$${widget.cart.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment Methods
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: PaymentService.getAvailableMethods().length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final method = PaymentService.getAvailableMethods()[index];
                final isSelected = _selectedPaymentMethod?.id == method.id;

                return GestureDetector(
                  onTap: () => setState(() => _selectedPaymentMethod = method),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightGrey,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          method.icon,
                          color:
                              isSelected ? AppColors.primary : AppColors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.darkGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                ),
                              ),
                              if (method.processingFee != null &&
                                  method.processingFee! > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Processing fee: ${method.processingFee}%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Continue Button
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _selectedPaymentMethod != null ? _handleContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _handleContinue() {
    if (_selectedPaymentMethod == null) return;

    // Check if payment method requires additional details
    if (_requiresPaymentDetails(_selectedPaymentMethod!) &&
        _paymentDetails == null) {
      setState(() => _showPaymentDetailsForm = true);
      return;
    }

    // Proceed to checkout
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          preselectedPaymentMethod: _selectedPaymentMethod!,
          preselectedPaymentDetails: _paymentDetails,
        ),
      ),
    );
  }

  bool _requiresPaymentDetails(PaymentMethodModel method) {
    return method.type != PaymentType.cashOnDelivery;
  }

  void _onPaymentDetailsSubmitted(PaymentDetails details) {
    setState(() {
      _paymentDetails = details;
      _showPaymentDetailsForm = false;
    });

    // Proceed to checkout
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          preselectedPaymentMethod: _selectedPaymentMethod!,
          preselectedPaymentDetails: _paymentDetails,
        ),
      ),
    );
  }
}
