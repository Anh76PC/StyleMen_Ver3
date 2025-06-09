import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_quanao/screens/product_detail_screen.dart';
import 'package:shop_quanao/screens/subcategory_products_screen.dart';
import 'package:shop_quanao/screens/user_profile_screen.dart';
import 'package:shop_quanao/services/product_service.dart';
import 'package:shop_quanao/services/subcategory_service.dart';
import 'package:shop_quanao/widgets/appbar_widget.dart';
import 'package:shop_quanao/widgets/category_bar_widget.dart';
import 'package:shop_quanao/widgets/product_card.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../widgets/bottom_widget.dart';
import '../services/category_service.dart';
import '../widgets/filter_bar_section.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final SubcategoryService _subcategoryService = SubcategoryService();
  final PageController _subCategoryController = PageController(initialPage: 0);

  List<Category> _categories = [];
  List<List<Product>> _productsPerCategory = [];
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;
  bool _isSearchVisible = false;

  List<String> selectedSizes = [];
  List<Color> selectedColors = [];
  RangeValues priceRange = const RangeValues(0, 2000000);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _categoryService.fetchCategories();
      for (var category in categories) {
        final subs = await _subcategoryService
            .getSubcategoriesWithProductStatus(category.id);
        category.subcategories = subs;
      }
      final allProducts = <List<Product>>[];
      for (var category in categories) {
        final products = await _productService.fetchProducts(
          categoryId: category.id,
        );
        allProducts.add(products);
      }
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _productsPerCategory = allProducts;
        _isLoading = false;
        _selectedCategoryIndex = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categories = [];
        _productsPerCategory = [];
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(int index) {
    if (_categories.isEmpty) return;
    setState(() {
      _selectedCategoryIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
    _subCategoryController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _handlePageChange(int pageIndex) {
    if (_categories.isEmpty) return;
    setState(() {
      _selectedCategoryIndex = pageIndex;
    });
    if (_subCategoryController.page?.round() != pageIndex) {
      _subCategoryController.jumpToPage(pageIndex);
    }
  }

  void _handleSubcategoryPageChange(int pageIndex) {
    if (_categories.isEmpty) return;
    setState(() {
      _selectedCategoryIndex = pageIndex;
    });
    if (_pageController.page?.round() != pageIndex) {
      _pageController.jumpToPage(pageIndex);
    }
  }

  void _handleSearchStateChanged(bool isActive) {
    setState(() {
      _isSearchVisible = isActive;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _subCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: const CustomAppBar(title: 'StyleMen'),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              if (!_isLoading && _categories.isNotEmpty)
                CategoryBar(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onCategorySelected: _onCategorySelected,
                ),
              FilterBarSection(
                selectedSizes: selectedSizes,
                selectedColors: selectedColors,
                priceRange: priceRange,
                setStateParent: setState,
                onPriceRangeChanged: (v) => setState(() => priceRange = v),
              ),
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _categories.length,
                      onPageChanged: _handlePageChange,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final products = _productsPerCategory[index];
                        return products.isEmpty
                            ? const Center(child: Text('Không có sản phẩm nào'))
                            : CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                    vertical: 12,
                                  ),
                                  sliver: SliverGrid(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      i,
                                    ) {
                                      final product = products[i];
                                      return ProductCard(
                                        product: product,
                                        onTap:
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        ProductDetailScreen(
                                                          product: product,
                                                        ),
                                              ),
                                            ),
                                      );
                                    }, childCount: products.length),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.4,
                                          mainAxisSpacing: 0,
                                          crossAxisSpacing: 0,
                                        ),
                                  ),
                                ),
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 120),
                                ),
                              ],
                            );
                      },
                    ),
                    if (_isSearchVisible)
                      PageView.builder(
                        controller: _subCategoryController,
                        itemCount: _categories.length,
                        onPageChanged: _handleSubcategoryPageChange,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, categoryIndex) {
                          final subcategories =
                              _categories[categoryIndex].getSubcategories;
                          return Container(
                            color: Colors.white,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 3,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                  ),
                              itemCount: subcategories.length,
                              itemBuilder: (context, index) {
                                final subcategory = subcategories[index];
                                return InkWell(
                                  onTap:
                                      subcategory.hasProducts
                                          ? () {
                                            setState(() {
                                              _isSearchVisible = false;
                                            });
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        SubcategoryProductsScreen(
                                                          subcategoryId:
                                                              subcategory.id,
                                                          subcategoryName:
                                                              subcategory.name,
                                                          categories:
                                                              _categories,
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
                                        if (subcategory.image != null)
                                          Container(
                                            width: 60,
                                            height: 60,
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                'http://pocketbase.anhpc.online:8090/api/files/subcategories/${subcategory.id}/${subcategory.image}',
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.image,
                                                      size: 30,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        Expanded(
                                          child: Text(
                                            subcategory.name,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  subcategory.hasProducts
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
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavigationBar(
              initialIndex: 0,
              onSearchStateChanged: _handleSearchStateChanged,
              showCloseIcon: _isSearchVisible,
            ),
          ),
        ],
      ),
    );
  }
}
