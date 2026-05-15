import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  List<OrderModel> _farmerOrders = [];
  List<OrderModel> _cooperativeOrders = [];
  OrderModel? _currentOrder;
  bool _isLoading = false;
  String? _errorMessage;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  List<OrderModel> get orders => _orders;
  List<OrderModel> get farmerOrders => _farmerOrders;
  List<OrderModel> get cooperativeOrders => _cooperativeOrders;
  OrderModel? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create notification helper
  Future<void> _createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Notification created for user: $userId');
    } catch (e) {
      print('❌ Error creating notification: $e');
    }
  }

  // CREATE NEW ORDER with farmer reference
  Future<OrderModel?> createOrder({
    required List<CartItem> items,
    required ShippingAddress shippingAddress,
    required String paymentMethod,
    required double subtotal,
    required double deliveryFee,
    required double tax,
    required double discount,
    required double total,
    required String userId,
    required String farmerId,
    required String farmerName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final orderItems = items.map((item) => OrderItem(
        productId: item.productId,
        productName: item.name,
        productImage: item.image,
        price: item.price,
        quantity: item.quantity,
        total: item.total,
        farmerId: item.farmerId,
        farmerName: item.farmerName,
      )).toList();

      final newOrder = OrderModel(
        id: 'ORD_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        farmerId: farmerId,
        farmerName: farmerName,
        items: orderItems,
        subtotal: subtotal,
        shippingFee: deliveryFee,
        tax: tax,
        discount: discount,
        total: total,
        status: 'pending',
        paymentMethod: paymentMethod,
        paymentStatus: 'pending',
        shippingAddress: shippingAddress,
        orderDate: DateTime.now(),
      );

      // Save to Firestore
      await _firestore.collection('orders').doc(newOrder.id).set(newOrder.toJson());
      print('✅ Order saved to Firestore: ${newOrder.id}');
      
      // Notify farmer about new order
      await _createNotification(
        userId: farmerId,
        title: 'New Order Received! 🎉',
        body: 'You have received a new order #${newOrder.id.substring(0, 8)} for \$${total.toStringAsFixed(2)}',
        type: 'order',
        data: {'orderId': newOrder.id},
      );
      
      // Notify buyer about order confirmation
      await _createNotification(
        userId: userId,
        title: 'Order Placed Successfully! ✅',
        body: 'Your order #${newOrder.id.substring(0, 8)} has been placed successfully.',
        type: 'order',
        data: {'orderId': newOrder.id},
      );
      
      _orders.insert(0, newOrder);
      _isLoading = false;
      notifyListeners();
      return newOrder;
      
    } catch (e) {
      print('❌ Error creating order: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Fetch buyer orders from Firestore
  Future<void> fetchOrders({String? userId}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .get();

      _orders = snapshot.docs.map((doc) {
        return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      
      print('✅ Fetched ${_orders.length} orders for user: $userId');
      _errorMessage = null;
    } catch (e) {
      print('❌ Error fetching orders: $e');
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Fetch farmer orders from Firestore
  Future<void> fetchFarmerOrders({String? farmerId}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('orderDate', descending: true)
          .get();

      _farmerOrders = snapshot.docs.map((doc) {
        return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      
      print('✅ Fetched ${_farmerOrders.length} orders for farmer: $farmerId');
      _errorMessage = null;
    } catch (e) {
      print('❌ Error fetching farmer orders: $e');
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Fetch cooperative orders from Firestore
  Future<void> fetchCooperativeOrders({String? cooperativeId}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('cooperativeId', isEqualTo: cooperativeId)
          .orderBy('orderDate', descending: true)
          .get();

      _cooperativeOrders = snapshot.docs.map((doc) {
        return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      
      print('✅ Fetched ${_cooperativeOrders.length} orders for cooperative: $cooperativeId');
      _errorMessage = null;
    } catch (e) {
      print('❌ Error fetching cooperative orders: $e');
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Fetch single order details
  Future<void> fetchOrderDetails(String orderId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      DocumentSnapshot doc = await _firestore.collection('orders').doc(orderId).get();
      
      if (doc.exists) {
        _currentOrder = OrderModel.fromJson(doc.data() as Map<String, dynamic>);
        print('✅ Fetched order details for: $orderId');
      } else {
        print('⚠️ Order not found: $orderId');
      }
      
      _errorMessage = null;
    } catch (e) {
      print('❌ Error fetching order details: $e');
      _errorMessage = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Update order status (for farmers)
  Future<bool> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Order status updated: $orderId -> $status');
      
      // Get order to get user ID for notification
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      final orderData = orderDoc.data() as Map<String, dynamic>;
      
      // Notify buyer about status update
      await _createNotification(
        userId: orderData['userId'],
        title: 'Order Status Updated',
        body: 'Your order #${orderId.substring(0, 8)} is now ${status.toUpperCase()}',
        type: 'order',
        data: {'orderId': orderId},
      );
      
      // Refresh local lists
      if (orderData['farmerId'] != null) {
        await fetchFarmerOrders(farmerId: orderData['farmerId']);
      }
      await fetchOrders(userId: orderData['userId']);
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      print('❌ Error updating order status: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel order (for buyers)
  Future<bool> cancelOrder(String orderId, String userId, String farmerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Order cancelled: $orderId');
      
      // Notify farmer about cancellation
      await _createNotification(
        userId: farmerId,
        title: 'Order Cancelled',
        body: 'An order has been cancelled by the buyer',
        type: 'order',
        data: {'orderId': orderId},
      );
      
      // Notify buyer about cancellation
      await _createNotification(
        userId: userId,
        title: 'Order Cancelled',
        body: 'Your order has been cancelled successfully',
        type: 'order',
        data: {'orderId': orderId},
      );
      
      await fetchOrders(userId: userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      print('❌ Error cancelling order: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Real-time stream for farmer orders
  Stream<QuerySnapshot> streamFarmerOrders(String farmerId) {
    return _firestore
        .collection('orders')
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  // Real-time stream for buyer orders
  Stream<QuerySnapshot> streamBuyerOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  // Get order by ID from Firestore directly
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        print('✅ Found order: $orderId');
        return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      print('⚠️ Order not found: $orderId');
      return null;
    } catch (e) {
      print('❌ Error getting order: $e');
      return null;
    }
  }

  // Get orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  // Get pending orders count for farmer
  int getPendingOrdersCount(String farmerId) {
    return _farmerOrders.where((order) => order.status == 'pending').length;
  }

  // Get confirmed orders count for farmer
  int getConfirmedOrdersCount(String farmerId) {
    return _farmerOrders.where((order) => order.status == 'confirmed').length;
  }

  // Get shipped orders count for farmer
  int getShippedOrdersCount(String farmerId) {
    return _farmerOrders.where((order) => order.status == 'shipped').length;
  }

  // Get delivered orders count for farmer
  int getDeliveredOrdersCount(String farmerId) {
    return _farmerOrders.where((order) => order.status == 'delivered').length;
  }

  // Get cancelled orders count for farmer
  int getCancelledOrdersCount(String farmerId) {
    return _farmerOrders.where((order) => order.status == 'cancelled').length;
  }

  // Get completed orders count for farmer
  int getCompletedOrdersCount(String farmerId) {
    return _farmerOrders.where((order) => order.status == 'delivered').length;
  }

  // Get total revenue for farmer
  double getTotalRevenue(String farmerId) {
    return _farmerOrders
        .where((order) => order.status == 'delivered')
        .fold<double>(0, (sum, order) => sum + order.total);
  }

  // Get total orders value for farmer
  double getTotalOrdersValue(String farmerId) {
    return _farmerOrders.fold<double>(0, (sum, order) => sum + order.total);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset provider (for logout)
  void reset() {
    _orders = [];
    _farmerOrders = [];
    _cooperativeOrders = [];
    _currentOrder = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}