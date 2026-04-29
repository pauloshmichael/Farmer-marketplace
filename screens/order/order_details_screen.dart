import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  void _loadOrderDetails() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchOrderDetails(widget.orderId);
    setState(() {
      _isLoading = false;
    });
  }

  // Helper method for safe ID display
  String _getShortId(String id) {
    if (id.length >= 8) {
      return id.substring(0, 8);
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final order = orderProvider.currentOrder;
    final isFarmer = authProvider.userRole == 'farmer';

    if (_isLoading || order == null) {
      return const Scaffold(
        body: Center(child: LoadingWidget()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          if (order.status == 'pending' && !isFarmer)
            TextButton(
              onPressed: _cancelOrder,
              child: const Text(
                'Cancel Order',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(order.status).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(order.status),
                      color: _getStatusColor(order.status),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusDisplayName(order.status),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusMessage(order.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Order Progress Tracker
            if (order.status != 'delivered' && order.status != 'cancelled')
              _buildOrderProgress(order.status),

            const SizedBox(height: 20),

            // Order Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // FIXED: Order ID display - using full ID, no substring needed
                  _buildInfoRow("Order ID", order.id),
                  _buildInfoRow("Order Date", _formatDateTime(order.orderDate)),
                  if (order.deliveredDate != null)
                    _buildInfoRow("Delivered Date",
                        _formatDateTime(order.deliveredDate!)),
                  if (order.estimatedDeliveryDate != null)
                    _buildInfoRow("Est. Delivery",
                        _formatDate(order.estimatedDeliveryDate!)),
                  _buildInfoRow("Payment Method", order.paymentMethod),
                  _buildInfoRow("Payment Status", order.paymentStatus),
                  if (order.trackingNumber != null)
                    _buildInfoRow("Tracking Number", order.trackingNumber!,
                        onTap: () {
                      // Open tracking
                    }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Shipping Address
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 20, color: AppColors.primary),
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
                  const SizedBox(height: 12),
                  Text(
                    order.shippingAddress.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(order.shippingAddress.phone),
                  const SizedBox(height: 4),
                  Text(order.shippingAddress.address),
                  Text(
                      "${order.shippingAddress.city}, ${order.shippingAddress.state}"),
                  Text(order.shippingAddress.zipCode),
                  if (order.shippingAddress.landmark != null)
                    Text("Landmark: ${order.shippingAddress.landmark}"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Order Items
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Items",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return _buildOrderItem(item);
                    },
                  ),
                  const Divider(height: 24),
                  _buildPriceSummary(order),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            if (order.status == 'delivered')
              CustomButton(
                text: "Write a Review",
                onPressed: () {
                  // Navigate to write review
                },
                isOutlined: true,
              ),

            if (order.status == 'pending' && !isFarmer)
              const SizedBox(height: 12),

            if (order.status == 'pending' && !isFarmer)
              CustomButton(
                text: "Cancel Order",
                onPressed: _cancelOrder,
                backgroundColor: Colors.red,
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderProgress(String status) {
    final steps = ['pending', 'confirmed', 'shipped', 'delivered'];
    final currentStep = steps.indexOf(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: index <= currentStep
                            ? const LinearGradient(
                                colors: [AppColors.primary, Colors.green],
                              )
                            : null,
                        color:
                            index <= currentStep ? null : Colors.grey.shade300,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(index == 0 ? 4 : 0),
                          right: Radius.circular(
                              index == steps.length - 1 ? 4 : 0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: index <= currentStep
                            ? AppColors.primary
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStepIcon(steps[index]),
                        size: 20,
                        color: index <= currentStep
                            ? Colors.white
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStepLabel(steps[index]),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: index <= currentStep
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: index <= currentStep
                            ? AppColors.primary
                            : Colors.grey.shade500,
                      ),
                    ),
                    if (index <= currentStep)
                      Text(
                        _getStepDate(status, steps[index]),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getStepDate(String currentStatus, String step) {
    if (step == 'pending') return _formatDate(DateTime.now());
    if (step == currentStatus) return 'Today';
    return '';
  }

  IconData _getStepIcon(String step) {
    switch (step) {
      case 'pending':
        return Icons.shopping_bag;
      case 'confirmed':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.delivery_dining;
      default:
        return Icons.circle;
    }
  }

  String _getStepLabel(String step) {
    switch (step) {
      case 'pending':
        return 'Ordered';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      default:
        return step;
    }
  }

  Widget _buildOrderItem(item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.productImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Quantity: ${item.quantity}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (item.farmerName != null)
                  Text(
                    "Sold by: ${item.farmerName}",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            "\$${item.total.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(order) {
    return Column(
      children: [
        _buildPriceRow("Subtotal", "\$${order.subtotal.toStringAsFixed(2)}"),
        const SizedBox(height: 8),
        _buildPriceRow(
            "Shipping Fee", "\$${order.shippingFee.toStringAsFixed(2)}"),
        const SizedBox(height: 8),
        _buildPriceRow("Tax", "\$${order.tax.toStringAsFixed(2)}"),
        if (order.discount > 0) ...[
          const SizedBox(height: 8),
          _buildPriceRow("Discount", "-\$${order.discount.toStringAsFixed(2)}",
              Colors.green),
        ],
        const Divider(height: 24),
        _buildPriceRow(
          "Total",
          "\$${order.total.toStringAsFixed(2)}",
          AppColors.primary,
          true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value,
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
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ??
                (isBold ? AppColors.primary : Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: const Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isCancelling = true;
      });

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final success = await orderProvider.cancelOrder(widget.orderId, '', '');

      setState(() {
        _isCancelling = false;
      });

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Order Placed';
      case 'confirmed':
        return 'Order Confirmed';
      case 'shipped':
        return 'Order Shipped';
      case 'delivered':
        return 'Order Delivered';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return status;
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Your order has been placed and is waiting for confirmation';
      case 'confirmed':
        return 'Your order has been confirmed and is being processed';
      case 'shipped':
        return 'Your order has been shipped and is on the way';
      case 'delivered':
        return 'Your order has been delivered successfully';
      case 'cancelled':
        return 'Your order has been cancelled';
      default:
        return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.delivery_dining;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
