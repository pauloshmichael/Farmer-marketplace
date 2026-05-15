import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  // Private properties
  List<ProductModel> _products = [];
  List<ProductModel> _farmerProducts = [];
  List<ProductModel> _cooperativeProducts = [];
  List<ProductModel> _wishlist = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _popularProducts = [];
  List<ProductModel> _searchResults = [];

  bool _isLoading = false;
  bool _isLoadingFeatured = false;
  bool _isLoadingPopular = false;
  bool _isLoadingSearch = false;

  String _errorMessage = '';
  String _currentCategory = 'All';
  String _searchQuery = '';

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get farmerProducts => _farmerProducts;
  List<ProductModel> get cooperativeProducts => _cooperativeProducts;
  List<ProductModel> get wishlist => _wishlist;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get popularProducts => _popularProducts;
  List<ProductModel> get searchResults => _searchResults;

  bool get isLoading => _isLoading;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingSearch => _isLoadingSearch;

  String get errorMessage => _errorMessage;
  String get currentCategory => _currentCategory;
  String get searchQuery => _searchQuery;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Filtered products based on category and search
  List<ProductModel> get filteredProducts {
    List<ProductModel> result = _products;

    if (_currentCategory != 'All') {
      result = result.where((p) => p.category == _currentCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return result;
  }

  // Constructor
  ProductProvider() {
    _loadMockProducts();
  }

  // Load mock product data
  void _loadMockProducts() {
    // Featured Products - UPDATED IMAGES
    _featuredProducts = [
      ProductModel(
        id: '1',
        name: 'Fresh Organic Tomatoes',
        description:
            'Farm-fresh organic tomatoes grown without pesticides. Perfect for salads and cooking.',
        price: 3.99,
        quantity: 100,
        category: 'Vegetables',
        images: [
          'https://images.pexels.com/photos/33499935/pexels-photo-33499935.jpeg'
        ],
        farmerId: 'farmer1',
        farmerName: 'Abebe  Farm',
        farmerImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        isAvailable: true,
        rating: 4.8,
        reviewCount: 124,
        createdAt: DateTime.now(),
        discount: 10,
        isOrganic: true,
        unit: 'kg',
        soldCount: 45,
      ),
      ProductModel(
        id: '2',
        name: 'Organic Potatoes',
        description: 'High-quality organic potatoes, freshly harvested.',
        price: 2.49,
        quantity: 200,
        category: 'Vegetables',
        images: [
          'https://images.pexels.com/photos/2286776/pexels-photo-2286776.jpeg?w=400'
        ],
        farmerId: 'farmer1',
        farmerName: 'Abebe  Farm',
        farmerImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        isAvailable: true,
        rating: 4.5,
        reviewCount: 89,
        createdAt: DateTime.now(),
        isOrganic: true,
        unit: 'kg',
        soldCount: 120,
      ),
      ProductModel(
        id: '3',
        name: 'Fresh Milk',
        description: 'Pure cow milk, pasteurized and delivered fresh daily.',
        price: 4.99,
        quantity: 50,
        category: 'Dairy',
        images: [
          'https://images.pexels.com/photos/7282733/pexels-photo-7282733.jpeg?w=400'
        ],
        farmerId: 'farmer2',
        farmerName: 'kebede Dairy',
        farmerImage: 'https://randomuser.me/api/portraits/women/1.jpg',
        isAvailable: true,
        rating: 4.9,
        reviewCount: 256,
        createdAt: DateTime.now(),
        discount: 5,
        unit: 'litre',
        soldCount: 234,
      ),
    ];

    // Popular Products - UPDATED IMAGES
    _popularProducts = [
      ProductModel(
        id: '4',
        name: 'Organic Apples',
        description: 'Sweet and crispy organic apples from Kashmir.',
        price: 5.99,
        quantity: 75,
        category: 'Fruits',
        images: [
          'https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg?w=400'
        ],
        farmerId: 'farmer3',
        farmerName: 'Tafese Orchard',
        farmerImage: 'https://randomuser.me/api/portraits/men/2.jpg',
        isAvailable: true,
        rating: 4.7,
        reviewCount: 178,
        createdAt: DateTime.now(),
        discount: 15,
        isOrganic: true,
        unit: 'kg',
        soldCount: 89,
      ),
      ProductModel(
        id: '5',
        name: 'Free-Range Eggs',
        description: 'Farm fresh free-range eggs from happy chickens.',
        price: 6.99,
        quantity: 200,
        category: 'Dairy',
        images: [
          'https://images.pexels.com/photos/4911784/pexels-photo-4911784.jpeg?w=400'
        ],
        farmerId: 'farmer2',
        farmerName: 'kebede Dairy',
        farmerImage: 'https://randomuser.me/api/portraits/women/1.jpg',
        isAvailable: true,
        rating: 4.6,
        reviewCount: 145,
        createdAt: DateTime.now(),
        unit: 'dozen',
        soldCount: 67,
      ),
    ];

    // All Products - UPDATED IMAGES
    _products = [
      ..._featuredProducts,
      ..._popularProducts,
      ProductModel(
        id: '6',
        name: 'Fresh Carrots',
        description: 'Crunchy and sweet organic carrots.',
        price: 2.99,
        quantity: 150,
        category: 'Vegetables',
        images: [
          'https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg?w=400'
        ],
        farmerId: 'farmer1',
        farmerName: 'Abebe  Farm',
        farmerImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        isAvailable: true,
        rating: 4.4,
        reviewCount: 67,
        createdAt: DateTime.now(),
        unit: 'kg',
        soldCount: 34,
      ),
      ProductModel(
        id: '7',
        name: 'Organic Spinach',
        description: 'Fresh organic spinach leaves, rich in iron.',
        price: 3.49,
        quantity: 80,
        category: 'Vegetables',
        images: [
          'https://images.pexels.com/photos/7511845/pexels-photo-7511845.jpeg?w=400'
        ],
        farmerId: 'farmer1',
        farmerName: 'Green Valley Farm',
        farmerImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        isAvailable: true,
        rating: 4.3,
        reviewCount: 45,
        createdAt: DateTime.now(),
        isOrganic: true,
        unit: 'bundle',
        soldCount: 23,
      ),
      ProductModel(
        id: '8',
        name: 'Fresh Broccoli',
        description: 'Fresh green broccoli, packed with nutrients.',
        price: 2.79,
        quantity: 90,
        category: 'Vegetables',
        images: [
          'https://images.pexels.com/photos/36895573/pexels-photo-36895573.jpeg?w=400'
        ],
        farmerId: 'farmer1',
        farmerName: 'Green Valley Farm',
        farmerImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        isAvailable: true,
        rating: 4.5,
        reviewCount: 78,
        createdAt: DateTime.now(),
        unit: 'kg',
        soldCount: 56,
      ),
      ProductModel(
        id: '9',
        name: 'Organic Honey',
        description: 'Pure organic honey from local bees.',
        price: 12.99,
        quantity: 30,
        category: 'Organic',
        images: [
          'https://images.pexels.com/photos/4111270/pexels-photo-4111270.jpeg?w=400'
        ],
        farmerId: 'farmer3',
        farmerName: 'Hilltop Orchard',
        farmerImage: 'https://randomuser.me/api/portraits/men/2.jpg',
        isAvailable: true,
        rating: 4.9,
        reviewCount: 234,
        createdAt: DateTime.now(),
        isOrganic: true,
        unit: 'jar',
        soldCount: 145,
      ),
    ];

    // Farmer Products
    _farmerProducts = _products.where((p) => p.farmerId == 'farmer1').toList();

    // Cooperative Products
    _cooperativeProducts = _products;
  }

  // ==================== FETCH METHODS ====================

  // Fetch all products
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    _isLoading = false;
    notifyListeners();
  }

  // Fetch featured products
  Future<void> fetchFeaturedProducts() async {
    _isLoadingFeatured = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoadingFeatured = false;
    notifyListeners();
  }

  // Fetch popular products
  Future<void> fetchPopularProducts() async {
    _isLoadingPopular = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoadingPopular = false;
    notifyListeners();
  }

  // Fetch farmer products
  Future<void> fetchFarmerProducts() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _isLoading = false;
    notifyListeners();
  }

  // Fetch cooperative products
  Future<void> fetchCooperativeProducts() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _isLoading = false;
    notifyListeners();
  }

  // Fetch product details
  Future<void> fetchProductDetails(String productId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  // ==================== SEARCH METHODS ====================

  // Search products
  Future<void> searchProducts(String query) async {
    _isLoadingSearch = true;
    _searchQuery = query;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = _products
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    _isLoadingSearch = false;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  // ==================== FILTER & SORT METHODS ====================

  // Filter by category
  void filterByCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  // Sort products
  void sortProducts(String sortBy) {
    if (sortBy == 'price_asc') {
      _products.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'price_desc') {
      _products.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'newest') {
      _products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortBy == 'popular') {
      _products.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    } else if (sortBy == 'rating') {
      _products.sort((a, b) => b.rating.compareTo(a.rating));
    }
    notifyListeners();
  }

  // ==================== CRUD OPERATIONS ====================

  // Add product from map
  Future<void> addProductFromMap(Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final newProduct = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: productData['name'],
      description: productData['description'],
      price: productData['price'],
      quantity: productData['quantity'],
      category: productData['category'],
      images: List<String>.from(productData['images']),
      farmerId: productData['farmerId'],
      farmerName: productData['farmerName'],
      farmerImage: productData['farmerImage'] ?? '',
      isAvailable: true,
      createdAt: DateTime.now(),
      discount: productData['discount'],
      isOrganic: productData['isOrganic'] ?? false,
      unit: productData['unit'],
      soldCount: 0,
    );

    _products.insert(0, newProduct);
    _farmerProducts.insert(0, newProduct);

    _isLoading = false;
    notifyListeners();
  }

  // Update product from map
  Future<void> updateProductFromMap(
      String productId, Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final updatedProduct = _products[index].copyWith(
        name: productData['name'],
        description: productData['description'],
        price: productData['price'],
        quantity: productData['quantity'],
        category: productData['category'],
        images: productData['images'],
        isAvailable: productData['isAvailable'],
        discount: productData['discount'],
        isOrganic: productData['isOrganic'],
        unit: productData['unit'],
      );

      _products[index] = updatedProduct;

      final farmerIndex = _farmerProducts.indexWhere((p) => p.id == productId);
      if (farmerIndex != -1) {
        _farmerProducts[farmerIndex] = updatedProduct;
      }

      final coopIndex =
          _cooperativeProducts.indexWhere((p) => p.id == productId);
      if (coopIndex != -1) {
        _cooperativeProducts[coopIndex] = updatedProduct;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _products.removeWhere((p) => p.id == productId);
    _farmerProducts.removeWhere((p) => p.id == productId);
    _cooperativeProducts.removeWhere((p) => p.id == productId);
    _wishlist.removeWhere((p) => p.id == productId);
    _featuredProducts.removeWhere((p) => p.id == productId);
    _popularProducts.removeWhere((p) => p.id == productId);

    _isLoading = false;
    notifyListeners();
  }

  // Toggle product availability
  void toggleProductAvailability(String productId, bool isAvailable) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(isAvailable: isAvailable);

      final farmerIndex = _farmerProducts.indexWhere((p) => p.id == productId);
      if (farmerIndex != -1) {
        _farmerProducts[farmerIndex] =
            _farmerProducts[farmerIndex].copyWith(isAvailable: isAvailable);
      }

      notifyListeners();
    }
  }

  // Update product quantity (for stock management)
  void updateProductQuantity(String productId, int newQuantity) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(quantity: newQuantity);

      final farmerIndex = _farmerProducts.indexWhere((p) => p.id == productId);
      if (farmerIndex != -1) {
        _farmerProducts[farmerIndex] =
            _farmerProducts[farmerIndex].copyWith(quantity: newQuantity);
      }

      notifyListeners();
    }
  }

  // ==================== PRODUCT RETRIEVAL ====================

  // Get product by ID
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get products by farmer ID
  List<ProductModel> getProductsByFarmer(String farmerId) {
    return _products.where((p) => p.farmerId == farmerId).toList();
  }

  // Get products by category
  List<ProductModel> getProductsByCategory(String category) {
    if (category == 'All') {
      return _products;
    }
    return _products.where((p) => p.category == category).toList();
  }

  // Get low stock products (quantity < 10)
  List<ProductModel> getLowStockProducts() {
    return _products.where((p) => p.quantity < 10 && p.isAvailable).toList();
  }

  // Get out of stock products
  List<ProductModel> getOutOfStockProducts() {
    return _products.where((p) => p.quantity == 0 || !p.isAvailable).toList();
  }

  // ==================== WISHLIST METHODS ====================

  // Add to wishlist
  void addToWishlist(ProductModel product) {
    if (!_wishlist.any((p) => p.id == product.id)) {
      _wishlist.add(product);
      notifyListeners();
    }
  }

  // Remove from wishlist
  void removeFromWishlist(String productId) {
    _wishlist.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlist.any((p) => p.id == productId);
  }

  // Clear wishlist
  void clearWishlist() {
    _wishlist.clear();
    notifyListeners();
  }

  // ==================== STATISTICS METHODS ====================

  // Get total number of products
  int getTotalProductCount() {
    return _products.length;
  }

  // Get total value of all products
  double getTotalInventoryValue() {
    return _products.fold(0.0, (sum, p) => sum + (p.price * p.quantity));
  }

  // Get average product price
  double getAverageProductPrice() {
    if (_products.isEmpty) return 0.0;
    return _products.fold(0.0, (sum, p) => sum + p.price) / _products.length;
  }

  // Get category distribution
  Map<String, int> getCategoryDistribution() {
    final Map<String, int> distribution = {};
    for (var product in _products) {
      distribution[product.category] =
          (distribution[product.category] ?? 0) + 1;
    }
    return distribution;
  }

  // Get top selling products
  List<ProductModel> getTopSellingProducts({int limit = 5}) {
    final sorted = List<ProductModel>.from(_products);
    sorted.sort((a, b) => (b.soldCount ?? 0).compareTo(a.soldCount ?? 0));
    return sorted.take(limit).toList();
  }

  // ==================== ERROR HANDLING ====================

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // ==================== RESET METHOD ====================

  // Reset provider (for logout)
  void reset() {
    _products = [];
    _farmerProducts = [];
    _cooperativeProducts = [];
    _wishlist = [];
    _featuredProducts = [];
    _popularProducts = [];
    _searchResults = [];
    _isLoading = false;
    _isLoadingFeatured = false;
    _isLoadingPopular = false;
    _isLoadingSearch = false;
    _errorMessage = '';
    _currentCategory = 'All';
    _searchQuery = '';
    _loadMockProducts();
    notifyListeners();
  }
}
