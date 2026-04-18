import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../services/local_storage_service.dart';

class SplashScreenAnimated extends StatefulWidget {
  const SplashScreenAnimated({super.key});

  @override
  State<SplashScreenAnimated> createState() => _SplashScreenAnimatedState();
}

class _SplashScreenAnimatedState extends State<SplashScreenAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  
  final LocalStorageService _storage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateToNext();
  }

  void _initAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _controller.forward();
  }

  Future<void> _navigateToNext() async {
    await _storage.initialize();
    
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final token = _storage.getAuthToken();
    final user = _storage.getCurrentUser();
    
    String route;
    if (token != null && user != null) {
      switch (user['role']) {
        case 'farmer':
          route = AppRoutes.farmerDashboard;
          break;
        case 'cooperative':
          route = AppRoutes.cooperativeDashboard;
          break;
        default:
          route = AppRoutes.buyerDashboard;
      }
    } else {
      route = AppRoutes.login;
    }
    
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie Animation (if you have Lottie files)
                  // You can add Lottie.asset('assets/animations/farming.json')
                  Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Farmer Marketplace",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Fresh from farm to table",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 60),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
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