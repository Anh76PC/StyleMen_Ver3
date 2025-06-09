// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:shop_quanao/models/product.dart';
import 'package:shop_quanao/models/category.dart';
import 'package:shop_quanao/screens/product_detail_screen.dart';
import 'package:shop_quanao/services/product_service.dart';
import 'package:shop_quanao/services/category_service.dart';
import 'package:shop_quanao/widgets/appbar_widget.dart';
import 'package:shop_quanao/widgets/bottom_widget.dart';
import 'package:shop_quanao/widgets/category_bar_widget.dart';
import 'package:shop_quanao/widgets/product_card.dart';

class SubcategoryProductsScreen extends StatefulWidget {
  final String subcategoryId;
  final String subcategoryName;
  final List<Category> categories; // Add this

  const SubcategoryProductsScreen({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.categories, // Add this
  });

  @override
  State<SubcategoryProductsScreen> createState() => _SubcategoryProductsScreenState();
}

class _SubcategoryProductsScreenState extends State<SubcategoryProductsScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isSearchVisible = false;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _categories = widget.categories;
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.fetchProducts(
        subcategoryId: widget.subcategoryId,
      );
      
      if (!mounted) return;
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading subcategory products: $e');
      if (!mounted) return;
      setState(() {
        _products = [];
        _isLoading = false;
      });
    }
  }

  void _handleSearchStateChanged(bool isActive) {
    setState(() {
      _isSearchVisible = isActive;
    });
  }

  void _handleBottomNavigationTap(int index) {
    if (index == 0) {
      // Home icon tapped - navigate back to home
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (_isSearchVisible) {
          // If search is visible, close it instead of going back
          setState(() {
            _isSearchVisible = false;
          });
          return false;
        }
        // Otherwise, allow normal back navigation
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: widget.subcategoryName),
        body: Stack(
          children: [
            // Main product grid
            if (!_isSearchVisible)
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? const Center(child: Text('Không có sản phẩm nào'))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          itemCount: _products.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ProductCard(
                              product: product,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: product),
                                ),
                              ),
                            );
                          },
                        ),

            // Search overlay
            if (_isSearchVisible)
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    CategoryBar(
                      categories: _categories,
                      selectedIndex: _selectedCategoryIndex,
                      onCategorySelected: (index) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                    ),
                    Expanded(
                      child: PageView.builder(
                        itemCount: _categories.length,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        itemBuilder: (context, categoryIndex) {
                          final subcategories = _categories[categoryIndex].getSubcategories;
                          return Container(
                            color: Colors.white,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              itemCount: subcategories.length,
                              itemBuilder: (context, index) {
                                final subcategory = subcategories[index];
                                return InkWell(
                                  onTap: subcategory.hasProducts
                                      ? () {
                                          setState(() {
                                            _isSearchVisible = false;
                                          });
                                          // Use push instead of pushReplacement to maintain navigation stack
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SubcategoryProductsScreen(
                                                subcategoryId: subcategory.id,
                                                subcategoryName: subcategory.name,
                                                categories: _categories,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        // Subcategory Image
                                        if (subcategory.image != null)
                                          Container(
                                            width: 60,
                                            height: 60,
                                            margin: const EdgeInsets.only(right: 12),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                'http://pocketbase.anhpc.online:8090/api/files/subcategories/${subcategory.id}/${subcategory.image}',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  debugPrint('❌ Error loading image for ${subcategory.name}: $error');
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(Icons.image, size: 30),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        // Subcategory Name
                                        Expanded(
                                          child: Text(
                                            subcategory.name,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: subcategory.hasProducts 
                                                  ? Colors.black 
                                                  : Colors.black54,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        bottomNavigationBar: CustomNavigationBar(
          onSearchStateChanged: _handleSearchStateChanged,
          showCloseIcon: _isSearchVisible,
          onHomePressed: () => _handleBottomNavigationTap(0),
        ),
      ),
    );
  }
}