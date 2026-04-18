import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
class CategoryScreen extends StatefulWidget {
  final String category;
  
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'newest';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _loadProducts();
  }

  void _loadProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.filterByCategory(_selectedCategory);
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  _buildSortOption("Newest", "newest"),
                  _buildSortOption("Price: Low to High", "price_asc"),
                  _buildSortOption("Price: High to Low", "price_desc"),
                  _buildSortOption("Popularity", "popular"),
                  _buildSortOption("Rating", "rating"),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      leading: Radio<String>(
        value: value,
        groupValue: _sortBy,
        onChanged: (newValue) {
          setState(() {
            _sortBy = newValue!;
          });
          final productProvider = Provider.of<ProductProvider>(context, listen: false);
          productProvider.sortProducts(_sortBy);
          Navigator.pop(context);
        },
        activeColor: AppColors.primary,
      ),
      title: Text(label),
      trailing: _sortBy == value
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final filteredProducts = productProvider.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedCategory == 'All' ? "All Products" : _selectedCategory,
        ),
        actions: [
          // Sort Button
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
          // View Toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.grid_view : Icons.list),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildCategoryFilter(),
        ),
      ),
      body: productProvider.isLoading
          ? const LoadingWidget()
          : filteredProducts.isEmpty
              ? _buildEmptyState()
              : _isGridView
                  ? _buildGridView(filteredProducts)
                  : _buildListView(filteredProducts),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.categories.length,
        itemBuilder: (context, index) {
          final category = AppConstants.categories[index];
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

  Widget _buildGridView(List<dynamic> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }

  Widget _buildListView(List<dynamic> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ProductCard(product: products[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "No products in this category",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for new products",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}