import 'package:flutter/material.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  List<ConversationModel> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<MessageModel> get messages => _messages;
  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ChatProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _conversations = [
      ConversationModel(
        id: 'conv1',
        otherUserId: 'farmer1',
        otherUserName: 'Green Valley Farm',
        otherUserImage: 'https://via.placeholder.com/100',
        otherUserRole: 'farmer',
        lastMessage: 'Your order has been shipped!',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
        unreadCount: 2,
        isOnline: true,
        lastSenderId: 'farmer1',
      ),
      ConversationModel(
        id: 'conv2',
        otherUserId: 'farmer2',
        otherUserName: 'Happy Cow Dairy',
        otherUserImage: 'https://via.placeholder.com/100',
        otherUserRole: 'farmer',
        lastMessage: 'Fresh milk available tomorrow',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        isOnline: false,
        lastSenderId: 'farmer2',
      ),
      ConversationModel(
        id: 'conv3',
        otherUserId: 'buyer1',
        otherUserName: 'Sarah Johnson',
        otherUserImage: 'https://via.placeholder.com/100',
        otherUserRole: 'buyer',
        lastMessage: 'Thanks for the quality products!',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        isOnline: false,
        lastSenderId: 'buyer1',
      ),
    ];

    _messages = [
      MessageModel(
        id: 'msg1',
        conversationId: 'conv1',
        senderId: 'farmer1',
        receiverId: 'currentUser',
        message: 'Hello! How can I help you?',
        type: 'text',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isSeen: true,
      ),
      MessageModel(
        id: 'msg2',
        conversationId: 'conv1',
        senderId: 'currentUser',
        receiverId: 'farmer1',
        message: 'When will my order be delivered?',
        type: 'text',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isSeen: true,
      ),
      MessageModel(
        id: 'msg3',
        conversationId: 'conv1',
        senderId: 'farmer1',
        receiverId: 'currentUser',
        message: 'Your order has been shipped! Tracking number: TRK123456',
        type: 'text',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isSeen: false,
      ),
    ];
  }

  // Fetch all conversations
  Future<void> fetchConversations() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoading = false;
    notifyListeners();
  }

  // Load messages for a specific conversation
  Future<void> loadMessages(String conversationId) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filter messages by conversationId
    _messages = _messages.where((m) => m.conversationId == conversationId).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  // Send message
  Future<void> sendMessage(MessageModel message) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Add message to list
    _messages.add(message);
    
    // Update conversation last message
    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == message.conversationId
    );
    
    if (conversationIndex != -1) {
      final conv = _conversations[conversationIndex];
      _conversations[conversationIndex] = ConversationModel(
        id: conv.id,
        otherUserId: conv.otherUserId,
        otherUserName: conv.otherUserName,
        otherUserImage: conv.otherUserImage,
        otherUserRole: conv.otherUserRole,
        lastMessage: message.message,
        lastMessageTime: message.timestamp,
        unreadCount: conv.unreadCount + 1,
        isOnline: conv.isOnline,
        lastSenderId: message.senderId,
      );
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Mark messages as read in a conversation
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Update messages as seen
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].conversationId == conversationId && 
          _messages[i].receiverId == userId && 
          !_messages[i].isSeen) {
        _messages[i] = MessageModel(
          id: _messages[i].id,
          conversationId: _messages[i].conversationId,
          senderId: _messages[i].senderId,
          receiverId: _messages[i].receiverId,
          message: _messages[i].message,
          type: _messages[i].type,
          timestamp: _messages[i].timestamp,
          isSeen: true,
          imageUrl: _messages[i].imageUrl,
        );
      }
    }
    
    // Update conversation unread count
    final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (conversationIndex != -1) {
      final conv = _conversations[conversationIndex];
      _conversations[conversationIndex] = ConversationModel(
        id: conv.id,
        otherUserId: conv.otherUserId,
        otherUserName: conv.otherUserName,
        otherUserImage: conv.otherUserImage,
        otherUserRole: conv.otherUserRole,
        lastMessage: conv.lastMessage,
        lastMessageTime: conv.lastMessageTime,
        unreadCount: 0,
        isOnline: conv.isOnline,
        lastSenderId: conv.lastSenderId,
      );
    }
    
    notifyListeners();
  }

  // Mark as read (alias for compatibility)
  Future<void> markAsRead(String conversationId) async {
    await markMessagesAsRead(conversationId, 'currentUser');
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Remove all messages in this conversation
    _messages.removeWhere((m) => m.conversationId == conversationId);
    
    // Remove the conversation
    _conversations.removeWhere((c) => c.id == conversationId);
    
    _isLoading = false;
    notifyListeners();
  }

  // Delete a single message
  Future<void> deleteMessage(String messageId) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    _messages.removeWhere((m) => m.id == messageId);
    
    _isLoading = false;
    notifyListeners();
  }

  // Mark a single message as read
  Future<void> markMessageAsRead(String messageId) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = MessageModel(
        id: _messages[index].id,
        conversationId: _messages[index].conversationId,
        senderId: _messages[index].senderId,
        receiverId: _messages[index].receiverId,
        message: _messages[index].message,
        type: _messages[index].type,
        timestamp: _messages[index].timestamp,
        isSeen: true,
        imageUrl: _messages[index].imageUrl,
      );
      notifyListeners();
    }
  }

  // Send typing indicator
  Future<void> sendTypingIndicator(String conversationId, bool isTyping) async {
    // In real app, send to server
    notifyListeners();
  }

  // Update user online status
  void updateOnlineStatus(String userId, bool isOnline) {
    final index = _conversations.indexWhere((c) => c.otherUserId == userId);
    if (index != -1) {
      final conv = _conversations[index];
      _conversations[index] = ConversationModel(
        id: conv.id,
        otherUserId: conv.otherUserId,
        otherUserName: conv.otherUserName,
        otherUserImage: conv.otherUserImage,
        otherUserRole: conv.otherUserRole,
        lastMessage: conv.lastMessage,
        lastMessageTime: conv.lastMessageTime,
        unreadCount: conv.unreadCount,
        isOnline: isOnline,
        lastSenderId: conv.lastSenderId,
      );
      notifyListeners();
    }
  }

  // Clear messages for a conversation
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Create new conversation
  Future<String> createConversation({
    required String otherUserId,
    required String otherUserName,
    String? otherUserImage,
    String? otherUserRole,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newConversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final newConversation = ConversationModel(
      id: newConversationId,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserImage: otherUserImage,
      otherUserRole: otherUserRole,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: false,
      lastSenderId: '',
    );
    
    _conversations.insert(0, newConversation);
    
    _isLoading = false;
    notifyListeners();
    
    return newConversationId;
  }

  // Get conversation by ID
  ConversationModel? getConversationById(String conversationId) {
    try {
      return _conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  // Get unread count for a user
  int getUnreadCount(String userId) {
    int count = 0;
    for (var conv in _conversations) {
      if (conv.otherUserId != userId) {
        count += conv.unreadCount;
      }
    }
    return count;
  }
}