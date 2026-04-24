import 'package:flutter/material.dart';

// Payment Method Model
enum PaymentType {
  cashOnDelivery,
  creditCard,
  debitCard,
  paypal,
  stripe,
  googlePay,
  applePay,
  bankTransfer,
}

class PaymentMethodModel {
  final String id;
  final PaymentType type;
  final String title;
  final String description;
  final IconData icon;
  final bool isEnabled;
  final List<String> supportedCards; // For card payments
  final double? processingFee; // Optional processing fee

  PaymentMethodModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.isEnabled = true,
    this.supportedCards = const [],
    this.processingFee,
  });

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map['id'] ?? '',
      type: PaymentType.values.firstWhere(
        (e) => e.toString() == 'PaymentType.${map['type']}',
        orElse: () => PaymentType.cashOnDelivery,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: _getIconFromString(map['icon'] ?? 'Icons.payment'),
      isEnabled: map['isEnabled'] ?? true,
      supportedCards: List<String>.from(map['supportedCards'] ?? []),
      processingFee: map['processingFee']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.toString().split('.').last,
        'title': title,
        'description': description,
        'icon': icon.toString(),
        'isEnabled': isEnabled,
        'supportedCards': supportedCards,
        'processingFee': processingFee,
      };

  static IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'Icons.money':
        return Icons.money;
      case 'Icons.credit_card':
        return Icons.credit_card;
      case 'Icons.account_balance':
        return Icons.account_balance;
      case 'Icons.payment':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }
}

class PaymentDetails {
  final PaymentMethodModel method;
  final String? cardNumber;
  final String? cardHolderName;
  final String? expiryDate;
  final String? cvv;
  final String? paypalEmail;
  final String? bankAccountNumber;
  final String? bankRoutingNumber;

  PaymentDetails({
    required this.method,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.cvv,
    this.paypalEmail,
    this.bankAccountNumber,
    this.bankRoutingNumber,
  });

  Map<String, dynamic> toMap() => {
        'method': method.toMap(),
        'cardNumber': cardNumber,
        'cardHolderName': cardHolderName,
        'expiryDate': expiryDate,
        'cvv': cvv,
        'paypalEmail': paypalEmail,
        'bankAccountNumber': bankAccountNumber,
        'bankRoutingNumber': bankRoutingNumber,
      };
}
