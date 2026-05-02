import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/cooperative_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/theme_provider.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run with splash screen while initializing
    try {
    // Add timeout for Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    print('✅ Firebase initialized');
  } catch (e) {
    print('❌ Firebase error: $e');
  }
  runApp(const InitializationWrapper());
}

class InitializationWrapper extends StatefulWidget {
  const InitializationWrapper({super.key});

  @override
  State<InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> {
  bool _isInitialized = false;
  String _initStatus = 'Initializing...';
  double _initProgress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize Firebase (20%)
      setState(() {
        _initStatus = 'Connecting to Firebase...';
        _initProgress = 0.2;
      });
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Step 2: Initialize Local Storage (40%)
      setState(() {
        _initStatus = 'Loading local storage...';
        _initProgress = 0.4;
      });
      await LocalStorageService().initialize();
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Step 3: Initialize Notifications (60%)
      setState(() {
        _initStatus = 'Setting up notifications...';
        _initProgress = 0.6;
      });
      await NotificationService().initialize();
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Step 4: Load user session (80%)
      setState(() {
        _initStatus = 'Loading user session...';
        _initProgress = 0.8;
      });
      await Future.delayed(const Duration(milliseconds: 30));
      
      // Step 5: Preload data (100%)
      setState(() {
        _initStatus = 'Almost ready...';
        _initProgress = 1.0;
      });
      await Future.delayed(const Duration(milliseconds: 30));
      
      // All initialized successfully
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      debugPrint('Initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorScreen();
    }
    
    if (!_isInitialized) {
      return _buildSplashScreen();
    }
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CooperativeProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const App(),
    );
  }

  Widget _buildSplashScreen() {
    return MaterialApp(
      title: 'Farmer Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF43A047),
                Color(0xFF66BB6A),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App Name
                  const Text(
                    'Farmer Marketplace',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Tagline
                  Text(
                    'Connecting Farmers & Buyers',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Progress Indicator
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _initProgress,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 4,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _initStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
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

  Widget _buildErrorScreen() {
    return MaterialApp(
      title: 'Farmer Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          error: AppColors.error,
        ),
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _errorMessage ?? 'Unknown error occurred',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _initStatus = 'Initializing...';
                      _initProgress = 0.0;
                      _isInitialized = false;
                    });
                    _initializeApp();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () {
                    // Exit app
                  },
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Exit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}