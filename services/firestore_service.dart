import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Collections
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _farmers => _firestore.collection('farmers');
  CollectionReference get _buyers => _firestore.collection('buyers');
  CollectionReference get _cooperatives => _firestore.collection('cooperatives');

  // Product Collections
  CollectionReference get _products => _firestore.collection('products');
  CollectionReference get _categories => _firestore.collection('categories');

  // Order Collections
  CollectionReference get _orders => _firestore.collection('orders');

  // Chat Collections
  CollectionReference get _messages => _firestore.collection('messages');
  CollectionReference get _conversations => _firestore.collection('conversations');

  // Notification Collection
  CollectionReference get _notifications => _firestore.collection('notifications');

  // User Methods
  Future<void> createUser(UserModel user) async {
    await _users.doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _users.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _users.doc(userId).update(data);
  }

  // Product Methods
  Future<void> addProduct(ProductModel product) async {
    await _products.doc(product.id).set(product.toJson());
  }

  Future<List<ProductModel>> getProducts({String? category, String? farmerId}) async {
    Query query = _products.where('isAvailable', isEqualTo: true);
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    
    if (farmerId != null) {
      query = query.where('farmerId', isEqualTo: farmerId);
    }
    
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<ProductModel>> streamProducts({String? category}) {
    Query query = _products.where('isAvailable', isEqualTo: true);
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _products.doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _products.doc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
  }

  // Order Methods
  Future<void> createOrder(OrderModel order) async {
    await _orders.doc(order.id).set(order.toJson());
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _orders
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _orders
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  Future<List<OrderModel>> getFarmerOrders(String farmerId) async {
    final snapshot = await _orders
        .where('items', arrayContains: {'farmerId': farmerId})
        .orderBy('orderDate', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orders.doc(orderId).update({
      'status': status,
      if (status == 'delivered') 'deliveredDate': DateTime.now().toIso8601String(),
    });
  }

  // Chat Methods
  Future<void> sendMessage(Map<String, dynamic> messageData) async {
    await _messages.add(messageData);
  }

  Stream<QuerySnapshot> getMessages(String conversationId) {
    return _messages
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    final messages = await _messages
        .where('conversationId', isEqualTo: conversationId)
        .where('receiverId', isEqualTo: userId)
        .where('isSeen', isEqualTo: false)
        .get();
    
    for (var message in messages.docs) {
      await message.reference.update({'isSeen': true});
    }
  }

  // Search Methods
  Future<List<ProductModel>> searchProducts(String query) async {
    final snapshot = await _products
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .where('isAvailable', isEqualTo: true)
        .limit(20)
        .get();
    
    return snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Batch Operations
  Future<void> batchWrite(List<Function> operations) async {
    final batch = _firestore.batch();
    for (var operation in operations) {
      operation(batch);
    }
    await batch.commit();
  }

  // Real-time Listeners
  Stream<DocumentSnapshot> streamUser(String userId) {
    return _users.doc(userId).snapshots();
  }

  Stream<QuerySnapshot> streamProductsByCategory(String category) {
    return _products
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .snapshots();
  }
}