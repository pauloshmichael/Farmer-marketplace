import 'dart:async';
import 'package:intl/intl.dart';

class AppHelpers {
  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return formatDate(dateTime);
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Currency Formatting
  static String formatCurrency(double amount, {String currencySymbol = '\$'}) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // String Helpers
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Validation Helpers
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  // Image Helpers
  static String getPlaceholderImage(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return 'https://via.placeholder.com/400x300?text=Vegetables';
      case 'fruits':
        return 'https://via.placeholder.com/400x300?text=Fruits';
      case 'dairy':
        return 'https://via.placeholder.com/400x300?text=Dairy';
      default:
        return 'https://via.placeholder.com/400x300?text=Product';
    }
  }

  // Rating Helpers
  static double calculateAverageRating(List<double> ratings) {
    if (ratings.isEmpty) return 0.0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  // Discount Calculation
  static double calculateDiscountedPrice(
      double originalPrice, double discountPercent) {
    return originalPrice - (originalPrice * discountPercent / 100);
  }

  static double calculateDiscountAmount(
      double originalPrice, double discountedPrice) {
    return originalPrice - discountedPrice;
  }

  static double calculateDiscountPercent(
      double originalPrice, double discountedPrice) {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - discountedPrice) / originalPrice) * 100;
  }

  // Distance Formatting
  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  // Generate Random ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Extract Initials
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final names = name.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  // Mask String
  static String maskString(String text, int visibleStart, int visibleEnd) {
    if (text.length <= visibleStart + visibleEnd) return text;
    final start = text.substring(0, visibleStart);
    final end = text.substring(text.length - visibleEnd);
    final maskedLength = text.length - visibleStart - visibleEnd;
    return '$start${'*' * maskedLength}$end';
  }

  // Mask Card Number
  static String maskCardNumber(String cardNumber) {
    if (cardNumber.length < 16) return cardNumber;
    return '•••• •••• •••• ${cardNumber.substring(cardNumber.length - 4)}';
  }

  // Parse and Format JSON
  static Map<String, dynamic> safeJsonParse(dynamic json) {
    try {
      if (json is Map<String, dynamic>) return json;
      if (json is String) {
        return {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Debounce Function
  static Function debounce(Function func, Duration duration) {
    Timer? timer;
    return () {
      if (timer?.isActive ?? false) timer!.cancel();
      timer = Timer(duration, () => func());
    };
  }
}
