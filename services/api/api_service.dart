import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  void clearAuthToken() {
    _authToken = null;
  }
  
  Map<String, String> get _headers {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ==================== AUTH ENDPOINTS ====================
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.login}'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.register}'),
        headers: _headers,
        body: json.encode(userData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.forgotPassword}'),
        headers: _headers,
        body: json.encode({'email': email}),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.resetPassword}'),
        headers: _headers,
        body: json.encode({
          'token': token,
          'password': newPassword,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.changePassword}'),
        headers: _headers,
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${AuthEndpoints.logout}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // ==================== PRODUCT ENDPOINTS ====================
  
  Future<Map<String, dynamic>> getProducts({
    String? category,
    String? farmerId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (category != null && category != 'All') {
        queryParams['category'] = category;
      }
      if (farmerId != null) {
        queryParams['farmer_id'] = farmerId;
      }
      
      final uri = Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.products}')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.productDetails}$productId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.addProduct}'),
        headers: _headers,
        body: json.encode(productData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.updateProduct}$productId'),
        headers: _headers,
        body: json.encode(productData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.deleteProduct}$productId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getFarmerProducts(String farmerId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.farmerProducts}?farmer_id=$farmerId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.searchProducts}?q=$query'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getFeaturedProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.featuredProducts}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getPopularProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.popularProducts}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.categories}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> addProductReview(String productId, Map<String, dynamic> reviewData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.addReview}'),
        headers: _headers,
        body: json.encode({
          'product_id': productId,
          ...reviewData,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getProductReviews(String productId, {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ProductEndpoints.productReviews}$productId?page=$page&limit=$limit'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // ==================== ORDER ENDPOINTS ====================
  
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${OrderEndpoints.createOrder}'),
        headers: _headers,
        body: json.encode(orderData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getOrders({int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${OrderEndpoints.orders}?page=$page&limit=$limit'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${OrderEndpoints.orderDetails}$orderId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${OrderEndpoints.cancelOrder}$orderId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${OrderEndpoints.trackOrder}$orderId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getFarmerOrders({int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${OrderEndpoints.farmerOrders}?page=$page&limit=$limit'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${OrderEndpoints.updateOrderStatus}$orderId'),
        headers: _headers,
        body: json.encode({'status': status}),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // ==================== CART ENDPOINTS ====================
  
  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CartEndpoints.cart}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> addToCart(Map<String, dynamic> cartData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CartEndpoints.addToCart}'),
        headers: _headers,
        body: json.encode(cartData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateCartItem(String productId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CartEndpoints.updateCart}'),
        headers: _headers,
        body: json.encode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> removeFromCart(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CartEndpoints.removeFromCart}$productId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CartEndpoints.clearCart}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> applyCoupon(String couponCode) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CartEndpoints.applyCoupon}'),
        headers: _headers,
        body: json.encode({'coupon_code': couponCode}),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // ==================== USER ENDPOINTS ====================
  
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${UserEndpoints.profile}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${UserEndpoints.updateProfile}'),
        headers: _headers,
        body: json.encode(profileData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> uploadAvatar(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${UserEndpoints.uploadAvatar}'),
        headers: _headers,
        body: json.encode({'avatar_url': imageUrl}),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getAddresses() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${UserEndpoints.addresses}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> addressData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${UserEndpoints.addAddress}'),
        headers: _headers,
        body: json.encode(addressData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateAddress(String addressId, Map<String, dynamic> addressData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${UserEndpoints.updateAddress}$addressId'),
        headers: _headers,
        body: json.encode(addressData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${UserEndpoints.deleteAddress}$addressId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${UserEndpoints.paymentMethods}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // ==================== CHAT ENDPOINTS ====================
  
  Future<Map<String, dynamic>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ChatEndpoints.conversations}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getMessages(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ChatEndpoints.messages}$conversationId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> messageData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ChatEndpoints.sendMessage}'),
        headers: _headers,
        body: json.encode(messageData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> markChatAsRead(String conversationId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${ChatEndpoints.markAsRead}$conversationId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // ==================== PAYMENT ENDPOINTS ====================
  
  Future<Map<String, dynamic>> createPaymentOrder(Map<String, dynamic> paymentData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${PaymentEndpoints.createPayment}'),
        headers: _headers,
        body: json.encode(paymentData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> verificationData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${PaymentEndpoints.verifyPayment}'),
        headers: _headers,
        body: json.encode(verificationData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getPaymentHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${PaymentEndpoints.paymentHistory}?page=$page&limit=$limit'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // ==================== NOTIFICATION ENDPOINTS ====================
  
  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${NotificationEndpoints.notifications}?page=$page&limit=$limit'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${NotificationEndpoints.markAsRead}$notificationId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${NotificationEndpoints.markAllAsRead}'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // ==================== COOPERATIVE ENDPOINTS ====================
  
  Future<Map<String, dynamic>> getCooperatives({int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CooperativeEndpoints.cooperatives}?page=$page&limit=$limit'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getCooperativeDetails(String cooperativeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CooperativeEndpoints.cooperativeDetails}$cooperativeId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> joinCooperative(String cooperativeId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CooperativeEndpoints.join}'),
        headers: _headers,
        body: json.encode({'cooperative_id': cooperativeId}),
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getCooperativeMembers(String cooperativeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CooperativeEndpoints.members}$cooperativeId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getCooperativeProducts(String cooperativeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentBaseUrl()}${CooperativeEndpoints.products}$cooperativeId'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // ==================== HELPER METHODS ====================
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'data': data,
      };
    } else {
      final error = json.decode(response.body);
      return {
        'success': false,
        'error': error['message'] ?? 'Request failed with status: ${response.statusCode}',
      };
    }
  }
  
  Map<String, dynamic> _handleError(dynamic error) {
    return {
      'success': false,
      'error': error.toString(),
    };
  }
}