import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadConversations();
  }

  void _loadConversations() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final conversations = chatProvider.conversations;

    final filteredConversations = _searchQuery.isEmpty
        ? conversations
        : conversations
            .where((conv) => conv.otherUserName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Chats'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Conversations List
          Expanded(
            child: chatProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredConversations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await chatProvider.fetchConversations();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredConversations.length,
                          itemBuilder: (context, index) {
                            final conversation = filteredConversations[index];

                            // Filter based on tab
                            if (_tabController.index == 1 &&
                                conversation.unreadCount == 0) {
                              return const SizedBox.shrink();
                            }

                            return _buildConversationTile(conversation,
                                authProvider.currentUser?.id ?? '');
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(conversation, String currentUserId) {
    final isFarmer = conversation.otherUserRole == 'farmer';
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: conversation.otherUserImage != null
                  ? NetworkImage(conversation.otherUserImage!)
                  : null,
              backgroundColor: Colors.grey.shade200,
              child: conversation.otherUserImage == null
                  ? Text(
                      conversation.otherUserName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            if (conversation.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.otherUserName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              _formatTime(conversation.lastMessageTime),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            if (conversation.lastSenderId == currentUserId)
              const Icon(
                Icons.done_all,
                size: 14,
                color: Colors.blue,
              ),
            if (conversation.lastSenderId == currentUserId)
              const SizedBox(width: 4),
            Expanded(
              child: Text(
                conversation.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: conversation.unreadCount > 0
                      ? Colors.black
                      : Colors.grey.shade600,
                  fontWeight: conversation.unreadCount > 0
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${conversation.unreadCount}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        isThreeLine: false,
        onTap: () {
          // Mark as read when opening chat
          chatProvider.markAsRead(conversation.id);

          Navigator.pushNamed(
            context,
            AppRoutes.chatDetail,
            arguments: {
              'chatId': conversation.id,
              'currentUserId': currentUserId,
              'receiverId': conversation.otherUserId,
              'receiverName': conversation.otherUserName,
              'receiverImage': conversation.otherUserImage,
              'receiverRole': conversation.otherUserRole,
            },
          ).then((_) {
            // Refresh conversations when returning
            _loadConversations();
          });
        },
        onLongPress: () {
          _showConversationOptions(conversation);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "No messages yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start a conversation with farmers or buyers",
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to products to start conversation
              Navigator.pushNamed(context, AppRoutes.productList);
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text("Browse Products"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showConversationOptions(conversation) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Conversation',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteConversation(conversation);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteConversation(conversation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Conversation'),
          content: Text(
              'Are you sure you want to delete conversation with ${conversation.otherUserName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final chatProvider =
                    Provider.of<ChatProvider>(context, listen: false);
                chatProvider.deleteConversation(conversation.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conversation deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
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
