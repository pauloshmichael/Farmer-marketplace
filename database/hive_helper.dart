import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  static final HiveHelper _instance = HiveHelper._internal();
  factory HiveHelper() => _instance;
  HiveHelper._internal();

  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String cartBox = 'cart_box';
  static const String searchHistoryBox = 'search_history_box';
  static const String offlineProductsBox = 'offline_products_box';
  static const String notificationsBox = 'notifications_box';
  static const String messagesBox = 'messages_box';

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters if needed
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(CartItemAdapter());
    Hive.registerAdapter(MessageModelAdapter());
    
    // Open boxes
    await Hive.openBox(userBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(cartBox);
    await Hive.openBox(searchHistoryBox);
    await Hive.openBox(offlineProductsBox);
    await Hive.openBox(notificationsBox);
    await Hive.openBox(messagesBox);
  }

  // User Box Operations
  Box get userBoxInstance => Hive.box(userBox);
  
  Future<void> saveUser(Map<String, dynamic> user) async {
    await userBoxInstance.put('current_user', user);
  }
  
  Map<String, dynamic>? getCurrentUser() {
    return userBoxInstance.get('current_user');
  }
  
  Future<void> clearUser() async {
    await userBoxInstance.delete('current_user');
  }

  // Settings Box Operations
  Box get settingsBoxInstance => Hive.box(settingsBox);
  
  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBoxInstance.put(key, value);
  }
  
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBoxInstance.get(key, defaultValue: defaultValue);
  }
  
  bool get isDarkMode => getSetting('is_dark_mode', defaultValue: false);
  
  Future<void> setDarkMode(bool value) async {
    await saveSetting('is_dark_mode', value);
  }
  
  String get language => getSetting('language', defaultValue: 'en');
  
  Future<void> setLanguage(String value) async {
    await saveSetting('language', value);
  }
  
  bool get notificationsEnabled => getSetting('notifications_enabled', defaultValue: true);
  
  Future<void> setNotificationsEnabled(bool value) async {
    await saveSetting('notifications_enabled', value);
  }

  // Cart Box Operations
  Box get cartBoxInstance => Hive.box(cartBox);
  
  Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    await cartBoxInstance.put('cart_items', cartItems);
  }
  
  List<Map<String, dynamic>> getCartItems() {
    final items = cartBoxInstance.get('cart_items');
    return items != null ? List<Map<String, dynamic>>.from(items) : [];
  }
  
  Future<void> clearCart() async {
    await cartBoxInstance.delete('cart_items');
  }

  // Search History Box Operations
  Box get searchHistoryBoxInstance => Hive.box(searchHistoryBox);
  
  Future<void> addSearchQuery(String query) async {
    List<String> history = getSearchHistory();
    history.remove(query);
    history.insert(0, query);
    if (history.length > 20) {
      history = history.sublist(0, 20);
    }
    await searchHistoryBoxInstance.put('queries', history);
  }
  
  List<String> getSearchHistory() {
    final queries = searchHistoryBoxInstance.get('queries');
    return queries != null ? List<String>.from(queries) : [];
  }
  
  Future<void> clearSearchHistory() async {
    await searchHistoryBoxInstance.delete('queries');
  }

  // Offline Products Box Operations
  Box get offlineProductsBoxInstance => Hive.box(offlineProductsBox);
  
  Future<void> saveProductOffline(Map<String, dynamic> product) async {
    await offlineProductsBoxInstance.put(product['id'], product);
  }
  
  Future<void> saveProductsOffline(List<Map<String, dynamic>> products) async {
    for (var product in products) {
      await offlineProductsBoxInstance.put(product['id'], product);
    }
  }
  
  Map<String, dynamic>? getOfflineProduct(String productId) {
    return offlineProductsBoxInstance.get(productId);
  }
  
  List<Map<String, dynamic>> getAllOfflineProducts() {
    return offlineProductsBoxInstance.values
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  
  Future<void> clearOfflineProducts() async {
    await offlineProductsBoxInstance.clear();
  }

  // Notifications Box Operations
  Box get notificationsBoxInstance => Hive.box(notificationsBox);
  
  Future<void> saveNotification(Map<String, dynamic> notification) async {
    final notifications = getNotifications();
    notifications.insert(0, notification);
    if (notifications.length > 100) {
      notifications.removeLast();
    }
    await notificationsBoxInstance.put('list', notifications);
  }
  
  List<Map<String, dynamic>> getNotifications() {
    final notifications = notificationsBoxInstance.get('list');
    return notifications != null ? List<Map<String, dynamic>>.from(notifications) : [];
  }
  
  Future<void> markNotificationAsRead(int index) async {
    final notifications = getNotifications();
    if (index < notifications.length) {
      notifications[index]['is_read'] = true;
      await notificationsBoxInstance.put('list', notifications);
    }
  }
  
  Future<void> clearNotifications() async {
    await notificationsBoxInstance.delete('list');
  }

  // Messages Box Operations
  Box get messagesBoxInstance => Hive.box(messagesBox);
  
  Future<void> saveMessage(String conversationId, Map<String, dynamic> message) async {
    final messages = getMessages(conversationId);
    messages.add(message);
    await messagesBoxInstance.put(conversationId, messages);
  }
  
  List<Map<String, dynamic>> getMessages(String conversationId) {
    final messages = messagesBoxInstance.get(conversationId);
    return messages != null ? List<Map<String, dynamic>>.from(messages) : [];
  }
  
  Future<void> clearMessages(String conversationId) async {
    await messagesBoxInstance.delete(conversationId);
  }

  // General Operations
  Future<void> clearAllBoxes() async {
    await userBoxInstance.clear();
    await settingsBoxInstance.clear();
    await cartBoxInstance.clear();
    await searchHistoryBoxInstance.clear();
    await offlineProductsBoxInstance.clear();
    await notificationsBoxInstance.clear();
    await messagesBoxInstance.clear();
  }
}

// Hive Adapters
class UserModelAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  final int typeId = 0;
  
  @override
  Map<String, dynamic> read(BinaryReader reader) {
    final int length = reader.readInt();
    final Map<String, dynamic> map = {};
    for (int i = 0; i < length; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }
    return map;
  }
  
  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    writer.writeInt(obj.length);
    obj.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}

class ProductModelAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  final int typeId = 1;
  
  @override
  Map<String, dynamic> read(BinaryReader reader) {
    final int length = reader.readInt();
    final Map<String, dynamic> map = {};
    for (int i = 0; i < length; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }
    return map;
  }
  
  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    writer.writeInt(obj.length);
    obj.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}

class CartItemAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  final int typeId = 2;
  
  @override
  Map<String, dynamic> read(BinaryReader reader) {
    final int length = reader.readInt();
    final Map<String, dynamic> map = {};
    for (int i = 0; i < length; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }
    return map;
  }
  
  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    writer.writeInt(obj.length);
    obj.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}

class MessageModelAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  final int typeId = 3;
  
  @override
  Map<String, dynamic> read(BinaryReader reader) {
    final int length = reader.readInt();
    final Map<String, dynamic> map = {};
    for (int i = 0; i < length; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }
    return map;
  }
  
  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    writer.writeInt(obj.length);
    obj.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}