import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  final List<PaymentModel> _payments = [];
  List<PaymentMethodModel> _savedMethods = [];
  bool _isProcessing = false;
  String? _errorMessage;

  List<PaymentModel> get payments => _payments;
  List<PaymentMethodModel> get savedMethods => _savedMethods;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  PaymentProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _savedMethods = [
      PaymentMethodModel(
        id: 'pm1',
        type: 'Visa',
        last4: '4242',
        expiryDate: '12/25',
        holderName: 'John Doe',
        isDefault: true,
      ),
      PaymentMethodModel(
        id: 'pm2',
        type: 'Mastercard',
        last4: '5555',
        expiryDate: '08/24',
        holderName: 'John Doe',
        isDefault: false,
      ),
    ];
  }

  Future<PaymentModel?> processPayment({
    required String orderId,
    required double amount,
    required String method,
    required Map<String, dynamic> paymentDetails,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Simulate successful payment
    if (amount > 0) {
      final payment = PaymentModel(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        userId: 'currentUser',
        amount: amount,
        method: method,
        status: 'completed',
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        details: paymentDetails,
      );

      _payments.insert(0, payment);
      _isProcessing = false;
      notifyListeners();
      return payment;
    } else {
      _errorMessage = 'Payment failed. Please try again.';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> savePaymentMethod(PaymentMethodModel method) async {
    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _savedMethods.add(method);
    _isProcessing = false;
    notifyListeners();
    return true;
  }

  Future<bool> deletePaymentMethod(String methodId) async {
    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _savedMethods.removeWhere((m) => m.id == methodId);
    _isProcessing = false;
    notifyListeners();
    return true;
  }

  Future<bool> setDefaultPaymentMethod(String methodId) async {
    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _savedMethods = _savedMethods
        .map((method) => PaymentMethodModel(
              id: method.id,
              type: method.type,
              last4: method.last4,
              expiryDate: method.expiryDate,
              holderName: method.holderName,
              isDefault: method.id == methodId,
            ))
        .toList();

    _isProcessing = false;
    notifyListeners();
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
