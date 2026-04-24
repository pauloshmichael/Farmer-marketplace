import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/chat_provider.dart';
import '../../models/message_model.dart';
import '../../utils/colors.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String receiverId;
  final String receiverName;
  final String? receiverImage;
  final String? receiverRole;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
    this.receiverImage,
    this.receiverRole,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isTyping = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markMessagesAsRead();
  }

  void _loadMessages() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.loadMessages(widget.chatId);
  }

  void _markMessagesAsRead() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.markMessagesAsRead(widget.chatId, widget.currentUserId);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }



void _sendMessage() async {
  if (_messageController.text.trim().isEmpty || _isSending) return;

  setState(() {
    _isSending = true;
  });

  final message = MessageModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    conversationId: widget.chatId,  // Add conversationId
    senderId: widget.currentUserId,
    receiverId: widget.receiverId,
    message: _messageController.text.trim(),
    type: 'text',
    timestamp: DateTime.now(),
    isSeen: false,
  );

  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  await chatProvider.sendMessage(message);

  _messageController.clear();
  setState(() {
    _isSending = false;
  });
  _scrollToBottom();
}

  Future<void> _sendImageMessage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _isSending = true;
      });

      // Simulate image upload
      await Future.delayed(const Duration(seconds: 1));

      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: widget.chatId,
        senderId: widget.currentUserId,
        receiverId: widget.receiverId,
        message: '📷 Image',
        type: 'image',
        timestamp: DateTime.now(),
        isSeen: false,
        imageUrl: pickedFile.path,
      );

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.sendMessage(message);

      setState(() {
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _showTypingIndicator() {
    // Show typing indicator logic
    setState(() {
      _isTyping = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.receiverImage != null
                  ? NetworkImage(widget.receiverImage!)
                  : null,
              child: widget.receiverImage == null
                  ? Text(
                      widget.receiverName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 16),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(fontSize: 16),
                ),
                if (widget.receiverRole != null)
                  Text(
                    widget.receiverRole!,
                    style: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showChatOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: chatProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? _buildEmptyChatState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == widget.currentUserId;
                          
                          return _buildMessageBubble(message, isMe, index == messages.length - 1);
                        },
                      ),
          ),
          
          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 40,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 6,
                          child: SizedBox.shrink(),
                        ),
                        SizedBox(width: 4),
                        CircleAvatar(
                          radius: 6,
                          child: SizedBox.shrink(),
                        ),
                        SizedBox(width: 4),
                        CircleAvatar(
                          radius: 6,
                          child: SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.receiverName} is typing...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          
          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe, bool isLast) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.type == 'image')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.imageUrl ?? '',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image, size: 40),
                          );
                        },
                      ),
                    )
                  else
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      if (isMe && isLast) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isSeen ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isSeen ? Colors.blue : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Gallery Button
            IconButton(
              icon: const Icon(Icons.photo, color: AppColors.primary),
              onPressed: _sendImageMessage,
            ),
            
            // Camera Button
            IconButton(
              icon: const Icon(Icons.camera_alt, color: AppColors.primary),
              onPressed: _sendImageMessage,
            ),
            
            // Text Field
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _showTypingIndicator();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            
            // Send Button
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _messageController.text.trim().isEmpty ? Colors.grey.shade300 : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: _messageController.text.trim().isEmpty ? Colors.grey : Colors.white,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState() {
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
            "Start a conversation with ${widget.receiverName}",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
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
                leading: const Icon(Icons.person, color: AppColors.primary),
                title: const Text('View Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to user profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Conversation',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteConversation();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteConversation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Conversation'),
          content: const Text('Are you sure you want to delete this conversation?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                chatProvider.deleteConversation(widget.chatId);
                Navigator.pop(context);
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
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}