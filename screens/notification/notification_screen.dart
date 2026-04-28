import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../app/routes.dart';
import '../../utils/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  void _loadNotifications() {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;
    
    // Apply filter
    var filteredNotifications = notifications;
    if (_filterType != 'all') {
      filteredNotifications = notifications.where((n) => n.type == _filterType).toList();
    }
    
    final unreadNotifications = notifications.where((n) => !n.isRead).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
        actions: [
          if (notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _filterType = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('All Notifications'),
                ),
                const PopupMenuItem(
                  value: 'order',
                  child: Text('Order Updates'),
                ),
                const PopupMenuItem(
                  value: 'payment',
                  child: Text('Payment Updates'),
                ),
                const PopupMenuItem(
                  value: 'message',
                  child: Text('Messages'),
                ),
                const PopupMenuItem(
                  value: 'promotion',
                  child: Text('Promotions'),
                ),
              ],
            ),
          if (unreadNotifications.isNotEmpty)
            TextButton(
              onPressed: () {
                _showMarkAllReadDialog();
              },
              child: const Text(
                'Mark All Read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredNotifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    await notificationProvider.fetchNotifications();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationCard(notification) {
    final isUnread = !notification.isRead;
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        notificationProvider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      },
      child: GestureDetector(
        onTap: () {
          // Mark as read
          if (isUnread) {
            final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
            notificationProvider.markAsRead(notification.id);
          }
          
          // Navigate based on notification type
          _handleNotificationTap(notification);
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isUnread ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isUnread
                ? const BorderSide(color: AppColors.primary, width: 1)
                : BorderSide.none,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnread ? Colors.blue.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                color: isUnread ? Colors.black : Colors.grey.shade800,
                              ),
                            ),
                          ),
                          if (notification.imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                notification.imageUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image, size: 20),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnread ? Colors.grey.shade800 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeAgo(notification.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Spacer(),
                          if (!isUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Read',
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            "No Notifications",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "You're all caught up!",
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.home);
            },
            icon: const Icon(Icons.home),
            label: const Text("Go to Home"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(notification) {
    switch (notification.type) {
      case 'order':
        if (notification.data != null && notification.data!.containsKey('orderId')) {
          Navigator.pushNamed(
            context,
            AppRoutes.orderDetail,
            arguments: {'orderId': notification.data!['orderId']},
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.orders);
        }
        break;
      case 'payment':
        if (notification.data != null && notification.data!.containsKey('orderId')) {
          Navigator.pushNamed(
            context,
            AppRoutes.orderTracking,
            arguments: {'orderId': notification.data!['orderId']},
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.orders);
        }
        break;
      case 'message':
        if (notification.data != null && notification.data!.containsKey('chatId')) {
          Navigator.pushNamed(
            context,
            AppRoutes.chatDetail,
            arguments: {
              'chatId': notification.data!['chatId'],
              'currentUserId': notification.data!['userId'],
              'receiverId': notification.data!['senderId'],
              'receiverName': notification.data!['senderName'],
            },
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.chat);
        }
        break;
      case 'promotion':
        // Navigate to promotions or products
        Navigator.pushNamed(context, AppRoutes.productList);
        break;
      default:
        // Do nothing
        break;
    }
  }

  void _showMarkAllReadDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mark All as Read'),
          content: const Text('Are you sure you want to mark all notifications as read?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                notificationProvider.markAllAsRead();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Mark All'),
            ),
          ],
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'payment':
        return Icons.payment;
      case 'message':
        return Icons.message;
      case 'promotion':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      case 'message':
        return Colors.blue;
      case 'promotion':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}