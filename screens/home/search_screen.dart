import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _recentSearches = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    // Load from local storage
    _recentSearches = [
      'Organic tomatoes',
      'Fresh milk',
      'Farm eggs',
      'Honey',
    ];
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isSearching = true;
    });
    
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.searchProducts(query);
    
    // Save to recent searches
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }
    
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final searchResults = productProvider.searchResults;
    final isSearchEmpty = _searchController.text.isEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: "Search products...",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
            onSubmitted: _performSearch,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _clearSearch();
                _focusNode.unfocus();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: _isSearching
          ? const LoadingWidget()
          : isSearchEmpty
              ? _buildEmptyState()
              : productProvider.isLoadingSearch
                  ? const LoadingWidget()
                  : searchResults.isEmpty
                      ? _buildNoResultsState()
                      : _buildSearchResults(searchResults),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        // Recent Searches
        if (_recentSearches.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Searches",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _recentSearches.clear();
                        });
                      },
                      child: const Text(
                        "Clear All",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              Padding (
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentSearches.map((search) {
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = search;
                        _performSearch(search);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Icon(Icons.history, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            search,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _recentSearches.remove(search);
                              });
                            },
                            child: Icon(Icons.close, size: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              )
            ],
          ),
        
        const SizedBox(height: 24),
        
        // Popular Categories
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Popular Categories",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Vegetables',
                  'Fruits',
                  'Dairy',
                  'Organic',
                  'Grains',
                  'Meat',
                  'Seeds',
                  'Equipment',
                ].map((category) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = category;
                      _performSearch(category);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(category),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "No products found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try searching with different keywords",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> results) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ProductCard(product: results[index]);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}