import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  final double _deliveryFee = 5.0;
  final double _taxRate = 0.08;
  String? _couponCode;
  double? _couponDiscount;
  bool _isLoading = false;

  // Getters
  List<CartItem> get items => _items;
  int get itemCount => _items.length;  // This is what home_screen uses
  double get deliveryFee => _deliveryFee;
  double get taxRate => _taxRate;
  String? get couponCode => _couponCode;
  double? get couponDiscount => _couponDiscount;
  bool get isLoading => _isLoading;
  
  double get subtotal {
    double total = 0;
    for (var item in _items) {
      total += item.discountedTotal;
    }
    return total;
  }
  
  double get taxAmount => subtotal * _taxRate;
  
  double get discountAmount => _couponDiscount ?? 0;
  
  double get total {
    double totalAmount = subtotal + _deliveryFee + taxAmount - discountAmount;
    return totalAmount > 0 ? totalAmount : 0;
  }
  
  bool get isFreeDelivery => subtotal >= 50.0;
  
  double get actualDeliveryFee => isFreeDelivery ? 0 : _deliveryFee;

  CartProvider() {
    _loadSavedCart();
  }

  void _loadSavedCart() {
    // Load from SharedPreferences in real app
    _items = [];
  }

  // Add product to cart
  void addToCartFromProduct(ProductModel product, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        productId: product.id,
        name: product.name,
        image: product.images.isNotEmpty ? product.images.first : 'https://via.placeholder.com/100',
        price: product.price,
        quantity: quantity,
        farmerId: product.farmerId,
        farmerName: product.farmerName,
        discount: product.discount,
      ));
    }
    
    _applyCouponIfNeeded();
    notifyListeners();
    _saveCartToStorage();
  }

  // Add cart item directly
  void addToCart(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.productId == item.productId);
    
    if (existingIndex != -1) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    
    _applyCouponIfNeeded();
    notifyListeners();
    _saveCartToStorage();
  }

  // Remove from cart
  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    _applyCouponIfNeeded();
    notifyListeners();
    _saveCartToStorage();
  }

  // Update quantity
  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      _applyCouponIfNeeded();
      notifyListeners();
      _saveCartToStorage();
    }
  }

  // Increment quantity
  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _items[index].quantity++;
      _applyCouponIfNeeded();
      notifyListeners();
      _saveCartToStorage();
    }
  }

  // Decrement quantity
  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      _applyCouponIfNeeded();
      notifyListeners();
      _saveCartToStorage();
    }
  }

  // Clear entire cart
  void clearCart() {
    _items.clear();
    _couponCode = null;
    _couponDiscount = null;
    notifyListeners();
    _saveCartToStorage();
  }

  // Fetch cart from server
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoading = false;
    notifyListeners();
  }

  // Apply coupon code
  Future<bool> applyCoupon(String code) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (code.toUpperCase() == 'SAVE10') {
      _couponCode = code;
      _couponDiscount = subtotal * 0.10;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (code.toUpperCase() == 'SAVE20') {
      _couponCode = code;
      _couponDiscount = subtotal * 0.20;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Remove coupon
  void removeCoupon() {
    _couponCode = null;
    _couponDiscount = null;
    notifyListeners();
  }

  void _applyCouponIfNeeded() {
    if (_couponCode != null && _couponDiscount != null) {
      if (_couponCode == 'SAVE10' || _couponCode == 'SAVE20') {
        _couponDiscount = subtotal * 0.10;
      }
      notifyListeners();
    }
  }

  void _saveCartToStorage() {
    // Implement SharedPreferences saving here
  }

  // Get quantity for a specific product
  int getItemQuantity(String productId) {
    final item = _items.firstWhere(
      (i) => i.productId == productId,
      orElse: () => CartItem(
        productId: '',
        name: '',
        image: '',
        price: 0,
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  // Get cart item by product ID
  CartItem? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }
}