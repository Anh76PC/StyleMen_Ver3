import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_quanao/providers/cart_provider.dart';
import 'package:shop_quanao/services/subcategory_service.dart';
import 'package:shop_quanao/utils/custom_painter.dart';
import 'package:shop_quanao/utils/snackbar_utils.dart';
import 'package:shop_quanao/widgets/bottom_widget.dart';
import 'package:shop_quanao/widgets/category_bar_widget.dart';
import 'package:shop_quanao/widgets/favorite_icon_widget.dart';
import 'package:shop_quanao/widgets/product_image_slider.dart';
import '../models/product.dart';
import '../widgets/appbar_widget.dart';
import '../services/category_service.dart';
import '../models/category.dart';
import 'subcategory_products_screen.dart';
import '../services/variant_service.dart';
import '../models/variant.dart';
import 'favorite_screen.dart';
import 'package:html_unescape/html_unescape.dart';


class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isSearchVisible = false;
  List<Category> _categories = [];
  int _selectedCategoryIndex = 0;
  final CategoryService _categoryService = CategoryService();
  final SubcategoryService _subcategoryService = SubcategoryService();
  final VariantService _variantService = VariantService();
  final PageController _pageController = PageController(initialPage: 0);
  List<Variant> _variants = [];
  Map<String, Map<String, int>> _colorSizeCounts = {};
  int _totalStock = 0;
  Variant? _selectedVariant;
  final ValueNotifier<String?> _primaryImageNotifier = ValueNotifier<String?>(
    null,
  );

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleSearchStateChanged(bool isActive) {
    setState(() {
      _isSearchVisible = isActive;
    });
  }

  void _handleBottomNavigationTap(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  final Map<String, Color> _colorMap = {
    'white': Colors.white,
    'black': Colors.black,
    'grey': Colors.grey,
    'pink': Colors.pink,
    'brown': Colors.brown,
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'blueaccent': Colors.blueAccent,
  };

  int _quantity = 1;
  String? _currentColor;
  String? _currentSize;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadVariants();
  }

  Future<void> _loadInitialData() async {
    try {
      final categories = await _categoryService.fetchCategories();
      for (var category in categories) {
        final subs = await _subcategoryService
            .getSubcategoriesWithProductStatus(category.id);
        category.subcategories = subs;
      }
      if (!mounted) return;
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
    }
  }

  Future<void> _loadVariants() async {
    try {
      final variants = await _variantService.fetchVariantsByProductId(
        widget.product.id,
      );
      final colorSizeCounts = <String, Map<String, int>>{};
      var totalStock = 0;

      for (var variant in variants) {
        colorSizeCounts[variant.color] ??= {};
        colorSizeCounts[variant.color]![variant.size] =
            (colorSizeCounts[variant.color]![variant.size] ?? 0) +
            variant.stock;
        totalStock += variant.stock;
      }

      if (!mounted) return;

      String? defaultColor;
      String? defaultSize;
      String? defaultImage;

      if (colorSizeCounts.isNotEmpty) {
        defaultColor = colorSizeCounts.keys.first;
        final sizesForColor = colorSizeCounts[defaultColor]?.entries.where(
          (entry) => entry.value > 0,
        );
        if (sizesForColor != null && sizesForColor.isNotEmpty) {
          defaultSize = sizesForColor.first.key;
        } else {
          defaultSize = colorSizeCounts[defaultColor]?.keys.first;
        }
      }

      Variant? selectedVariant;
      if (defaultColor != null && defaultSize != null) {
        selectedVariant = variants.firstWhere(
          (v) => v.color == defaultColor && v.size == defaultSize,
          orElse: () => variants.first,
        );
        defaultImage =
            selectedVariant.imageProduct != null
                ? 'http://pocketbase.anhpc.online:8090/api/files/variants/${selectedVariant.id}/${selectedVariant.imageProduct}'
                : null;
      }

      setState(() {
        _variants = variants;
        _colorSizeCounts = colorSizeCounts;
        _totalStock = totalStock;
        _currentColor = defaultColor;
        _currentSize = defaultSize;
        _selectedVariant = selectedVariant;
        _primaryImageNotifier.value = defaultImage;
        _quantity = 1;
      });
    } catch (e) {
      debugPrint('❌ Error loading variants: $e');
    }
  }

  void _updateColor(String color) {
    setState(() {
      _currentColor = color;

      final sizesForColor = _colorSizeCounts[color]?.entries.where(
        (entry) => entry.value > 0,
      );
      if (sizesForColor != null && sizesForColor.isNotEmpty) {
        _currentSize = sizesForColor.first.key;
      } else {
        _currentSize = _colorSizeCounts[color]?.keys.first;
      }

      _selectedVariant =
          _variants.isNotEmpty
              ? _variants.firstWhere(
                (v) => v.color == _currentColor && v.size == _currentSize,
                orElse: () => _variants.first,
              )
              : null;

      _primaryImageNotifier.value =
          _selectedVariant?.imageProduct != null
              ? 'http://pocketbase.anhpc.online:8090/api/files/variants/${_selectedVariant!.id}/${_selectedVariant!.imageProduct}'
              : null;

      _quantity = 1;
    });
  }

  void _updateSize(String size) {
    setState(() {
      _currentSize = size;

      _selectedVariant =
          _variants.isNotEmpty
              ? _variants.firstWhere(
                (v) => v.color == _currentColor && v.size == _currentSize,
                orElse: () => _variants.first,
              )
              : null;

      _primaryImageNotifier.value =
          _selectedVariant?.imageProduct != null
              ? 'http://pocketbase.anhpc.online:8090/api/files/variants/${_selectedVariant!.id}/${_selectedVariant!.imageProduct}'
              : null;

      _quantity = 1;
    });
  }

  void _updateQuantity(bool increase) {
    final currentStock = _colorSizeCounts[_currentColor]?[_currentSize] ?? 0;
    setState(() {
      if (increase) {
        if (_quantity < currentStock) {
          _quantity += 1;
        }
      } else {
        _quantity = _quantity > 1 ? _quantity - 1 : 1;
      }
    });
  }

  static const List<String> sampleReviews = [
    'Sản phẩm rất tốt, chất lượng vượt mong đợi!',
    'Giao hàng nhanh, đóng gói cẩn thận.',
    'Giá hơi cao nhưng đáng đồng tiền.',
  ];

  static const double averageRating = 4.5;

  @override
  void dispose() {
    _pageController.dispose();
    _primaryImageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images =
        (widget.product.image != null && widget.product.image!.isNotEmpty)
            ? widget.product.image!
            : [];

    return WillPopScope(
      onWillPop: () async {
        if (_isSearchVisible) {
          setState(() {
            _isSearchVisible = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'StyleMen', showBackButton: true),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImageSlider(
                    productId: widget.product.id,
                    images: images,
                    primaryImageNotifier: _primaryImageNotifier,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {},
                            ),
                            FavoriteIcon(productId: widget.product.id),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildVariantInfo(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPriceRow(),
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < averageRating.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '(999+)',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 6.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      color:
                                          _quantity == 1
                                              ? Colors.grey
                                              : Colors.black,
                                      size: 20,
                                    ),
                                    onPressed:
                                        _quantity == 1
                                            ? null
                                            : () => _updateQuantity(false),
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    '$_quantity',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 20),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 20,
                                      color:
                                          _quantity >=
                                                  (_colorSizeCounts[_currentColor]?[_currentSize] ??
                                                      0)
                                              ? Colors.grey
                                              : Colors.black,
                                    ),
                                    onPressed:
                                        _quantity >=
                                                (_colorSizeCounts[_currentColor]?[_currentSize] ??
                                                    0)
                                            ? null
                                            : () => _updateQuantity(true),
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Còn hàng',
                              style: TextStyle(color: Colors.green),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    textStyle: const TextStyle(fontSize: 16),
                                  ),
                                  onPressed: () {
                                    if (_selectedVariant == null) return;

                                    Provider.of<CartProvider>(
                                      context,
                                      listen: false,
                                    ).addItem(
                                      widget.product.id,
                                      widget.product.name,
                                      widget.product.price.toDouble(),
                                      widget.product.discountPrice?.toDouble(),
                                      'http://pocketbase.anhpc.online:8090/api/files/variants/${_selectedVariant!.id}/${_selectedVariant!.imageProduct ?? ''}',
                                      size: _selectedVariant!.size,
                                      color: _selectedVariant!.color,
                                      quantity: _quantity,
                                      variantId: _selectedVariant!.id,
                                      accessory: null,
                                    );
                                    showCustomSnackBar(
                                      context,
                                      'Đã thêm "${widget.product.name}" vào giỏ hàng',
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                    );
                                  },
                                  child: const Text('Thêm vào giỏ hàng'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Mô tả sản phẩm:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          HtmlUnescape().convert(widget.product.description),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Đánh giá trung bình:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...sampleReviews.map(
                          (review) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              '• $review',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isSearchVisible)
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    if (_categories.isNotEmpty)
                      CategoryBar(
                        categories: _categories,
                        selectedIndex: _selectedCategoryIndex,
                        onCategorySelected: _onCategorySelected,
                      ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _categories.length,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
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
                    ),
                  ],
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomNavigationBar(
                onSearchStateChanged: _handleSearchStateChanged,
                showCloseIcon: _isSearchVisible,
                onHomePressed: () => _handleBottomNavigationTap(0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.product.price.toStringAsFixed(0)}.000 VNĐ',
          style: const TextStyle(
            fontSize: 16,
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        Text(
          '${widget.product.discountPrice?.toStringAsFixed(0) ?? '0'}.000 VNĐ',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVariantInfo() {
    if (_colorSizeCounts.isEmpty) {
      return const Text(
        'Đang tải thông tin sản phẩm...',
        style: TextStyle(fontSize: 16),
      );
    }

    const List<String> sizeOrder = ['S', 'M', 'L', 'XL', 'XXL'];

    final allSizes =
        _colorSizeCounts.values
            .fold<Set<String>>(
              {},
              (previous, sizeMap) => previous..addAll(sizeMap.keys),
            )
            .toList()
          ..sort((a, b) {
            final indexA = sizeOrder.indexOf(a.toUpperCase());
            final indexB = sizeOrder.indexOf(b.toUpperCase());
            return (indexA == -1 ? 999 : indexA).compareTo(
              indexB == -1 ? 999 : indexB,
            );
          });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Wrap(
              spacing: 10,
              children:
                  _colorSizeCounts.keys.map((color) {
                    final isSelected = _currentColor == color;
                    return GestureDetector(
                      onTap: () => _updateColor(color),
                      child: Stack(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Container(
                              margin:
                                  isSelected
                                      ? const EdgeInsets.all(1)
                                      : const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color:
                                    _colorMap[color.toLowerCase()] ??
                                    Colors.grey,
                                shape: BoxShape.circle,
                                border:
                                    isSelected
                                        ? Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        )
                                        : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Wrap(
              spacing: 10,
              children:
                  allSizes.map((size) {
                    final stock = _colorSizeCounts[_currentColor]?[size] ?? 0;
                    final isSelected = _currentSize == size;
                    final isOutOfStock = stock == 0;

                    return GestureDetector(
                      onTap: isOutOfStock ? null : () => _updateSize(size),
                      child: Stack(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Container(
                              margin:
                                  isSelected && !isOutOfStock
                                      ? const EdgeInsets.all(1)
                                      : const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color:
                                    isSelected && !isOutOfStock
                                        ? Colors.black
                                        : Colors.white,
                                border:
                                    isSelected && !isOutOfStock
                                        ? Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        )
                                        : null,
                              ),
                              child: Center(
                                child: Text(
                                  size.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected && !isOutOfStock
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (isOutOfStock)
                            CustomPaint(
                              size: const Size(35, 35),
                              painter: StrikeThroughPainter(),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
