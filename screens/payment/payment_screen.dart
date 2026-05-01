import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../models/cart_model.dart';
import '../../services/payment_service.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  final String farmerId;
  final String farmerName;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic> shippingAddress;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.orderId,
    required this.farmerId,
    required this.farmerName,
    required this.items,
    required this.shippingAddress,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Cash on Delivery';
  File? _receiptImage;
  bool _isProcessing = false;
  String _referenceNumber = '';
  String _bankName = '';
  String _transactionDate = '';
  String _mobileNumber = '';
  String _mobileProvider = 'Telebirr';

  final List<String> _mobileProviders = [
    'Telebirr',
    'M-Pesa',
    'Airtel Money',
    'Safaricom'
  ];

  // Helper method to check if form is valid
  bool _isFormValid() {
    if (_selectedMethod == 'Cash on Delivery') {
      return true;
    }

    // For Bank Transfer or Mobile Money
    if (_receiptImage == null) {
      return false;
    }
    if (_referenceNumber.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAmountCard(),
                const SizedBox(height: 24),
                const Text(
                  'Select Payment Method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...PaymentService.paymentMethods
                    .map((method) => _buildPaymentMethodCard(method)),
                if (_selectedMethod != 'Cash on Delivery') ...[
                  const SizedBox(height: 24),
                  _buildPaymentDetailsForm(),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
          _buildBottomButton(),
          if (_isProcessing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Total Amount',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Order #${widget.orderId.length >= 8 ? widget.orderId.substring(0, 8) : widget.orderId}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['name'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method['name'];
          if (!method['requiresReceipt']) {
            _receiptImage = null;
            _referenceNumber = '';
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(method['icon'],
                  color: isSelected ? Colors.white : AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    method['description'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
  }

  Widget _buildPaymentDetailsForm() {
    if (_selectedMethod == 'Bank Transfer') {
      return _buildBankTransferForm();
    } else if (_selectedMethod == 'Mobile Money') {
      return _buildMobileMoneyForm();
    }
    return const SizedBox.shrink();
  }

  Widget _buildBankTransferForm() {
    final bankDetails = PaymentService.getBankDetails();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Bank Transfer Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Bank Name', bankDetails['bankName']!),
          _buildDetailRow('Account Name', bankDetails['accountName']!),
          _buildDetailRow('Account Number', bankDetails['accountNumber']!),
          _buildDetailRow('Branch', bankDetails['branch']!),
          _buildDetailRow('SWIFT Code', bankDetails['swiftCode']!),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              setState(() {
                _referenceNumber = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Reference/Transaction Number',
              hintText: 'Enter your transaction reference',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) {
              setState(() {
                _bankName = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Your Bank Name',
              hintText: 'Enter your bank name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance),
            ),
          ),
          const SizedBox(height: 12),
          _buildDatePicker(),
          const SizedBox(height: 16),
          _buildReceiptUploader(),
          const SizedBox(height: 12),
          _buildInfoMessage(
            'Please transfer the exact amount and upload a clear screenshot of your payment receipt.',
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMoneyForm() {
    final mobileDetails = PaymentService.getMobileMoneyDetails();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone_android, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Mobile Money Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Provider', mobileDetails['provider']!),
          _buildDetailRow('Number', mobileDetails['number']!),
          _buildDetailRow('Account Name', mobileDetails['accountName']!),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _mobileProvider,
            decoration: const InputDecoration(
              labelText: 'Select Provider',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_android),
            ),
            items: _mobileProviders.map((provider) {
              return DropdownMenuItem<String>(
                value: provider,
                child: Text(provider),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _mobileProvider = value!;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) {
              setState(() {
                _mobileNumber = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Your Mobile Number',
              hintText: 'Enter your phone number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) {
              setState(() {
                _referenceNumber = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Transaction Reference',
              hintText: 'Enter transaction ID',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
          ),
          const SizedBox(height: 12),
          _buildDatePicker(),
          const SizedBox(height: 16),
          _buildReceiptUploader(),
          const SizedBox(height: 12),
          _buildInfoMessage(
            'Send payment to the number above and upload the confirmation screenshot.',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextField(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            _transactionDate = '${date.day}/${date.month}/${date.year}';
          });
        }
      },
      controller: TextEditingController(text: _transactionDate),
      decoration: const InputDecoration(
        labelText: 'Transaction Date',
        hintText: 'Select date',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      readOnly: true,
    );
  }

  Widget _buildReceiptUploader() {
    return GestureDetector(
      onTap: () async {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile =
            await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _receiptImage = File(pickedFile.path);
          });
        }
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _receiptImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _receiptImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _receiptImage = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload,
                      size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload receipt',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG accepted',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final bool isValid = _isFormValid();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomButton(
          text: _selectedMethod == 'Cash on Delivery'
              ? 'Place Order'
              : 'Submit Payment',
          onPressed: () {
            if (isValid) {
              _processPayment();
            }
          },
          backgroundColor: isValid ? AppColors.primary : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing payment...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and upload receipt'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Create order
      final order = await orderProvider.createOrder(
        items: widget.items
            .map((item) => CartItem(
                  productId: item['productId'] ?? '',
                  name: item['name'] ?? '',
                  image: item['image'] ?? '',
                  price: (item['price'] ?? 0).toDouble(),
                  quantity: item['quantity'] ?? 1,
                  farmerId: item['farmerId'],
                  farmerName: item['farmerName'],
                ))
            .toList(),
        shippingAddress: ShippingAddress.fromJson(widget.shippingAddress),
        paymentMethod: _selectedMethod,
        subtotal: widget.amount,
        deliveryFee: 0.0,
        tax: 0.0,
        discount: 0.0,
        total: widget.amount,
        userId: authProvider.currentUser?.id ?? '',
        farmerId: widget.farmerId,
        farmerName: widget.farmerName,
      );

      if (order == null) {
        throw Exception('Failed to create order');
      }

      String? receiptUrl;
      if (_receiptImage != null) {
        receiptUrl = await PaymentService.uploadReceiptImage(
            _receiptImage!, widget.orderId);
      }

      await PaymentService.savePaymentInfo(
        orderId: widget.orderId,
        amount: widget.amount,
        paymentMethod: _selectedMethod,
        referenceNumber: _referenceNumber,
        bankName: _bankName.isEmpty ? null : _bankName,
        transactionDate: _transactionDate.isEmpty ? null : _transactionDate,
        receiptImageUrl: receiptUrl,
      );

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart();

      setState(() {
        _isProcessing = false;
      });

      if (_selectedMethod == 'Cash on Delivery') {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.orderTracking,
            arguments: {'orderId': widget.orderId},
          );
        }
      } else {
        if (mounted) {
          _showSuccessDialog();
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      String errorMessage = e.toString();

      // Check if it's a permission error
      if (errorMessage.contains('permission-denied')) {
        errorMessage =
            'Please configure Firebase Security Rules. Contact support.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Payment Submitted'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Your payment receipt has been submitted successfully.'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Our team will verify your payment within 24 hours.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.orders);
              },
              child: const Text('View Orders'),
            ),
          ],
        );
      },
    );
  }
}
