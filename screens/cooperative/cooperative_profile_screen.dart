import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cooperative_provider.dart';
import '../../utils/colors.dart';

class CooperativeProfileScreen extends StatelessWidget {
  const CooperativeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cooperativeProvider = Provider.of<CooperativeProvider>(context);
    
    final cooperative = cooperativeProvider.currentCooperative;
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooperative Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover Image
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: cooperative?.coverImage != null
                        ? DecorationImage(
                            image: NetworkImage(cooperative!.coverImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.green,
                  ),
                  child: cooperative?.coverImage == null
                      ? const Center(
                          child: Icon(
                            Icons.agriculture,
                            size: 80,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: -40,
                  left: 20,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: cooperative?.logo != null
                        ? NetworkImage(cooperative!.logo)
                        : null,
                    child: cooperative?.logo == null
                        ? Text(
                            cooperative?.name[0].toUpperCase() ?? 'C',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 50),
            
            // Cooperative Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    cooperative?.name ?? 'Cooperative Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cooperative?.isVerified ?? false ? Icons.verified : Icons.verified_outlined,
                        size: 16,
                        color: cooperative?.isVerified ?? false ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cooperative?.isVerified ?? false ? 'Verified Cooperative' : 'Verification Pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: cooperative?.isVerified ?? false ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStat(
                      value: cooperative?.memberCount.toString() ?? '0',
                      label: 'Members',
                      icon: Icons.people,
                    ),
                  ),
                  Expanded(
                    child: _buildStat(
                      value: cooperative?.productCount.toString() ?? '0',
                      label: 'Products',
                      icon: Icons.inventory_2,
                    ),
                  ),
                  Expanded(
                    child: _buildStat(
                      value: cooperative?.rating.toString() ?? '0.0',
                      label: 'Rating',
                      icon: Icons.star,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About Cooperative",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cooperative?.description ?? 'No description available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contact Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Contact Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.location_on, cooperative?.address ?? 'No address provided'),
                  _buildInfoRow(Icons.phone, cooperative?.phone ?? 'No phone number'),
                  _buildInfoRow(Icons.email, cooperative?.email ?? 'No email'),
                  _buildInfoRow(Icons.language, cooperative?.website ?? 'No website'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Categories
            if (cooperative?.categories.isNotEmpty ?? false)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Categories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cooperative!.categories.map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Admin Actions
            if (user?.id == cooperative?.adminId)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Admin Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAdminAction(
                      icon: Icons.edit,
                      title: "Edit Cooperative Info",
                      onTap: () {
                        // Navigate to edit cooperative info
                      },
                    ),
                    _buildAdminAction(
                      icon: Icons.people,
                      title: "Manage Members",
                      onTap: () {
                        // Navigate to members management
                      },
                    ),
                    _buildAdminAction(
                      icon: Icons.settings,
                      title: "Settings",
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.settings);
                      },
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}