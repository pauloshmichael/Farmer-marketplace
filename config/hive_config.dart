import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/message_model.dart';

class HiveConfig {
  static const String userBox = 'user_box';
  static const String cartBox = 'cart_box';
  static const String settingsBox = 'settings_box';
  static const String searchHistoryBox = 'search_history_box';
  static const String offlineProductsBox = 'offline_products_box';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(OrderModelAdapter());
    Hive.registerAdapter(CartItemAdapter());
    Hive.registerAdapter(MessageModelAdapter());

    // Open boxes
    await Hive.openBox<UserModel>(userBox);
    await Hive.openBox<CartItem>(cartBox);
    await Hive.openBox<dynamic>(settingsBox);
    await Hive.openBox<String>(searchHistoryBox);
    await Hive.openBox<ProductModel>(offlineProductsBox);
  }

  static Future<void> clearAllBoxes() async {
    await Hive.deleteBoxFromDisk(userBox);
    await Hive.deleteBoxFromDisk(cartBox);
    await Hive.deleteBoxFromDisk(settingsBox);
    await Hive.deleteBoxFromDisk(searchHistoryBox);
    await Hive.deleteBoxFromDisk(offlineProductsBox);
  }
}

// UserModel Adapter
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      id: reader.readString(),
      name: reader.readString(),
      email: reader.readString(),
      role: reader.readString(),
      phone: reader.readString(),
      profileImage: reader.readString(),
      address: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      isVerified: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.role);
    writer.writeString(obj.phone);
    writer.writeString(obj.profileImage ?? '');
    writer.writeString(obj.address);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeBool(obj.isVerified);
  }
}

// ProductModel Adapter
class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 1;

  @override
  ProductModel read(BinaryReader reader) {
    return ProductModel(
      id: reader.readString(),
      name: reader.readString(),
      description: reader.readString(),
      price: reader.readDouble(),
      quantity: reader.readInt(),
      category: reader.readString(),
      images: reader.readList().cast<String>(),
      farmerId: reader.readString(),
      farmerName: reader.readString(),
      farmerImage: reader.readString(),
      isAvailable: reader.readBool(),
      rating: reader.readDouble(),
      reviewCount: reader.readInt(),
      createdAt: DateTime.parse(reader.readString()),
      discount: reader.readDouble(),
      isOrganic: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
    writer.writeDouble(obj.price);
    writer.writeInt(obj.quantity);
    writer.writeString(obj.category);
    writer.writeList(obj.images);
    writer.writeString(obj.farmerId);
    writer.writeString(obj.farmerName);
    writer.writeString(obj.farmerImage);
    writer.writeBool(obj.isAvailable);
    writer.writeDouble(obj.rating);
    writer.writeInt(obj.reviewCount);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeDouble(obj.discount ?? 0);
    writer.writeBool(obj.isOrganic);
  }
}

// OrderModel Adapter
class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 2;

  @override
  OrderModel read(BinaryReader reader) {
    return OrderModel(
      id: reader.readString(),
      userId: reader.readString(),
      farmerId: reader.readString(),
      farmerName: reader.readString(),
      items: reader.readList().cast<OrderItem>(),
      subtotal: reader.readDouble(),
      shippingFee: reader.readDouble(),
      tax: reader.readDouble(),
      total: reader.readDouble(),
      status: reader.readString(),
      paymentMethod: reader.readString(),
      paymentStatus: reader.readString(),
      shippingAddress: reader.read() as ShippingAddress,
      orderDate: DateTime.parse(reader.readString()),
      deliveredDate:
          reader.readBool() ? DateTime.parse(reader.readString()) : null,
      trackingNumber: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.userId);
    writer.writeString(obj.farmerId);
    writer.writeString(obj.farmerName);
    writer.writeList(obj.items);
    writer.writeDouble(obj.subtotal);
    writer.writeDouble(obj.shippingFee);
    writer.writeDouble(obj.tax);
    writer.writeDouble(obj.total);
    writer.writeString(obj.status);
    writer.writeString(obj.paymentMethod);
    writer.writeString(obj.paymentStatus);
    writer.write(obj.shippingAddress);
    writer.writeString(obj.orderDate.toIso8601String());
    writer.writeBool(obj.deliveredDate != null);
    if (obj.deliveredDate != null) {
      writer.writeString(obj.deliveredDate!.toIso8601String());
    }
    writer.writeString(obj.trackingNumber ?? '');
  }
}

// CartItem Adapter
class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 3;

  @override
  CartItem read(BinaryReader reader) {
    return CartItem(
      productId: reader.readString(),
      name: reader.readString(),
      image: reader.readString(),
      price: reader.readDouble(),
      quantity: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer.writeString(obj.productId);
    writer.writeString(obj.name);
    writer.writeString(obj.image);
    writer.writeDouble(obj.price);
    writer.writeInt(obj.quantity);
  }
}

// MessageModel Adapter
class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 4;

  @override
  MessageModel read(BinaryReader reader) {
    return MessageModel(
      id: reader.readString(),
      senderId: reader.readString(),
      receiverId: reader.readString(),
      conversationId: reader.readString(),
      message: reader.readString(),
      type: reader.readString(),
      timestamp: DateTime.parse(reader.readString()),
      isSeen: reader.readBool(),
      imageUrl: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.senderId);
    writer.writeString(obj.receiverId);
    writer.writeString(obj.conversationId);
    writer.writeString(obj.message);
    writer.writeString(obj.type);
    writer.writeString(obj.timestamp.toIso8601String());
    writer.writeBool(obj.isSeen);
    writer.writeString(obj.imageUrl ?? '');
  }
}

// ShippingAddress Adapter
class ShippingAddressAdapter extends TypeAdapter<ShippingAddress> {
  @override
  final int typeId = 5;

  @override
  ShippingAddress read(BinaryReader reader) {
    return ShippingAddress(
      fullName: reader.readString(),
      phone: reader.readString(),
      address: reader.readString(),
      city: reader.readString(),
      state: reader.readString(),
      zipCode: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ShippingAddress obj) {
    writer.writeString(obj.fullName);
    writer.writeString(obj.phone);
    writer.writeString(obj.address);
    writer.writeString(obj.city);
    writer.writeString(obj.state);
    writer.writeString(obj.zipCode);
  }
}

// OrderItem Adapter
class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final int typeId = 6;

  @override
  OrderItem read(BinaryReader reader) {
    return OrderItem(
      productId: reader.readString(),
      productName: reader.readString(),
      productImage: reader.readString(),
      price: reader.readDouble(),
      quantity: reader.readInt(),
      total: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer.writeString(obj.productId);
    writer.writeString(obj.productName);
    writer.writeString(obj.productImage);
    writer.writeDouble(obj.price);
    writer.writeInt(obj.quantity);
    writer.writeDouble(obj.total);
  }
}
