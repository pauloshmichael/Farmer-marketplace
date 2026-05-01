import 'package:flutter/material.dart';

class AppConstants {
  // Categories
  static const List<String> categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Meat',
    'Organic',
    'Seeds',
    'Equipment',
  ];

  // Category Icons Mapping
  static const Map<String, IconData> categoryIcons = {
    'All': Icons.apps,
    'Vegetables': Icons.eco,
    'Fruits': Icons.apple,
    'Grains': Icons.grass,
    'Dairy': Icons.emoji_food_beverage,
    'Meat': Icons.restaurant,
    'Organic': Icons.spa,
    'Seeds': Icons.nature,
    'Equipment': Icons.build,
  };

  // Get category icon - FIXED METHOD
  static IconData getCategoryIcon(String category) {
    return categoryIcons[category] ?? Icons.category;
  }

  // Other constants remain the same...
  static const String appName = 'Farmer Marketplace';
  static const String appVersion = '1.0.0';
  
  // API Keys
  static const String mapBoxToken = 'YOUR_MAPBOX_TOKEN';
  static const String razorpayKey = 'YOUR_RAZORPAY_KEY';
  
  // Shared Preferences Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  
  // Order Status
  static const List<String> orderStatus = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];
  
  // Order Status Colors
  static const Map<String, int> orderStatusColors = {
    'pending': 0xFFFFA000,
    'confirmed': 0xFF2196F3,
    'processing': 0xFF9C27B0,
    'shipped': 0xFF00BCD4,
    'delivered': 0xFF4CAF50,
    'cancelled': 0xFFF44336,
  };
  
  // Payment Methods
  static const List<String> paymentMethods = [
    'Credit Card',
    'Debit Card',
    'UPI',
    'Net Banking',
    'Cash on Delivery',
  ];
  
  // Product Units
  static const List<String> productUnits = [
    'kg',
    'g',
    'lb',
    'piece',
    'dozen',
    'bundle',
    'basket',
    'bag',
  ];
}