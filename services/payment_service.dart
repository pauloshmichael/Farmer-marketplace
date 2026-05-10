import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Payment methods
  static const List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'Cash on Delivery',
      'icon': Icons.money,
      'description': 'Pay when you receive the product',
      'requiresReceipt': false,
    },
    {
      'name': 'Bank Transfer',
      'icon': Icons.account_balance,
      'description': 'Transfer to bank account and upload receipt',
      'requiresReceipt': true,
    },
    {
      'name': 'Mobile Money',
      'icon': Icons.phone_android,
      'description': 'Pay via M-Pesa, Airtel Money, Telebirr',
      'requiresReceipt': true,
    },
  ];

  // Get bank details
  static Map<String, String> getBankDetails() {
    return {
      'bankName': 'Commercial Bank of Ethiopia',
      'accountName': 'Farmer Marketplace',
      'accountNumber': '1000123456789',
      'branch': 'Addis Ababa Main Branch',
      'swiftCode': 'CBETETAA',
    };
  }

  // Get mobile money details
  static Map<String, String> getMobileMoneyDetails() {
    return {
      'provider': 'Telebirr / M-Pesa',
      'number': '0912345678',
      'accountName': 'Farmer Marketplace',
    };
  }

  // Upload receipt image
  static Future<String> uploadReceiptImage(File image, String orderId) async {
    final fileName = 'receipts/$orderId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final reference = _storage.ref().child(fileName);
    await reference.putFile(image);
    return await reference.getDownloadURL();
  }

  // Save payment information
  static Future<void> savePaymentInfo({
    required String orderId,
    required double amount,
    required String paymentMethod,
    required String referenceNumber,
    required String? bankName,
    required String? transactionDate,
    required String? receiptImageUrl,
  }) async {
    await _firestore.collection('payments').doc(orderId).set({
      'orderId': orderId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'referenceNumber': referenceNumber,
      'bankName': bankName ?? '',
      'transactionDate': transactionDate ?? '',
      'receiptImageUrl': receiptImageUrl ?? '',
      'status': paymentMethod == 'Cash on Delivery' ? 'completed' : 'pending_verification',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Process Cash on Delivery
  static Future<void> processCashOnDelivery(String orderId) async {
    await _firestore.collection('payments').doc(orderId).set({
      'orderId': orderId,
      'paymentMethod': 'Cash on Delivery',
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Check payment status
  static Stream<DocumentSnapshot> getPaymentStatus(String orderId) {
    return _firestore.collection('payments').doc(orderId).snapshots();
  }
}