import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/colors.dart';

class ProductListScreen extends StatefulWidget {
  final String? category;
  
  const ProductListScreen({super.key, this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'newest';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Vegetables', 'Fruits', 'Grains', 'Dairy', 'Meat', 'Organic'];
  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Newest', 'value': 'newest'},
    {'label': 'Price: Low to High', 'value': 'price_asc'},
    {'label': 'Price: High to Low', 'value': 'price_desc'},
    {'label': 'Popularity', 'value': 'popular'},
    {'label': 'Rating', 'value': 'rating'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.category != null && widget.category != 'featured' && widget.category != 'popular') {
      _selectedCategory = widget.category!;
    }
    _loadProducts();
  }

  void _loadProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    if (widget.category == 'featured') {
      productProvider.fetchFeaturedProducts();
    } else if (widget.category == 'popular') {
      productProvider.fetchPopularProducts();
    } else {
      productProvider.fetchProducts();
      productProvider.filterByCategory(_selectedCategory);
    }
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sort By",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ..._sortOptions.map((option) => ListTile(
                leading: Radio<String>(
                  value: option['value'],
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    final productProvider = Provider.of<ProductProvider>(context, listen: false);
                    productProvider.sortProducts(_sortBy);
                    Navigator.pop(context);
                  },
                  activeColor: AppColors.primary,
                ),
                title: Text(option['label']),
                trailing: _sortBy == option['value']
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
              )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    List products = [];
    if (widget.category == 'featured') {
      products = productProvider.featuredProducts;
    } else if (widget.category == 'popular') {
      products = productProvider.popularProducts;
    } else {
      products = productProvider.filteredProducts;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == 'featured' 
            ? 'Featured Products' 
            : widget.category == 'popular'
                ? 'Popular Products'
                : 'All Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
        bottom: widget.category == null || (widget.category != 'featured' && widget.category != 'popular')
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: _buildCategoryFilter(),
              )
            : null,
      ),
      body: Column(
        children: [
          if (widget.category == null || (widget.category != 'featured' && widget.category != 'popular'))
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                            final productProvider = Provider.of<ProductProvider>(context, listen: false);
                            productProvider.searchProducts('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  final productProvider = Provider.of<ProductProvider>(context, listen: false);
                  productProvider.searchProducts(value);
                },
              ),
            ),
          Expanded(
            child: productProvider.isLoading
                ? const LoadingWidget()
                : products.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: products[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                productProvider.filterByCategory(category);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _selectedCategory == category ? AppColors.primary : Colors.grey.shade700,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
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
            "Try adjusting your filters",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}