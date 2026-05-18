class AppConfig {
  // App Information
  static const String appName = 'Farmer Marketplace';
  static const String appVersion = '1.0.0';
  static const String appBuild = '1';
  static const String packageName = 'com.farmer.marketplace';
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableChat = true;
  static const bool enableReviews = true;
  static const bool enableWishlist = true;
  static const bool enableLocationTracking = true;
  static const bool enableSocialLogin = true;
  
  // Limits
  static const int maxCartItems = 50;
  static const int maxWishlistItems = 100;
  static const int maxProductImages = 10;
  static const int maxImageSizeMB = 5;
  static const int maxSearchHistory = 20;
  static const int productsPerPage = 20;
  static const int reviewsPerPage = 10;
  static const int messagesPerPage = 50;
  
  // Cache Duration (in seconds)
  static const int productsCacheDuration = 300; // 5 minutes
  static const int categoriesCacheDuration = 3600; // 1 hour
  static const int userProfileCacheDuration = 1800; // 30 minutes
  
  // Minimum App Version Required
  static const int minimumAndroidVersion = 21; // Android 5.0
  static const int minimumiOSVersion = 12; // iOS 12.0
  
  // Support Email
  static const String supportEmail = 'support@farmermarketplace.com';
  static const String supportPhone = '+1-800-123-4567';
  
  // Social Media Links
  static const String facebookUrl = 'https://facebook.com/farmer-marketplace';
  static const String twitterUrl = 'https://twitter.com/farmer-marketplace';
  static const String instagramUrl = 'https://instagram.com/farmer-marketplace';
  static const String websiteUrl = 'https://farmermarketplace.com';
  
  // Privacy & Policy URLs
  static const String privacyPolicyUrl = 'https://farmermarketplace.com/privacy';
  static const String termsOfServiceUrl = 'https://farmermarketplace.com/terms';
  
  // Image Placeholders
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String userAvatarPlaceholder = 'assets/images/user_avatar.png';
  static const String productImagePlaceholder = 'assets/images/product_placeholder.png';
  
  // Currency & Units
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';
  static const String distanceUnit = 'km';
  static const String weightUnit = 'kg';
  
  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxAddressLength = 200;
  
  // Delivery Settings
  static const double standardDeliveryFee = 5.0;
  static const double freeDeliveryThreshold = 50.0;
  static const int estimatedDeliveryDays = 3;
  static const int maxDeliveryRadius = 50; // in km
  
  // Tax Settings
  static const double taxRate = 0.08; // 8%
  
  // Commission Settings
  static const double farmerCommissionRate = 0.10; // 10%
  static const double cooperativeCommissionRate = 0.05; // 5%
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isLoggedIn = 'is_logged_in';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String lastSyncTime = 'last_sync_time';
  static const String notificationSettings = 'notification_settings';
  static const String deliveryAddress = 'delivery_address';
  static const String defaultPaymentMethod = 'default_payment_method';
  static const String searchHistory = 'search_history';
  static const String recentlyViewed = 'recently_viewed';
}