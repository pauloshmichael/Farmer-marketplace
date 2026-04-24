import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/colors.dart';
import '../../models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  String _selectedPaymentMethod = 'Cash on Delivery';
  bool _isLoading = false;
  bool _saveAddress = true;

  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'Credit Card',
    'Debit Card',
    'UPI',
    'Net Banking',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _fullNameController.text = user.name;
      _phoneController.text = user.phone;
      _addressController.text = user.address;
    }
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final userId = authProvider.currentUser?.id ?? '';
      final farmerId = cartProvider.items.isNotEmpty
          ? cartProvider.items.first.farmerId ?? ''
          : '';
      final farmerName = cartProvider.items.isNotEmpty
          ? cartProvider.items.first.farmerName ?? ''
          : '';

      final shippingAddress = ShippingAddress(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty
            ? null
            : _landmarkController.text.trim(),
      );

      final order = await orderProvider.createOrder(
        items: cartProvider.items,
        shippingAddress: shippingAddress,
        paymentMethod: _selectedPaymentMethod,
        subtotal: cartProvider.subtotal,
        deliveryFee: cartProvider.actualDeliveryFee,
        tax: cartProvider.taxAmount,
        discount: cartProvider.discountAmount,
        total: cartProvider.total,
        userId: userId,
        farmerId: farmerId,
        farmerName: farmerName,
      );

      if (order != null && mounted) {
        cartProvider.clearCart();

        if (_selectedPaymentMethod == 'Cash on Delivery') {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.orderTracking,
            arguments: {'orderId': order.id},
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.payment,
            arguments: {
              'orderId': order.id,
              'amount': order.total,
            },
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shipping Address Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            "Shipping Address",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _fullNameController,
                              hintText: "Full Name",
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _phoneController,
                              hintText: "Phone Number",
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _addressController,
                              hintText: "Address",
                              prefixIcon: Icons.home_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _cityController,
                                    hintText: "City",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _stateController,
                                    hintText: "State",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _zipCodeController,
                                    hintText: "ZIP Code",
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _landmarkController,
                                    hintText: "Landmark (Optional)",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _saveAddress,
                                  onChanged: (value) {
                                    setState(() {
                                      _saveAddress = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                                const Text("Save this address"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Payment Method Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.payment, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            "Payment Method",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._paymentMethods.map((method) => RadioListTile(
                            value: method,
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                            title: Text(method),
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Order Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            "Order Summary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildOrderSummaryRow("Subtotal",
                          "\$${cartProvider.subtotal.toStringAsFixed(2)}"),
                      const SizedBox(height: 8),
                      _buildOrderSummaryRow(
                        "Delivery Fee",
                        cartProvider.isFreeDelivery
                            ? "Free"
                            : "\$${cartProvider.actualDeliveryFee.toStringAsFixed(2)}",
                      ),
                      if (cartProvider.discountAmount > 0) ...[
                        const SizedBox(height: 8),
                        _buildOrderSummaryRow(
                          "Discount",
                          "-\$${cartProvider.discountAmount.toStringAsFixed(2)}",
                          Colors.green,
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildOrderSummaryRow("Tax",
                          "\$${cartProvider.taxAmount.toStringAsFixed(2)}"),
                      const Divider(height: 24),
                      _buildOrderSummaryRow(
                        "Total",
                        "\$${cartProvider.total.toStringAsFixed(2)}",
                        AppColors.primary,
                        true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // Bottom Button
          Positioned(
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
                text: "Place Order",
                onPressed: _placeOrder,
                backgroundColor: AppColors.primary,
                isLoading: _isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryRow(String label, String value,
      [Color? valueColor, bool isBold = false]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ??
                (isBold ? AppColors.primary : Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }
}
