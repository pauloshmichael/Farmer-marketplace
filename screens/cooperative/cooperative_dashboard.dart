import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cooperative_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/colors.dart';
import 'cooperative_members_screen.dart';
import 'cooperative_products_screen.dart';
import 'cooperative_profile_screen.dart';

class CooperativeDashboard extends StatefulWidget {
  const CooperativeDashboard({super.key});

  @override
  State<CooperativeDashboard> createState() => _CooperativeDashboardState();
}

class _CooperativeDashboardState extends State<CooperativeDashboard> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Helper method to safely get short order ID - FIXES THE ERROR
  String _getShortOrderId(String id) {
    if (id.length >= 8) {
      return id.substring(0, 8);
    }
    return id;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final cooperativeProvider =
        Provider.of<CooperativeProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    cooperativeProvider.fetchCooperatives();
    cooperativeProvider.fetchCurrentCooperative();
    productProvider.fetchCooperativeProducts();
    orderProvider.fetchCooperativeOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildHomeTab(),
          const CooperativeProductsScreen(),
          const CooperativeMembersScreen(),
          const CooperativeProfileScreen(),
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
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final cooperativeProvider = Provider.of<CooperativeProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final cooperative = cooperativeProvider.currentCooperative;
    final totalProducts = productProvider.cooperativeProducts.length;
    final totalMembers = cooperativeProvider.members.length;
    final pendingOrders = orderProvider.cooperativeOrders
        .where(
            (order) => order.status == 'pending' || order.status == 'confirmed')
        .length;
    final totalRevenue = orderProvider.cooperativeOrders
        .where((order) => order.status == 'delivered')
        .fold<double>(0, (sum, order) => sum + order.total);

    return RefreshIndicator(
      onRefresh: () async {
        await cooperativeProvider.fetchCurrentCooperative();
        await productProvider.fetchCooperativeProducts();
        await orderProvider.fetchCooperativeOrders();
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
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: cooperative?.logo != null
                            ? NetworkImage(cooperative!.logo)
                            : null,
                        child: cooperative?.logo == null
                            ? Text(
                                cooperative?.name[0].toUpperCase() ?? 'C',
                                style: const TextStyle(
                                  fontSize: 28,
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
                              cooperative?.name ?? 'Cooperative',
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
                          icon: Icons.inventory_2,
                          title: 'Products',
                          value: totalProducts.toString(),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people,
                          title: 'Members',
                          value: totalMembers.toString(),
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
                          icon: Icons.pending_actions,
                          title: 'Pending Orders',
                          value: pendingOrders.toString(),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.attach_money,
                          title: 'Total Revenue',
                          value: '\$${totalRevenue.toStringAsFixed(2)}',
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
                    subtitle: "Add new product to cooperative",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.addProduct);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.person_add,
                    title: "Add Member",
                    subtitle: "Invite new members",
                    onTap: () {
                      _showInviteMemberDialog();
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
                    subtitle: "Check pending orders",
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                        _pageController.jumpToPage(1);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.analytics,
                    title: "Analytics",
                    subtitle: "View reports",
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
                      _selectedIndex = 1;
                      _pageController.jumpToPage(1);
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
                : orderProvider.cooperativeOrders.isEmpty
                    ? _buildEmptyOrders()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderProvider.cooperativeOrders.length > 5
                            ? 5
                            : orderProvider.cooperativeOrders.length,
                        itemBuilder: (context, index) {
                          final order = orderProvider.cooperativeOrders[index];
                          return _buildRecentOrderCard(order);
                        },
                      ),

            const SizedBox(height: 24),

            // Top Products
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Top Products",
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
                    "View All",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            productProvider.isLoading
                ? const LoadingWidget()
                : productProvider.cooperativeProducts.isEmpty
                    ? _buildEmptyProducts()
                    : SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              productProvider.cooperativeProducts.length > 5
                                  ? 5
                                  : productProvider.cooperativeProducts.length,
                          itemBuilder: (context, index) {
                            final product =
                                productProvider.cooperativeProducts[index];
                            return _buildTopProductCard(product);
                          },
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

  // FIXED: _buildRecentOrderCard with safe substring
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
          "Order #${_getShortOrderId(order.id)}", // FIXED: using safe method
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

  Widget _buildTopProductCard(product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.images.isNotEmpty
                    ? product.images.first
                    : 'https://via.placeholder.com/160',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey.shade200,
                    child:
                        const Icon(Icons.image, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Sold: ${product.soldCount ?? 0}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                      ),
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

  Widget _buildEmptyProducts() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            "No products added",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addProduct);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text("Add Product"),
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invite Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Enter the email address of the member you want to invite'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invitation sent successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Send Invite'),
            ),
          ],
        );
      },
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
              _buildAnalyticsRow("Total Sales", "\$45,678"),
              _buildAnalyticsRow("Total Orders", "1,234"),
              _buildAnalyticsRow("Average Order Value", "\$37.00"),
              _buildAnalyticsRow("Member Growth", "+15%"),
              _buildAnalyticsRow("Product Performance", "4.8 ★"),
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
