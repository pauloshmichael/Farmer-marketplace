import 'package:flutter/animation.dart';

class RouteConfig {
  // Transition Durations
  static const Duration transitionDuration = Duration(milliseconds: 300);

  // Route Guards
  static const List<String> authRequiredRoutes = [
    '/cart',
    '/orders',
    '/profile',
    '/chat',
    '/payment',
    '/wishlist',
    '/checkout',
  ];

  static const List<String> farmerOnlyRoutes = [
    '/farmer-dashboard',
    '/add-product',
    '/edit-product',
    '/my-products',
    '/farmer-orders',
  ];

  static const List<String> cooperativeOnlyRoutes = [
    '/cooperative-dashboard',
    '/cooperative-members',
    '/cooperative-products',
    '/cooperative-profile',
  ];

  static const List<String> buyerOnlyRoutes = [
    '/buyer-dashboard',
    '/cart',
    '/wishlist',
    '/buyer-orders',
  ];

  // Deep Links
  static const Map<String, String> deepLinks = {
    'product': '/product-detail',
    'order': '/order-detail',
    'chat': '/chat-detail',
    'cooperative': '/cooperative-dashboard',
    'farmer': '/farmer-dashboard',
  };

  // Bottom Navigation Routes
  static const Map<String, int> bottomNavRoutes = {
    '/home': 0,
    '/search': 1,
    '/cart': 2,
    '/orders': 3,
    '/profile': 4,
  };

  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve slideCurve = Curves.easeOutCubic;
  static const Curve scaleCurve = Curves.easeOutBack;
}
