import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../utils/app_theme.dart';

class PaymentDetailsForm extends StatefulWidget {
  final PaymentMethodModel paymentMethod;
  final Function(PaymentDetails) onSubmit;

  const PaymentDetailsForm({
    super.key,
    required this.paymentMethod,
    required this.onSubmit,
  });

  @override
  State<PaymentDetailsForm> createState() => _PaymentDetailsFormState();
}

class _PaymentDetailsFormState extends State<PaymentDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _paypalEmailCtrl = TextEditingController();
  final _bankAccountCtrl = TextEditingController();
  final _bankRoutingCtrl = TextEditingController();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _paypalEmailCtrl.dispose();
    _bankAccountCtrl.dispose();
    _bankRoutingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 20),
            _buildPaymentForm(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    switch (widget.paymentMethod.type) {
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        return _buildCardForm();
      case PaymentType.paypal:
        return _buildPayPalForm();
      case PaymentType.bankTransfer:
        return _buildBankTransferForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        PaymentTextField(
          hint: 'Card Number',
          controller: _cardNumberCtrl,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.credit_card,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 16) return 'Invalid card number';
            return null;
          },
        ),
        const SizedBox(height: 14),
        PaymentTextField(
          hint: 'Cardholder Name',
          controller: _cardHolderCtrl,
          prefixIcon: Icons.person,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: PaymentTextField(
                hint: 'MM/YY',
                controller: _expiryCtrl,
                keyboardType: TextInputType.datetime,
                prefixIcon: Icons.calendar_today,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) {
                    return 'Invalid format (MM/YY)';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PaymentTextField(
                hint: 'CVV',
                controller: _cvvCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.lock,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 3) return 'Invalid CVV';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayPalForm() {
    return PaymentTextField(
      hint: 'PayPal Email',
      controller: _paypalEmailCtrl,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (!v.contains('@') || !v.contains('.')) {
          return 'Invalid email address';
        }
        return null;
      },
    );
  }

  Widget _buildBankTransferForm() {
    return Column(
      children: [
        PaymentTextField(
          hint: 'Account Number',
          controller: _bankAccountCtrl,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.account_balance,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 8) return 'Invalid account number';
            return null;
          },
        ),
        const SizedBox(height: 14),
        PaymentTextField(
          hint: 'Routing Number',
          controller: _bankRoutingCtrl,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.swap_horiz,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 6) return 'Invalid routing number';
            return null;
          },
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final paymentDetails = PaymentDetails(
        method: widget.paymentMethod,
        cardNumber: _cardNumberCtrl.text.isNotEmpty ? _cardNumberCtrl.text : null,
        cardHolderName: _cardHolderCtrl.text.isNotEmpty ? _cardHolderCtrl.text : null,
        expiryDate: _expiryCtrl.text.isNotEmpty ? _expiryCtrl.text : null,
        cvv: _cvvCtrl.text.isNotEmpty ? _cvvCtrl.text : null,
        paypalEmail: _paypalEmailCtrl.text.isNotEmpty ? _paypalEmailCtrl.text : null,
        bankAccountNumber: _bankAccountCtrl.text.isNotEmpty ? _bankAccountCtrl.text : null,
        bankRoutingNumber: _bankRoutingCtrl.text.isNotEmpty ? _bankRoutingCtrl.text : null,
      );
      widget.onSubmit(paymentDetails);
    }
  }
}

// Payment-specific text field widget to avoid circular imports
class PaymentTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool obscureText;

  const PaymentTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.maxLines,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
      validator: validator,
    );
  }
}
