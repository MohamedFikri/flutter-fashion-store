import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../widgets/payment_details_form.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final PaymentMethodModel? preselectedPaymentMethod;
  final PaymentDetails? preselectedPaymentDetails;

  const CheckoutScreen({
    super.key,
    this.preselectedPaymentMethod,
    this.preselectedPaymentDetails,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'Sri Lanka');
  bool _isLoading = false;
  int _step = 0; // 0 = delivery, 1 = payment, 2 = review
  PaymentMethodModel? _selectedPaymentMethod;
  PaymentDetails? _paymentDetails;
  bool _showPaymentDetailsForm = false;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod =
        widget.preselectedPaymentMethod ?? PaymentService.getMethodById('cod');
    _paymentDetails = widget.preselectedPaymentDetails;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _step = 0);
      return;
    }

    // Check if payment method requires additional details
    if (_selectedPaymentMethod != null &&
        _requiresPaymentDetails(_selectedPaymentMethod!) &&
        _paymentDetails == null) {
      setState(() => _showPaymentDetailsForm = true);
      return;
    }

    setState(() => _isLoading = true);
    final cart = context.read<CartProvider>();

    try {
      // Process payment if needed
      if (_paymentDetails != null &&
          _selectedPaymentMethod!.type != PaymentType.cashOnDelivery) {
        final total = cart.total;
        final paymentSuccess =
            await PaymentService.processPayment(_paymentDetails!, total);

        if (!paymentSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment failed. Please try again.'),
                backgroundColor: AppColors.error,
              ),
            );
            setState(() => _isLoading = false);
          }
          return;
        }
      }

      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final success = await cart.checkout(
        userId: auth.user?.uid ?? '',
        fullName: _nameCtrl.text,
        phone: _phoneCtrl.text,
        address: _addressCtrl.text,
        city: _cityCtrl.text,
        postalCode: _postalCtrl.text,
        country: _countryCtrl.text,
        email: auth.user?.email,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) =>
                  const OrderSuccessScreen(orderId: 'mock_order_id')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  bool _requiresPaymentDetails(PaymentMethodModel method) {
    return method.type != PaymentType.cashOnDelivery;
  }

  void _onPaymentMethodSelected(PaymentMethodModel method) {
    setState(() {
      _selectedPaymentMethod = method;
      // Reset payment details when method changes
      _paymentDetails = null;
      _showPaymentDetailsForm = false;
    });
  }

  void _onPaymentDetailsSubmitted(PaymentDetails details) {
    setState(() {
      _paymentDetails = details;
      _showPaymentDetailsForm = false;
      // Continue to review step
      _step = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Step Indicator
            _StepIndicator(current: _step),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0
                      ? _DeliveryForm(
                          key: const ValueKey(0),
                          nameCtrl: _nameCtrl,
                          phoneCtrl: _phoneCtrl,
                          addressCtrl: _addressCtrl,
                          cityCtrl: _cityCtrl,
                          postalCtrl: _postalCtrl,
                          countryCtrl: _countryCtrl,
                        )
                      : _step == 1
                          ? _PaymentForm(
                              key: const ValueKey(1),
                              selected: _selectedPaymentMethod,
                              onSelect: _onPaymentMethodSelected,
                            )
                          : _ReviewOrder(
                              key: const ValueKey(2),
                              cart: cart,
                              delivery: _nameCtrl.text,
                              address:
                                  '${_addressCtrl.text}, ${_cityCtrl.text}',
                              payment: _selectedPaymentMethod?.title ??
                                  'Cash on Delivery',
                            ),
                ),
              ),
            ),

            // Bottom Nav
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              color: AppColors.white,
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: AppButton(
                        text: 'Back',
                        isOutlined: true,
                        onPressed: () => setState(() => _step--),
                        width: null,
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: _step == 2 ? 'Place Order' : 'Continue',
                      isLoading: _isLoading,
                      onPressed: () {
                        if (_step < 2) {
                          setState(() => _step++);
                        } else {
                          _placeOrder();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Payment Details Modal
            if (_showPaymentDetailsForm && _selectedPaymentMethod != null)
              PaymentDetailsForm(
                paymentMethod: _selectedPaymentMethod!,
                onSubmit: _onPaymentDetailsSubmitted,
              ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    final steps = ['Delivery', 'Payment', 'Review'];
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color:
                    i ~/ 2 < current ? AppColors.primary : AppColors.lightGrey,
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < current;
          final active = idx == current;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      done || active ? AppColors.primary : AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: active ? Colors.white : AppColors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[idx],
                style: TextStyle(
                  fontSize: 11,
                  color: active ? AppColors.primary : AppColors.grey,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DeliveryForm extends StatelessWidget {
  final TextEditingController nameCtrl,
      phoneCtrl,
      addressCtrl,
      cityCtrl,
      postalCtrl,
      countryCtrl;

  const _DeliveryForm({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.postalCtrl,
    required this.countryCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Delivery Details', style: AppTextStyles.heading2),
        const SizedBox(height: 20),
        AppTextField(
            hint: 'Full Name',
            controller: nameCtrl,
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.grey),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null),
        const SizedBox(height: 14),
        AppTextField(
            hint: 'Phone Number',
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.grey),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null),
        const SizedBox(height: 14),
        AppTextField(
            hint: 'Street Address',
            controller: addressCtrl,
            prefixIcon:
                const Icon(Icons.location_on_outlined, color: AppColors.grey),
            maxLines: 2,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                  hint: 'City',
                  controller: cityCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                  hint: 'Postal Code',
                  controller: postalCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppTextField(
            hint: 'Country',
            controller: countryCtrl,
            prefixIcon: const Icon(Icons.flag_outlined, color: AppColors.grey),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      ],
    );
  }
}

class _PaymentForm extends StatelessWidget {
  final PaymentMethodModel? selected;
  final ValueChanged<PaymentMethodModel> onSelect;

  const _PaymentForm(
      {super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = PaymentService.getAvailableMethods();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: AppTextStyles.heading2),
        const SizedBox(height: 20),
        ...options.map((method) {
          final isSelected = selected?.id == method.id;
          return GestureDetector(
            onTap: () => onSelect(method),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : AppColors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.lightGrey,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(method.icon,
                      color: isSelected ? AppColors.primary : AppColors.grey),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(method.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.darkGrey,
                            )),
                        Text(method.description,
                            style: AppTextStyles.bodySmall),
                        if (method.processingFee != null &&
                            method.processingFee! > 0)
                          Text(
                            'Processing fee: ${method.processingFee}%',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ReviewOrder extends StatelessWidget {
  final CartProvider cart;
  final String delivery;
  final String address;
  final String payment;

  const _ReviewOrder({
    super.key,
    required this.cart,
    required this.delivery,
    required this.address,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Order', style: AppTextStyles.heading2),
        const SizedBox(height: 20),
        _InfoCard(
          title: 'Delivery To',
          children: [
            Text(delivery, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(address, style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Payment',
          children: [
            Text(payment, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Items (${cart.itemCount})',
          children: cart.items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.product.name} × ${item.quantity}',
                            style: const TextStyle(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _row('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _row(
                  'Shipping',
                  cart.shippingFee == 0
                      ? 'FREE'
                      : '\$${cart.shippingFee.toStringAsFixed(2)}'),
              const Divider(height: 20),
              _row('Total', '\$${cart.total.toStringAsFixed(2)}', bold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: bold ? AppColors.primary : AppColors.grey,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: bold ? AppColors.primary : AppColors.darkGrey,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  fontSize: bold ? 16 : 14)),
        ],
      );
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
