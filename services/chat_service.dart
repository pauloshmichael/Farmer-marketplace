import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String message,
    required String type,
  }) async {
    final messageData = {
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'isSeen': false,
    };
    
    await _firestore.collection('messages').add(messageData);
    
    // Update conversation last message
    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    });
    
    // Update unread count for receiver
    await _firestore.collection('conversations').doc(conversationId).update({
      'unreadCount_$receiverId': FieldValue.increment(1),
    });
  }

  Stream<QuerySnapshot> getMessages(String conversationId) {
    return _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> markMessagesAsSeen(String conversationId, String userId) async {
    final messages = await _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .where('receiverId', isEqualTo: userId)
        .where('isSeen', isEqualTo: false)
        .get();
    
    for (var message in messages.docs) {
      await message.reference.update({'isSeen': true});
    }
    
    // Reset unread count
    await _firestore.collection('conversations').doc(conversationId).update({
      'unreadCount_$userId': 0,
    });
  }

  Future<String> createConversation({
    required String user1Id,
    required String user2Id,
    required String user1Name,
    required String user2Name,
    required String user1Image,
    required String user2Image,
  }) async {
    final conversationId = _generateConversationId(user1Id, user2Id);
    
    final conversationData = {
      'id': conversationId,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'user1Name': user1Name,
      'user2Name': user2Name,
      'user1Image': user1Image,
      'user2Image': user2Image,
      'lastMessage': '',
      'lastMessageTime': null,
      'unreadCount_$user1Id': 0,
      'unreadCount_$user2Id': 0,
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    await _firestore.collection('conversations').doc(conversationId).set(conversationData);
    
    return conversationId;
  }

  Stream<QuerySnapshot> getUserConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('user1Id', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  String _generateConversationId(String user1Id, String user2Id) {
    List<String> ids = [user1Id, user2Id];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }

  Future<void> deleteConversation(String conversationId) async {
    // Delete all messages in conversation
    final messages = await _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .get();
    
    for (var message in messages.docs) {
      await message.reference.delete();
    }
    
    // Delete conversation
    await _firestore.collection('conversations').doc(conversationId).delete();
  }
}