import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _couponCode;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final items = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                _showClearCartDialog(context, cartProvider);
              },
              child: const Text(
                'Clear Cart',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await cartProvider.fetchCart();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildCartItem(item, cartProvider);
                      },
                    ),
                  ),
                ),
                _buildOrderSummary(cartProvider, authProvider),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Add items to get started",
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.productList);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text("Start Shopping"),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(item, CartProvider cartProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.farmerName != null)
                    Text(
                      "by ${item.farmerName}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Price
                      if (item.discount != null && item.discount! > 0) ...[
                        Text(
                          '\$${item.discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: () {
                        if (item.quantity > 1) {
                          cartProvider.updateQuantity(
                              item.productId, item.quantity - 1);
                        } else {
                          _showRemoveItemDialog(
                              context, cartProvider, item.productId);
                        }
                      },
                    ),
                    Container(
                      width: 40,
                      height: 35,
                      alignment: Alignment.center,
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: () {
                        cartProvider.updateQuantity(
                            item.productId, item.quantity + 1);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _showRemoveItemDialog(
                        context, cartProvider, item.productId);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Remove",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildOrderSummary(
      CartProvider cartProvider, AuthProvider authProvider) {
    final subtotal = cartProvider.subtotal;
    final deliveryFee = cartProvider.actualDeliveryFee;
    final tax = cartProvider.taxAmount;
    final discount = cartProvider.discountAmount;
    final total = cartProvider.total;
    final isFreeDelivery = cartProvider.isFreeDelivery;

    return Container(
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
      child: Column(
        children: [
          // Coupon Section
          if (_couponCode == null) _buildCouponInput(cartProvider),

          if (_couponCode != null) _buildAppliedCoupon(cartProvider),

          const SizedBox(height: 16),

          // Price Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildPriceRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}",
                    isBold: false),
                const SizedBox(height: 8),
                _buildPriceRow(
                  "Delivery Fee",
                  isFreeDelivery
                      ? "Free"
                      : "\$${deliveryFee.toStringAsFixed(2)}",
                  isBold: false,
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    "Discount",
                    "-\$${discount.toStringAsFixed(2)}",
                    valueColor: Colors.green,
                    isBold: false,
                  ),
                ],
                const SizedBox(height: 8),
                _buildPriceRow("Tax", "\$${tax.toStringAsFixed(2)}",
                    isBold: false),
                const Divider(height: 24),
                _buildPriceRow(
                  "Total",
                  "\$${total.toStringAsFixed(2)}",
                  valueColor: AppColors.primary,
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Checkout Button - FIXED: Generate proper order ID
          // In cart_screen.dart, update the checkout button
          // Checkout Button - FIXED
          CustomButton(
            text: "Proceed to Checkout",
            onPressed: () {
              if (authProvider.isAuthenticated) {
                // Get farmer info from first item in cart
                final firstItem = cartProvider.items.first;
                final farmerId = firstItem.farmerId ?? '';
                final farmerName = firstItem.farmerName ?? 'Farmer';

                // Create shipping address payload
                final Map<String, dynamic> shippingAddress = {
                  'fullName': authProvider.currentUser?.name ?? '',
                  'phone': authProvider.currentUser?.phone ?? '',
                  'address': authProvider.currentUser?.address ?? '',
                  'city': '',
                  'state': '',
                  'zipCode': '',
                };

                final String orderId =
                    'ORD_${DateTime.now().millisecondsSinceEpoch}';

                // Convert items to List<Map<String, dynamic>> correctly
                final List<Map<String, dynamic>> itemsList =
                    cartProvider.items.map((item) {
                  return {
                    'productId': item.productId,
                    'name': item.name,
                    'image': item.image,
                    'price': item.price,
                    'quantity': item.quantity,
                    'farmerId': item.farmerId,
                    'farmerName': item.farmerName,
                    'discount': item.discount,
                  };
                }).toList();

                Navigator.pushNamed(
                  context,
                  AppRoutes.payment,
                  arguments: {
                    'orderId': orderId,
                    'amount': total,
                    'farmerId': farmerId,
                    'farmerName': farmerName,
                    'items': itemsList,
                    'shippingAddress': shippingAddress,
                  },
                );
              } else {
                _showLoginRequiredDialog(context);
              }
            },
            backgroundColor: AppColors.primary,
          ),
          const SizedBox(height: 8),

          // Continue Shopping Link
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.productList);
            },
            child: const Text("Continue Shopping"),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInput(CartProvider cartProvider) {
    final TextEditingController couponController = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: couponController,
              decoration: const InputDecoration(
                hintText: "Enter coupon code",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final code = couponController.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                final success = await cartProvider.applyCoupon(code);
                if (success && mounted) {
                  setState(() {
                    _couponCode = code;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coupon applied successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid coupon code'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              "Apply",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedCoupon(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Coupon Applied: $_couponCode",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  "Saved \$${cartProvider.discountAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _couponCode = null;
              });
              cartProvider.removeCoupon();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
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
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ??
                (isBold ? AppColors.primary : Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text(
              'Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.pop(context);
                setState(() {
                  _couponCode = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveItemDialog(
      BuildContext context, CartProvider cartProvider, String productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: const Text(
              'Are you sure you want to remove this item from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.removeFromCart(productId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item removed from cart'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please login to proceed with checkout'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }
}
