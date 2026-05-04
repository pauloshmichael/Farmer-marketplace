import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
            ),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.changePassword);
              },
            ),
            _buildSettingsTile(
              icon:
                  Icons.location_on_outlined, // Fixed: was location_on_outline
              title: 'Manage Addresses',
              subtitle: 'Add or remove delivery addresses',
              onTap: () {
                // Navigate to addresses screen
              },
            ),
            _buildSettingsTile(
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              subtitle: 'Manage saved cards and payment options',
              onTap: () {
                // Navigate to payment methods screen
              },
            ),

            const SizedBox(height: 16),

            // Preferences Section
            _buildSectionHeader('Preferences'),
            _buildSettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () {
                _showLanguageDialog();
              },
              showArrow: true,
            ),
            _buildSettingsTile(
              icon: Icons.attach_money,
              title: 'Currency',
              subtitle: _selectedCurrency,
              onTap: () {
                _showCurrencyDialog();
              },
              showArrow: true,
            ),
            SwitchListTile(
              secondary: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                color: AppColors.primary,
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              value: isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              activeThumbColor: AppColors.primary,
            ),

            const SizedBox(height: 16),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined,
                  color: AppColors.primary), // Fixed: was notifications_outline
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive notifications on your device'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_outlined,
                  color: AppColors.primary),
              title: const Text('Sound'),
              subtitle: const Text('Play sound for notifications'),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.vibration, color: AppColors.primary),
              title: const Text('Vibration'),
              subtitle: const Text('Vibrate on notification'),
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            _buildSettingsTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notification Settings',
              subtitle: 'Configure notification preferences',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
              showArrow: true,
            ),

            const SizedBox(height: 16),

            // Support Section
            _buildSectionHeader('Support'),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'FAQs and support',
              onTap: () {
                // Navigate to help center
              },
              showArrow: true,
            ),
            _buildSettingsTile(
              icon: Icons.chat_bubble_outline,
              title: 'Contact Us',
              subtitle: 'Get in touch with support team',
              onTap: () {
                // Navigate to contact us
              },
              showArrow: true,
            ),
            _buildSettingsTile(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Help us improve',
              onTap: () {
                _showFeedbackDialog();
              },
              showArrow: true,
            ),
            _buildSettingsTile(
              icon: Icons.star_outline,
              title: 'Rate Us',
              subtitle: 'Rate us on Play Store',
              onTap: () {
                // Open play store rating
              },
              showArrow: true,
            ),

            const SizedBox(height: 16),

            // Legal Section
            _buildSectionHeader('Legal'),
            _buildSettingsTile(
              icon:
                  Icons.privacy_tip_outlined, // Fixed: was privacy_tip_outline
              title: 'Privacy Policy',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.privacyPolicy);
              },
              showArrow: true,
            ),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {
                // Navigate to terms of service
              },
              showArrow: true,
            ),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.about);
              },
              showArrow: true,
            ),

            const SizedBox(height: 16),

            // Data Section
            _buildSectionHeader('Data'),
            _buildSettingsTile(
              icon: Icons.storage_outlined,
              title: 'Clear Cache',
              subtitle: 'Clear app cache and temporary data',
              onTap: () {
                _showClearCacheDialog();
              },
              showArrow: true,
            ),
            _buildSettingsTile(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              onTap: () {
                _showDeleteAccountDialog();
              },
              showArrow: true,
              textColor: Colors.red,
            ),

            const SizedBox(height: 30),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool showArrow = false,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: showArrow
          ? const Icon(Icons.chevron_right, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    final languages = [
      'English',
      'Spanish',
      'French',
      'German',
      'Hindi',
      'Arabic'
    ];

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
                    leading:
                        const Icon(Icons.language, color: AppColors.primary),
                    title: Text(language),
                    trailing: language == _selectedLanguage
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language;
                      });
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

  void _showCurrencyDialog() {
    final currencies = [
      'USD (\$)',
      'EUR (€)',
      'GBP (£)',
      'INR (₹)',
      'CAD (\$)',
      'AUD (\$)'
    ];

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
                'Select Currency',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...currencies.map((currency) => ListTile(
                    leading: const Icon(Icons.attach_money,
                        color: AppColors.primary),
                    title: Text(currency),
                    trailing: currency == _selectedCurrency
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCurrency = currency;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Currency changed to $currency'),
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

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('We value your feedback! Please share your thoughts.'),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  hintText: 'Your feedback...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
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
                if (feedbackController.text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your feedback!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text(
              'This will clear temporary files and cached data. Your personal information will not be affected.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Warning: This action is permanent and cannot be undone. All your data will be deleted.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  hintText: 'Enter your password to confirm',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
                if (passwordController.text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // Navigate to login
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
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
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
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
}
