import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    
    final user = authProvider.currentUser;
    final isFarmer = authProvider.userRole == 'farmer';
    final isCooperative = authProvider.userRole == 'cooperative';
    
    final totalOrders = orderProvider.orders.length;
    final completedOrders = orderProvider.orders
        .where((order) => order.status == 'delivered')
        .length;
    final totalSpent = orderProvider.orders
        .where((order) => order.status == 'delivered')
        .fold<double>(0, (sum, order) => sum + (order.total ?? 0));
    
    final totalProducts = isFarmer ? productProvider.farmerProducts.length : 0;
    final totalRevenue = isFarmer ? orderProvider.farmerOrders
        .where((order) => order.status == 'delivered')
        .fold<double>(0, (sum, order) => sum + (order.total ?? 0)) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Avatar with Edit Button
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.profileImage != null
                            ? NetworkImage(user!.profileImage!)
                            : null,
                        child: user?.profileImage == null
                            ? Text(
                                user?.name.isNotEmpty == true 
                                    ? user!.name[0].toUpperCase() 
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.editProfile);
                            },
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleDisplayName(authProvider.userRole),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isFarmer || isCooperative
                  ? _buildFarmerStats(totalProducts, totalRevenue, totalOrders)
                  : _buildBuyerStats(totalOrders, completedOrders, totalSpent),
            ),

            const SizedBox(height: 24),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: "Edit Profile",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.editProfile);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.changePassword);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,  // Fixed icon name
                    title: "Saved Addresses",
                    subtitle: "Manage your delivery addresses",
                    onTap: () {
                      // Navigate to addresses screen
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.payment_outlined,
                    title: "Payment Methods",
                    subtitle: "Manage saved cards and payment options",
                    onTap: () {
                      // Navigate to payment methods screen
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,  // Fixed icon name
                    title: "Notifications",
                    subtitle: "Manage notification preferences",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.language_outlined,
                    title: "Language",
                    subtitle: "English",
                    onTap: () {
                      _showLanguageDialog(context);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,  // Fixed icon name
                    title: "Privacy Policy",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.privacyPolicy);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: "About",
                    subtitle: "Version 1.0.0",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.about);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: "Logout",
                    textColor: Colors.red,
                    showArrow: false,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerStats(int totalOrders, int completedOrders, double totalSpent) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: "Total Orders",
            value: totalOrders.toString(),
            icon: Icons.shopping_bag_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: "Completed",
            value: completedOrders.toString(),
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: "Total Spent",
            value: "\$${totalSpent.toStringAsFixed(2)}",
            icon: Icons.attach_money,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildFarmerStats(int totalProducts, double totalRevenue, int totalOrders) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: "Products",
            value: totalProducts.toString(),
            icon: Icons.inventory_2_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: "Revenue",
            value: "\$${totalRevenue.toStringAsFixed(2)}",
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: "Orders",
            value: totalOrders.toString(),
            icon: Icons.receipt_long_outlined,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppColors.primary),
        title: Text(
          title,
          style: TextStyle(color: textColor),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: showArrow ? const Icon(Icons.chevron_right, color: Colors.grey) : null,
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = ['English', 'Spanish', 'French', 'German', 'Hindi', 'Arabic'];
    
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
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...languages.map((language) => ListTile(
                leading: const Icon(Icons.language, color: AppColors.primary),
                title: Text(language),
                trailing: language == 'English' 
                    ? const Icon(Icons.check, color: AppColors.primary) 
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to $language'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'farmer':
        return 'Farmer';
      case 'cooperative':
        return 'Cooperative Member';
      default:
        return 'Buyer';
    }
  }
}