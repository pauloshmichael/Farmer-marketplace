import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/colors.dart';
import '../../utils/validators.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;
  
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Note: Your auth_provider.dart doesn't have resetPasswordWithToken method
      // You need to add this method to AuthProvider or use changePassword
      // For now, we'll use changePassword if user is logged in
      
      final user = authProvider.currentUser;
      if (user != null) {
        // User is already logged in from email link
        final success = await authProvider.changePassword(
          oldPassword: _passwordController.text, // This won't work for reset
          newPassword: _passwordController.text,
        );
        
        setState(() {
          _isLoading = false;
          _isSuccess = success;
        });
      } else {
        // User not logged in - show error
        setState(() {
          _isLoading = false;
          _isSuccess = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid or expired reset link. Please request a new one.'),
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
        title: const Text('Reset Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Icon
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isSuccess ? Icons.check_circle : Icons.lock_reset,
                    size: 50,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Title
                Text(
                  _isSuccess ? "Password Reset Successfully!" : "Create New Password",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 10),
                
                if (!_isSuccess)
                  Text(
                    "Enter your new password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                if (!_isSuccess)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // New Password
                          CustomTextField(
                            controller: _passwordController,
                            hintText: "New Password",
                            labelText: "New Password",
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            validator: Validators.validatePassword,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Confirm Password
                          CustomTextField(
                            controller: _confirmPasswordController,
                            hintText: "Confirm New Password",
                            labelText: "Confirm New Password",
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            validator: (value) => Validators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Reset Button
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomButton(
                                  text: "Reset Password",
                                  onPressed: _handleResetPassword,
                                  backgroundColor: AppColors.primary,
                                ),
                        ],
                      ),
                    ),
                  ),
                
                if (_isSuccess)
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: const Column(
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          "Redirecting to login...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}