import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;
  String? get errorMessage => _errorMessage;

  NotificationProvider() {
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    _notifications = [
      NotificationModel(
        id: '1',
        userId: 'currentUser',
        title: 'Order Delivered',
        body: 'Your order #ORD001 has been delivered successfully!',
        type: 'order',
        data: {'orderId': 'ORD001'},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '2',
        userId: 'currentUser',
        title: 'Special Offer',
        body: 'Get 20% off on all organic vegetables this week!',
        type: 'promotion',
        data: {'discount': '20'},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        imageUrl: 'https://via.placeholder.com/100',
      ),
      NotificationModel(
        id: '3',
        userId: 'currentUser',
        title: 'Payment Received',
        body: 'Your payment of \$51.99 has been received.',
        type: 'payment',
        data: {'amount': '51.99'},
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '4',
        userId: 'currentUser',
        title: 'New Message',
        body: 'You have a new message from Green Valley Farm',
        type: 'message',
        data: {'senderId': 'farmer1', 'senderName': 'Green Valley Farm'},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      NotificationModel(
        id: '5',
        userId: 'currentUser',
        title: 'Order Shipped',
        body: 'Your order #ORD002 has been shipped!',
        type: 'order',
        data: {'orderId': 'ORD002'},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: '6',
        userId: 'currentUser',
        title: 'Welcome to Farmer Marketplace!',
        body: 'Thank you for joining our community. Start exploring fresh products!',
        type: 'general',
        data: {},
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
    
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // Fetch notifications - FIXED METHOD
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    _isLoading = false;
    notifyListeners();
  }

  // Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        body: _notifications[index].body,
        type: _notifications[index].type,
        data: _notifications[index].data,
        isRead: true,
        createdAt: _notifications[index].createdAt,
        imageUrl: _notifications[index].imageUrl,
      );
      _updateUnreadCount();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = NotificationModel(
        id: _notifications[i].id,
        userId: _notifications[i].userId,
        title: _notifications[i].title,
        body: _notifications[i].body,
        type: _notifications[i].type,
        data: _notifications[i].data,
        isRead: true,
        createdAt: _notifications[i].createdAt,
        imageUrl: _notifications[i].imageUrl,
      );
    }
    _unreadCount = 0;
    
    _isLoading = false;
    notifyListeners();
  }

  // Delete a single notification
  Future<void> deleteNotification(String notificationId) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    
    _isLoading = false;
    notifyListeners();
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _notifications.clear();
    _unreadCount = 0;
    
    _isLoading = false;
    notifyListeners();
  }

  // Add a new notification (for real-time updates)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    if (type == 'all') {
      return _notifications;
    }
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Get recent notifications (last 7 days)
  List<NotificationModel> getRecentNotifications() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications.where((n) => n.createdAt.isAfter(sevenDaysAgo)).toList();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset provider (for logout)
  void reset() {
    _notifications = [];
    _isLoading = false;
    _unreadCount = 0;
    _errorMessage = null;
    _loadMockNotifications();
    notifyListeners();
  }
}