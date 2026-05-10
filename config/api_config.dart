class ApiConfig {
  // Base URLs
  static const String baseUrl = 'https://api.farmermarketplace.com/v1';
  static const String stagingBaseUrl = 'https://staging-api.farmermarketplace.com/v1';
  static const String localBaseUrl = 'http://10.0.2.2:3000/v1'; // For Android Emulator
  
  // API Keys
  static const String razorpayKey = 'rzp_test_YourRazorpayKeyHere'; // Replace with your actual Razorpay key
  static const String mapBoxToken = 'pk.your_mapbox_token_here'; // Replace with your Mapbox token
  static const String googleMapsKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // Replace with your Google Maps key
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Auth Headers
  static Map<String, String> authHeaders(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
  
  // API Version
  static const String apiVersion = 'v1';
  
  // Environment
  static const bool isProduction = false;
  static const bool isStaging = true;
  static const bool isDevelopment = true;
  
  static String getCurrentBaseUrl() {
    if (isProduction) return baseUrl;
    if (isStaging) return stagingBaseUrl;
    return localBaseUrl;
  }
}

class AuthEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String changePassword = '/auth/change-password';
  static const String socialLogin = '/auth/social-login';
}

class ProductEndpoints {
  static const String products = '/products';
  static const String productDetails = '/products/';
  static const String addProduct = '/products/add';
  static const String updateProduct = '/products/update/';
  static const String deleteProduct = '/products/delete/';
  static const String farmerProducts = '/products/farmer';
  static const String featuredProducts = '/products/featured';
  static const String popularProducts = '/products/popular';
  static const String searchProducts = '/products/search';
  static const String filterProducts = '/products/filter';
  static const String categories = '/products/categories';
  static const String productReviews = '/products/reviews/';
  static const String addReview = '/products/reviews/add';
}

class OrderEndpoints {
  static const String orders = '/orders';
  static const String orderDetails = '/orders/';
  static const String createOrder = '/orders/create';
  static const String updateOrderStatus = '/orders/status/';
  static const String cancelOrder = '/orders/cancel/';
  static const String trackOrder = '/orders/track/';
  static const String orderHistory = '/orders/history';
  static const String farmerOrders = '/orders/farmer';
  static const String cooperativeOrders = '/orders/cooperative';
  static const String invoice = '/orders/invoice/';
}

class CartEndpoints {
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String removeFromCart = '/cart/remove/';
  static const String updateCart = '/cart/update';
  static const String clearCart = '/cart/clear';
  static const String applyCoupon = '/cart/coupon';
}

class UserEndpoints {
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String uploadAvatar = '/user/avatar';
  static const String deleteAccount = '/user/delete';
  static const String addresses = '/user/addresses';
  static const String addAddress = '/user/addresses/add';
  static const String updateAddress = '/user/addresses/update/';
  static const String deleteAddress = '/user/addresses/delete/';
  static const String paymentMethods = '/user/payment-methods';
  static const String addPaymentMethod = '/user/payment-methods/add';
  static const String deletePaymentMethod = '/user/payment-methods/delete/';
}

class ChatEndpoints {
  static const String conversations = '/chat/conversations';
  static const String messages = '/chat/messages/';
  static const String sendMessage = '/chat/send';
  static const String markAsRead = '/chat/read/';
  static const String deleteMessage = '/chat/delete/';
  static const String deleteConversation = '/chat/conversation/';
  static const String typing = '/chat/typing';
  static const String online = '/chat/online';
}

class PaymentEndpoints {
  static const String createPayment = '/payment/create';
  static const String verifyPayment = '/payment/verify';
  static const String paymentHistory = '/payment/history';
  static const String paymentDetails = '/payment/';
  static const String refund = '/payment/refund/';
  static const String webhook = '/payment/webhook';
}

class NotificationEndpoints {
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/read/';
  static const String markAllAsRead = '/notifications/read-all';
  static const String deleteNotification = '/notifications/delete/';
  static const String settings = '/notifications/settings';
  static const String updateSettings = '/notifications/settings/update';
}

class CooperativeEndpoints {
  static const String cooperatives = '/cooperatives';
  static const String cooperativeDetails = '/cooperatives/';
  static const String members = '/cooperatives/members/';
  static const String join = '/cooperatives/join';
  static const String leave = '/cooperatives/leave';
  static const String applications = '/cooperatives/applications';
  static const String approveMember = '/cooperatives/approve/';
  static const String rejectMember = '/cooperatives/reject/';
  static const String products = '/cooperatives/products/';
  static const String addProduct = '/cooperatives/products/add';
  static const String statistics = '/cooperatives/statistics/';
}

class LocationEndpoints {
  static const String nearbyFarmers = '/location/nearby-farmers';
  static const String nearbyCooperatives = '/location/nearby-cooperatives';
  static const String deliveryZones = '/location/delivery-zones';
  static const String calculateDistance = '/location/distance';
  static const String reverseGeocode = '/location/reverse-geocode';
}