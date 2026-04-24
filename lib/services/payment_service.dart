import 'package:flutter/material.dart';
import 'dart:async';
import '../models/payment_model.dart';

class PaymentService {
  static final List<PaymentMethodModel> _availableMethods = [
    PaymentMethodModel(
      id: 'cod',
      type: PaymentType.cashOnDelivery,
      title: 'Cash on Delivery',
      description: 'Pay when you receive your order',
      icon: Icons.money,
    ),
    PaymentMethodModel(
      id: 'credit_card',
      type: PaymentType.creditCard,
      title: 'Credit Card',
      description: 'Visa, Mastercard, Amex',
      icon: Icons.credit_card,
      supportedCards: ['Visa', 'Mastercard', 'American Express'],
      processingFee: 0.0,
    ),
    PaymentMethodModel(
      id: 'debit_card',
      type: PaymentType.debitCard,
      title: 'Debit Card',
      description: 'Visa, Mastercard Debit',
      icon: Icons.credit_card,
      supportedCards: ['Visa Debit', 'Mastercard Debit'],
      processingFee: 0.0,
    ),
    PaymentMethodModel(
      id: 'paypal',
      type: PaymentType.paypal,
      title: 'PayPal',
      description: 'Fast and secure payment',
      icon: Icons.account_balance_wallet,
      processingFee: 2.9,
    ),
    PaymentMethodModel(
      id: 'stripe',
      type: PaymentType.stripe,
      title: 'Stripe',
      description: 'Secure card processing',
      icon: Icons.payment,
      processingFee: 2.9,
    ),
    PaymentMethodModel(
      id: 'google_pay',
      type: PaymentType.googlePay,
      title: 'Google Pay',
      description: 'Pay with Google',
      icon: Icons.account_balance,
      processingFee: 0.0,
    ),
    PaymentMethodModel(
      id: 'bank_transfer',
      type: PaymentType.bankTransfer,
      title: 'Bank Transfer',
      description: 'Direct bank deposit',
      icon: Icons.account_balance,
      processingFee: 0.0,
    ),
  ];

  static List<PaymentMethodModel> getAvailableMethods() {
    return _availableMethods.where((method) => method.isEnabled).toList();
  }

  static PaymentMethodModel? getMethodById(String id) {
    try {
      return _availableMethods.firstWhere((method) => method.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> processPayment(PaymentDetails paymentDetails, double amount) async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock validation - in real app, integrate with payment gateway
    switch (paymentDetails.method.type) {
      case PaymentType.cashOnDelivery:
        return true; // Always successful for COD
        
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        return _validateCardDetails(paymentDetails);
        
      case PaymentType.paypal:
        return _validatePayPalDetails(paymentDetails);
        
      case PaymentType.stripe:
        return _validateStripeDetails(paymentDetails);
        
      case PaymentType.googlePay:
        return true; // Handled by Google Pay SDK
        
      case PaymentType.applePay:
        return true; // Handled by Apple Pay SDK
        
      case PaymentType.bankTransfer:
        return _validateBankDetails(paymentDetails);
    }
  }

  static bool _validateCardDetails(PaymentDetails details) {
    // Basic card validation (in real app, use payment gateway SDK)
    final cardNumber = details.cardNumber ?? '';
    final expiryDate = details.expiryDate ?? '';
    final cvv = details.cvv ?? '';
    
    return cardNumber.length >= 16 && 
           expiryDate.isNotEmpty && 
           cvv.length >= 3;
  }

  static bool _validatePayPalDetails(PaymentDetails details) {
    final email = details.paypalEmail ?? '';
    return email.contains('@') && email.contains('.');
  }

  static bool _validateStripeDetails(PaymentDetails details) {
    // Similar to card validation but using Stripe SDK
    return _validateCardDetails(details);
  }

  static bool _validateBankDetails(PaymentDetails details) {
    final accountNumber = details.bankAccountNumber ?? '';
    final routingNumber = details.bankRoutingNumber ?? '';
    
    return accountNumber.length >= 8 && routingNumber.length >= 6;
  }

  static double calculateProcessingFee(PaymentMethodModel method, double amount) {
    if (method.processingFee == null) return 0.0;
    
    // Calculate percentage-based fee
    return (amount * method.processingFee!) / 100;
  }

  static Future<String> generatePaymentReference() async {
    // Generate unique payment reference
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'PAY_$timestamp$random';
  }
}
