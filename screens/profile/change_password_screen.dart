import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/colors.dart';
import '../../utils/validators.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.changePassword(
        oldPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current password is incorrect'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Password must be at least 6 characters long and contain at least one number',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Current Password
              CustomTextField(
                controller: _currentPasswordController,
                hintText: "Current Password",
                labelText: "Current Password",
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureCurrent,
                suffixIcon: _obscureCurrent
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixIconTap: () {
                  setState(() {
                    _obscureCurrent = !_obscureCurrent;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current password';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // New Password
              CustomTextField(
                controller: _newPasswordController,
                hintText: "New Password",
                labelText: "New Password",
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureNew,
                suffixIcon: _obscureNew
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixIconTap: () {
                  setState(() {
                    _obscureNew = !_obscureNew;
                  });
                },
                validator: Validators.validatePassword,
              ),
              
              const SizedBox(height: 20),
              
              // Confirm Password
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: "Confirm New Password",
                labelText: "Confirm New Password",
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirm,
                suffixIcon: _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixIconTap: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 30),
              
              // Password Strength Indicator
              if (_newPasswordController.text.isNotEmpty)
                _buildPasswordStrength(_newPasswordController.text),
              
              const SizedBox(height: 30),
              
              // Update Button
              CustomButton(
                text: "Update Password",
                onPressed: _changePassword,
                backgroundColor: AppColors.primary,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength(String password) {
    int strength = _calculatePasswordStrength(password);
    String strengthText;
    Color strengthColor;
    
    if (strength < 2) {
      strengthText = 'Weak';
      strengthColor = Colors.red;
    } else if (strength < 4) {
      strengthText = 'Medium';
      strengthColor = Colors.orange;
    } else {
      strengthText = 'Strong';
      strengthColor = Colors.green;
    }
    
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Password Strength: ',
              style: TextStyle(fontSize: 13),
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: strength / 5,
          backgroundColor: Colors.grey.shade200,
          color: strengthColor,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}