import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteHelper {
  static final SQLiteHelper _instance = SQLiteHelper._internal();
  factory SQLiteHelper() => _instance;
  SQLiteHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'farmer_marketplace.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        role TEXT NOT NULL,
        phone TEXT,
        profile_image TEXT,
        address TEXT,
        created_at TEXT NOT NULL,
        is_verified INTEGER DEFAULT 0
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        images TEXT,
        farmer_id TEXT NOT NULL,
        farmer_name TEXT,
        farmer_image TEXT,
        is_available INTEGER DEFAULT 1,
        rating REAL DEFAULT 0,
        review_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        discount REAL,
        is_organic INTEGER DEFAULT 0,
        unit TEXT
      )
    ''');

    // Cart table
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_image TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        farmer_id TEXT,
        farmer_name TEXT,
        discount REAL,
        added_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        subtotal REAL NOT NULL,
        shipping_fee REAL NOT NULL,
        tax REAL NOT NULL,
        discount REAL DEFAULT 0,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        payment_status TEXT NOT NULL,
        shipping_address TEXT NOT NULL,
        order_date TEXT NOT NULL,
        delivered_date TEXT,
        tracking_number TEXT,
        delivery_partner TEXT
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_image TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        total REAL NOT NULL,
        farmer_id TEXT,
        farmer_name TEXT,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Wishlist table
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        added_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id),
        UNIQUE(user_id, product_id)
      )
    ''');

    // Addresses table
    await db.execute('''
      CREATE TABLE addresses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        city TEXT NOT NULL,
        state TEXT NOT NULL,
        zip_code TEXT NOT NULL,
        landmark TEXT,
        is_default INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Conversations table
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        other_user_id TEXT NOT NULL,
        other_user_name TEXT NOT NULL,
        other_user_image TEXT,
        last_message TEXT,
        last_message_time TEXT,
        unread_count INTEGER DEFAULT 0,
        is_online INTEGER DEFAULT 0
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT DEFAULT 'text',
        timestamp TEXT NOT NULL,
        is_seen INTEGER DEFAULT 0,
        image_url TEXT
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        image_url TEXT
      )
    ''');

    // Search history table
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        searched_at TEXT NOT NULL
      )
    ''');

    // Recently viewed products table
    await db.execute('''
      CREATE TABLE recently_viewed (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        viewed_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id),
        UNIQUE(user_id, product_id)
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        image_url TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Farmers table
    await db.execute('''
      CREATE TABLE farmers (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        farm_name TEXT NOT NULL,
        farm_description TEXT,
        farm_address TEXT,
        farm_image TEXT,
        is_verified INTEGER DEFAULT 0,
        rating REAL DEFAULT 0,
        total_products INTEGER DEFAULT 0,
        total_orders INTEGER DEFAULT 0,
        joined_at TEXT NOT NULL,
        license_number TEXT
      )
    ''');

    // Cooperatives table
    await db.execute('''
      CREATE TABLE cooperatives (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        logo TEXT,
        cover_image TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        phone TEXT,
        email TEXT,
        website TEXT,
        member_count INTEGER DEFAULT 0,
        product_count INTEGER DEFAULT 0,
        rating REAL DEFAULT 0,
        is_verified INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Cooperative members table
    await db.execute('''
      CREATE TABLE cooperative_members (
        id TEXT PRIMARY KEY,
        cooperative_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_email TEXT NOT NULL,
        user_image TEXT,
        role TEXT DEFAULT 'member',
        joined_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (cooperative_id) REFERENCES cooperatives (id)
      )
    ''');

    // Reviews table
    await db.execute('''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_image TEXT,
        rating REAL NOT NULL,
        comment TEXT,
        images TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_products_category ON products(category)');
    await db.execute('CREATE INDEX idx_products_farmer_id ON products(farmer_id)');
    await db.execute('CREATE INDEX idx_orders_user_id ON orders(user_id)');
    await db.execute('CREATE INDEX idx_orders_status ON orders(status)');
    await db.execute('CREATE INDEX idx_cart_product_id ON cart(product_id)');
    await db.execute('CREATE INDEX idx_messages_conversation_id ON messages(conversation_id)');
    await db.execute('CREATE INDEX idx_notifications_user_id ON notifications(user_id)');
    await db.execute('CREATE INDEX idx_reviews_product_id ON reviews(product_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add migration logic here for version 2
    }
  }

  // ==================== USER OPERATIONS ====================
  
  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> user) async {
    final db = await database;
    await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ==================== PRODUCT OPERATIONS ====================
  
  Future<void> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    await db.insert('products', product, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllProducts({String? category}) async {
    final db = await database;
    if (category != null && category != 'All') {
      return await db.query(
        'products',
        where: 'category = ? AND is_available = 1',
        whereArgs: [category],
        orderBy: 'created_at DESC',
      );
    }
    return await db.query(
      'products',
      where: 'is_available = 1',
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getProduct(String productId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getFarmerProducts(String farmerId) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await database;
    return await db.query(
      'products',
      where: 'name LIKE ? AND is_available = 1',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> product) async {
    final db = await database;
    await db.update(
      'products',
      product,
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> deleteProduct(String productId) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [productId]);
  }

  // ==================== CART OPERATIONS ====================
  
  Future<void> addToCart(Map<String, dynamic> cartItem) async {
    final db = await database;
    await db.insert('cart', cartItem, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.query('cart', orderBy: 'added_at DESC');
  }

  Future<void> updateCartItemQuantity(int cartId, int quantity) async {
    final db = await database;
    await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<void> removeFromCart(int cartId) async {
    final db = await database;
    await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  Future<Map<String, dynamic>?> getCartItemByProductId(String productId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'cart',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ==================== ORDER OPERATIONS ====================
  
  Future<void> insertOrder(Map<String, dynamic> order) async {
    final db = await database;
    await db.insert('orders', order, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrderItem(Map<String, dynamic> orderItem) async {
    final db = await database;
    await db.insert('order_items', orderItem);
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'order_date DESC',
    );
  }

  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    final db = await database;
    return await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final db = await database;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  // ==================== WISHLIST OPERATIONS ====================
  
  Future<void> addToWishlist(String userId, String productId, String addedAt) async {
    final db = await database;
    await db.insert('wishlist', {
      'user_id': userId,
      'product_id': productId,
      'added_at': addedAt,
    });
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    final db = await database;
    await db.delete(
      'wishlist',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
  }

  Future<List<Map<String, dynamic>>> getWishlist(String userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.*, w.added_at 
      FROM wishlist w
      JOIN products p ON w.product_id = p.id
      WHERE w.user_id = ?
      ORDER BY w.added_at DESC
    ''', [userId]);
  }

  Future<bool> isInWishlist(String userId, String productId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'wishlist',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
    return result.isNotEmpty;
  }

  // ==================== ADDRESS OPERATIONS ====================
  
  Future<void> insertAddress(Map<String, dynamic> address) async {
    final db = await database;
    if (address['is_default'] == 1) {
      await db.update(
        'addresses',
        {'is_default': 0},
        where: 'user_id = ?',
        whereArgs: [address['user_id']],
      );
    }
    await db.insert('addresses', address, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUserAddresses(String userId) async {
    final db = await database;
    return await db.query(
      'addresses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'is_default DESC, created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getDefaultAddress(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'addresses',
      where: 'user_id = ? AND is_default = 1',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateAddress(String addressId, Map<String, dynamic> address) async {
    final db = await database;
    if (address['is_default'] == 1) {
      final oldAddress = await getAddress(addressId);
      if (oldAddress != null) {
        await db.update(
          'addresses',
          {'is_default': 0},
          where: 'user_id = ? AND is_default = 1',
          whereArgs: [oldAddress['user_id']],
        );
      }
    }
    await db.update(
      'addresses',
      address,
      where: 'id = ?',
      whereArgs: [addressId],
    );
  }

  Future<Map<String, dynamic>?> getAddress(String addressId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'addresses',
      where: 'id = ?',
      whereArgs: [addressId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> deleteAddress(String addressId) async {
    final db = await database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [addressId]);
  }

  // ==================== MESSAGE OPERATIONS ====================
  
  Future<void> insertConversation(Map<String, dynamic> conversation) async {
    final db = await database;
    await db.insert('conversations', conversation, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final db = await database;
    return await db.query(
      'conversations',
      orderBy: 'last_message_time DESC',
    );
  }

  Future<void> insertMessage(Map<String, dynamic> message) async {
    final db = await database;
    await db.insert('messages', message, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> markMessagesAsSeen(String conversationId, String receiverId) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE messages 
      SET is_seen = 1 
      WHERE conversation_id = ? AND receiver_id = ? AND is_seen = 0
    ''', [conversationId, receiverId]);
    
    await db.update(
      'conversations',
      {'unread_count': 0},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  Future<void> updateConversationLastMessage(String conversationId, String lastMessage, String timestamp) async {
    final db = await database;
    await db.update(
      'conversations',
      {
        'last_message': lastMessage,
        'last_message_time': timestamp,
      },
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  // ==================== NOTIFICATION OPERATIONS ====================
  
  Future<void> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;
    await db.insert('notifications', notification, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getNotifications(String userId, {int limit = 50}) async {
    final db = await database;
    return await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'notifications',
      where: 'user_id = ? AND is_read = 0',
      whereArgs: [userId],
    );
    return result.length;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    final db = await database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [notificationId]);
  }

  // ==================== SEARCH HISTORY OPERATIONS ====================
  
  Future<void> addSearchQuery(String query, String searchedAt) async {
    final db = await database;
    await db.insert('search_history', {
      'query': query,
      'searched_at': searchedAt,
    });
    
    // Keep only last 20 searches
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM search_history')
    ) ?? 0;
    
    if (count > 20) {
      await db.rawDelete('''
        DELETE FROM search_history 
        WHERE id IN (
          SELECT id FROM search_history 
          ORDER BY searched_at ASC 
          LIMIT ?
        )
      ''', [count - 20]);
    }
  }

  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final db = await database;
    return await db.query(
      'search_history',
      orderBy: 'searched_at DESC',
      limit: 20,
    );
  }

  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_history');
  }

  // ==================== RECENTLY VIEWED OPERATIONS ====================
  
  Future<void> addRecentlyViewed(String userId, String productId, String viewedAt) async {
    final db = await database;
    await db.insert('recently_viewed', {
      'user_id': userId,
      'product_id': productId,
      'viewed_at': viewedAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    
    // Keep only last 20 viewed items
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM recently_viewed WHERE user_id = ?', [userId])
    ) ?? 0;
    
    if (count > 20) {
      await db.rawDelete('''
        DELETE FROM recently_viewed 
        WHERE user_id = ? AND id IN (
          SELECT id FROM recently_viewed 
          WHERE user_id = ? 
          ORDER BY viewed_at ASC 
          LIMIT ?
        )
      ''', [userId, userId, count - 20]);
    }
  }

  Future<List<Map<String, dynamic>>> getRecentlyViewed(String userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.*, rv.viewed_at 
      FROM recently_viewed rv
      JOIN products p ON rv.product_id = p.id
      WHERE rv.user_id = ?
      ORDER BY rv.viewed_at DESC
      LIMIT 20
    ''', [userId]);
  }

  // ==================== REVIEW OPERATIONS ====================
  
  Future<void> insertReview(Map<String, dynamic> review) async {
    final db = await database;
    await db.insert('reviews', review, conflictAlgorithm: ConflictAlgorithm.replace);
    
    // Update product rating
    final avgRating = await getAverageRatingForProduct(review['product_id']);
    await db.update(
      'products',
      {
        'rating': avgRating,
        'review_count': await getReviewCountForProduct(review['product_id']),
      },
      where: 'id = ?',
      whereArgs: [review['product_id']],
    );
  }

  Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    final db = await database;
    return await db.query(
      'reviews',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
  }

  Future<double> getAverageRatingForProduct(String productId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT AVG(rating) as avg_rating 
      FROM reviews 
      WHERE product_id = ?
    ''', [productId]);
    return result.first['avg_rating'] as double? ?? 0.0;
  }

  Future<int> getReviewCountForProduct(String productId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM reviews 
      WHERE product_id = ?
    ''', [productId]);
    return result.first['count'] as int? ?? 0;
  }

  // ==================== HELPER METHODS ====================
  
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('users');
    await db.delete('products');
    await db.delete('cart');
    await db.delete('orders');
    await db.delete('order_items');
    await db.delete('wishlist');
    await db.delete('addresses');
    await db.delete('conversations');
    await db.delete('messages');
    await db.delete('notifications');
    await db.delete('search_history');
    await db.delete('recently_viewed');
    await db.delete('reviews');
  }

  Future<Map<String, dynamic>> getDatabaseStats() async {
    final db = await database;
    final userCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
    final productCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products')) ?? 0;
    final orderCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM orders')) ?? 0;
    final cartCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cart')) ?? 0;
    
    return {
      'users': userCount,
      'products': productCount,
      'orders': orderCount,
      'cart_items': cartCount,
    };
  }
}