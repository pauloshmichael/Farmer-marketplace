import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/colors.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'all';

  final List<String> _statusFilters = ['all', 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.userRole == 'farmer') {
      await orderProvider.fetchFarmerOrders();
    } else if (authProvider.userRole == 'cooperative') {
      await orderProvider.fetchCooperativeOrders();
    } else {
      await orderProvider.fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final orders = authProvider.userRole == 'farmer' 
        ? orderProvider.farmerOrders 
        : authProvider.userRole == 'cooperative'
            ? orderProvider.cooperativeOrders
            : orderProvider.orders;
    
    final filteredOrders = _selectedStatus == 'all'
        ? orders
        : orders.where((order) => order.status == _selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(authProvider.userRole)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Active Orders'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Status Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final status = _statusFilters[index];
                final displayName = status == 'all' ? 'All' : _getStatusDisplayName(status);
                final isSelected = _selectedStatus == status;
                final orderCount = status == 'all'
                    ? orders.length
                    : orders.where((o) => o.status == status).length;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text('$displayName ($orderCount)'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          
          // Orders List
          Expanded(
            child: orderProvider.isLoading
                ? const LoadingWidget()
                : filteredOrders.isEmpty
                    ? _buildEmptyState(authProvider.userRole)
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _buildOrderCard(order, authProvider.userRole);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(String userRole) {
    switch (userRole) {
      case 'farmer':
        return 'Manage Orders';
      case 'cooperative':
        return 'Cooperative Orders';
      default:
        return 'My Orders';
    }
  }

  // Helper method for safe order ID display
  String _getSafeOrderId(String id) {
    if (id.length >= 8) {
      return id.substring(0, 8);
    }
    return id;
  }

  Widget _buildOrderCard(order, String userRole) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.orderDetail,
            arguments: {'orderId': order.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FIXED: Safe substring for order ID
                        Text(
                          "Order #${_getSafeOrderId(order.id)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.orderDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(order.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Order Items Preview
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: order.items.length > 4 ? 4 : order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(item.productImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                'x${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Order Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${order.items.length} item${order.items.length > 1 ? 's' : ''}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (order.trackingNumber != null)
                        Text(
                          "Tracking: ${order.trackingNumber}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\$${order.total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if ((userRole == 'farmer' || userRole == 'cooperative') && order.status == 'pending')
                        const SizedBox(height: 8),
                      if ((userRole == 'farmer' || userRole == 'cooperative') && order.status == 'pending')
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              _showUpdateStatusDialog(order);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Process",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      if (order.status == 'delivered' && userRole != 'farmer' && userRole != 'cooperative')
                        TextButton(
                          onPressed: () {
                            // Navigate to write review
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: const Text(
                            "Write Review",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              // Progress Indicator for active orders
              if (order.status != 'delivered' && order.status != 'cancelled')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildOrderProgress(order.status),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderProgress(String status) {
    final steps = ['pending', 'confirmed', 'shipped', 'delivered'];
    final currentStep = steps.indexOf(status);
    
    return Column(
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
                      color: index <= currentStep ? null : Colors.grey.shade300,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(index == 0 ? 4 : 0),
                        right: Radius.circular(index == steps.length - 1 ? 4 : 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    _getStepIcon(steps[index]),
                    size: 16,
                    color: index <= currentStep ? AppColors.primary : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStepLabel(steps[index]),
                    style: TextStyle(
                      fontSize: 10,
                      color: index <= currentStep ? AppColors.primary : Colors.grey.shade500,
                      fontWeight: index <= currentStep ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
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

  Widget _buildEmptyState(String userRole) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            userRole == 'farmer'
                ? "No orders yet"
                : userRole == 'cooperative'
                    ? "No cooperative orders"
                    : "You haven't placed any orders yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userRole == 'farmer'
                ? "Orders will appear here when customers purchase your products"
                : userRole == 'cooperative'
                    ? "Orders from cooperative members will appear here"
                    : "Start shopping to see your orders here",
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          if (userRole != 'farmer' && userRole != 'cooperative')
            const SizedBox(height: 24),
          if (userRole != 'farmer' && userRole != 'cooperative')
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.productList);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text("Start Shopping"),
            ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Update Order Status",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatusOption(order, 'confirmed', 'Confirm Order', Icons.check_circle),
              _buildStatusOption(order, 'shipped', 'Mark as Shipped', Icons.local_shipping),
              _buildStatusOption(order, 'delivered', 'Mark as Delivered', Icons.delivery_dining),
              _buildStatusOption(order, 'cancelled', 'Cancel Order', Icons.cancel, isDestructive: true),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(order, String status, String label, IconData icon, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.primary),
      title: Text(
        label,
        style: TextStyle(color: isDestructive ? Colors.red : null),
      ),
      onTap: () async {
        Navigator.pop(context);
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        await orderProvider.updateOrderStatus(order.id, status);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order ${status.toUpperCase()}'),
              backgroundColor: isDestructive ? Colors.red : Colors.green,
            ),
          );
          await _loadOrders();
        }
      },
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
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

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}