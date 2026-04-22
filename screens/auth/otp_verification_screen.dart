import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../app/routes.dart';
import '../../widgets/custom_button.dart';
import '../../utils/colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String purpose; // 'registration', 'reset_password'

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.purpose = 'registration',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isResendEnabled = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else if (mounted) {
        setState(() {
          _isResendEnabled = true;
        });
      }
    });
  }

  Future<void> _handleVerify() async {
    if (_pinController.text.length == 6) {
      setState(() {
        _isLoading = true;
      });

      // Simulate OTP verification
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (widget.purpose == 'registration') {
          // Navigate to complete registration or login
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else {
          // Navigate to reset password screen
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.resetPassword,
            arguments: {'email': widget.email},
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF66BB6A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

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
                    child: const Icon(
                      Icons.verified_user,
                      size: 50,
                      color: Color(0xFF2E7D32),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Title
                  const Text(
                    "Verify Your Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Description
                  Text(
                    "We've sent a verification code to",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // OTP Input
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
                    child: Column(
                      children: [
                        Pinput(
                          controller: _pinController,
                          length: 6,
                          showCursor: true,
                          onCompleted: (pin) => _handleVerify(),
                          defaultPinTheme: PinTheme(
                            width: 50,
                            height: 50,
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 50,
                            height: 50,
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.primary, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Verify Button
                        _isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(
                                text: "Verify",
                                onPressed: _handleVerify,
                                backgroundColor: AppColors.primary,
                              ),

                        const SizedBox(height: 16),

                        // Resend Section
                        if (_isResendEnabled)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _countdown = 60;
                                _isResendEnabled = false;
                              });
                              _startCountdown();
                              // Resend OTP logic here
                            },
                            child: const Text(
                              "Resend Code",
                              style: TextStyle(color: AppColors.primary),
                            ),
                          )
                        else
                          Text(
                            "Resend code in ${_countdown}s",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
