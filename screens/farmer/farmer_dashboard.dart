import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/colors.dart';
import 'my_products_screen.dart';
import 'farmer_orders_screen.dart';
import 'farmer_profile_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _listenForNewOrders();
  }

  void _loadData() {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    productProvider.fetchFarmerProducts();
    orderProvider.fetchFarmerOrders();
  }

  void _listenForNewOrders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      FirebaseFirestore.instance
          .collection('orders')
          .where('farmerId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          // Show notification to farmer
          _showNewOrderNotification(snapshot.docs.length);
          // Refresh orders
          _loadData();
        }
      });
    }
  }

  void _showNewOrderNotification(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have $count new order${count > 1 ? 's' : ''}!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildHomeTab(authProvider, productProvider, orderProvider),
          const MyProductsScreen(),
          const FarmerOrdersScreen(),
          const FarmerProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addProduct);
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHomeTab(
    AuthProvider authProvider,
    ProductProvider productProvider,
    OrderProvider orderProvider,
  ) {
    final pendingOrders = orderProvider.farmerOrders
        .where(
            (order) => order.status == 'pending' || order.status == 'confirmed')
        .length;

    final totalProducts = productProvider.farmerProducts.length;
    final totalRevenue = orderProvider.farmerOrders
        .where((order) => order.status == 'delivered')
        .fold<double>(0, (sum, order) => sum + order.total);

    final lowStockProducts = productProvider.farmerProducts
        .where((product) => product.quantity < 10)
        .length;

    return RefreshIndicator(
      onRefresh: () async {
        await productProvider.fetchFarmerProducts();
        await orderProvider.fetchFarmerOrders();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            authProvider.currentUser?.profileImage != null
                                ? NetworkImage(
                                    authProvider.currentUser!.profileImage!)
                                : null,
                        child: authProvider.currentUser?.profileImage == null
                            ? Text(
                                authProvider.currentUser?.name[0]
                                        .toUpperCase() ??
                                    'F',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back,",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            Text(
                              authProvider.currentUser?.name ?? 'Farmer',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Total Products',
                          value: totalProducts.toString(),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.pending_actions_outlined,
                          title: 'Pending Orders',
                          value: pendingOrders.toString(),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.attach_money,
                          title: 'Total Revenue',
                          value: '\$${totalRevenue.toStringAsFixed(2)}',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.warning_amber_outlined,
                          title: 'Low Stock',
                          value: lowStockProducts.toString(),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.add_shopping_cart,
                    title: "Add Product",
                    subtitle: "Add new product to store",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.addProduct);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.inventory_2,
                    title: "Manage Stock",
                    subtitle: "Update product inventory",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.myProducts);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.receipt_long,
                    title: "View Orders",
                    subtitle: "Check new orders",
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                        _pageController.jumpToPage(2);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.analytics,
                    title: "Analytics",
                    subtitle: "View sales report",
                    onTap: () {
                      _showAnalyticsDialog();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Orders",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                      _pageController.jumpToPage(2);
                    });
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            orderProvider.isLoading
                ? const LoadingWidget()
                : orderProvider.farmerOrders.isEmpty
                    ? _buildEmptyOrders()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderProvider.farmerOrders.length > 5
                            ? 5
                            : orderProvider.farmerOrders.length,
                        itemBuilder: (context, index) {
                          final order = orderProvider.farmerOrders[index];
                          return _buildRecentOrderCard(order);
                        },
                      ),

            const SizedBox(height: 24),

            // Low Stock Products
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Low Stock Alert",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                      _pageController.jumpToPage(1);
                    });
                  },
                  child: const Text(
                    "Manage",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lowStockProducts > 0)
              ...productProvider.farmerProducts
                  .where((product) => product.quantity < 10)
                  .take(3)
                  .map((product) => _buildLowStockCard(product))
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "All products have sufficient stock",
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: Safe substring for order ID
  Widget _buildRecentOrderCard(order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getOrderStatusColor(order.status).withValues(alpha: 0.2),
          child: Icon(
            _getOrderStatusIcon(order.status),
            color: _getOrderStatusColor(order.status),
            size: 20,
          ),
        ),
        title: Text(
          "Order #${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${order.items.length} items • ${_formatDate(order.orderDate)}",
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$${order.total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getOrderStatusColor(order.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: _getOrderStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.orderDetail,
            arguments: {'orderId': order.id},
          );
        },
      ),
    );
  }

  Widget _buildLowStockCard(product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: product.images.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(product.images.first),
                    fit: BoxFit.cover,
                  )
                : null,
            color: Colors.grey.shade200,
          ),
          child: product.images.isEmpty
              ? const Icon(Icons.image, color: Colors.grey)
              : null,
        ),
        title: Text(product.name),
        subtitle: Text("Current Stock: ${product.quantity} units"),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.editProduct,
              arguments: {'productId': product.id},
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("Restock"),
        ),
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_outlined, size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            "No orders yet",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Analytics Overview"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnalyticsRow("Total Sales", "\$12,345"),
              _buildAnalyticsRow("Total Orders", "156"),
              _buildAnalyticsRow("Average Order Value", "\$79.20"),
              _buildAnalyticsRow("Customer Rating", "4.8 ★"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
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

  Color _getOrderStatusColor(String status) {
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

  IconData _getOrderStatusIcon(String status) {
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
}
