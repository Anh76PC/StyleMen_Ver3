import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Added for number formatting
import 'package:shop_quanao/utils/convert_name_color.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../services/variant_service.dart';
import '../models/variant.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final double _shippingFee = 30000.0;
  final double _voucherDiscount = 10000.0;
  bool _useVoucher = true;

  // Store variants by productId -> color -> size -> Variant
  Map<String, Map<String, Map<String, Variant>>> _variantStock = {};
  Set<String> _loadedProductIds = {}; // Track loaded product IDs

  @override
  void initState() {
    super.initState();
    _preloadVariants();
  }

  Future<void> _preloadVariants() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cart.items.values.toList();
    final uniqueProductIds = cartItems.map((item) => item.productId).toSet();
    for (var productId in uniqueProductIds) {
      if (!_loadedProductIds.contains(productId)) {
        await _loadVariants(productId);
        _loadedProductIds.add(productId);
      }
    }
  }

  Future<void> _loadVariants(String productId) async {
    try {
      final variantService = VariantService();
      final variants = await variantService.fetchVariantsByProductId(productId);

      final Map<String, Map<String, Variant>> tempMap = {};
      for (var item in variants) {
        final color = item.color;
        final size = item.size;
        if (!tempMap.containsKey(color)) {
          tempMap[color] = {};
        }
        tempMap[color]![size] = item;
      }

      setState(() {
        _variantStock[productId] = tempMap; // Assign the nested map correctly
      });
    } catch (e) {
      debugPrint('Error loading variants: $e');
    }
  }

  void _showEditBottomSheet(BuildContext context, CartItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (ctx) {
        return FutureBuilder<void>(
          future: _loadVariants(item.productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final productVariants = _variantStock[item.productId] ?? {};
            List<String> colors = productVariants.keys.toList();
            String? selectedColor =
                item.color ?? (colors.isNotEmpty ? colors.first : null);
            String? selectedSize = selectedColor != null &&
                    productVariants[selectedColor]?.isNotEmpty == true
                ? item.size ?? productVariants[selectedColor]!.keys.first
                : null;
            List<String> localSizes =
                selectedColor != null && productVariants[selectedColor] != null
                    ? productVariants[selectedColor]!.keys.toList()
                    : [];
            int quantity = item.quantity;

            // Calculate total quantity of all items with the same productId
            final cart = Provider.of<CartProvider>(context, listen: false);
            int totalUsedQuantity = cart.items.values
                .where((cartItem) => cartItem.productId == item.productId)
                .map((cartItem) => cartItem.quantity)
                .reduce((a, b) => a + b);
            int currentItemQuantity = item.quantity;
            int remainingStockForProduct =
                productVariants.values.expand((colorMap) => colorMap.values)
                    .map((variant) => variant.stock)
                    .reduce((a, b) => a + b); // Total stock across all variants
            int availableStock = remainingStockForProduct - (totalUsedQuantity - currentItemQuantity);

            // Adjust maxStock for the selected variant
            int maxStock = selectedSize != null &&
                    selectedColor != null &&
                    productVariants[selectedColor]?[selectedSize] != null
                ? productVariants[selectedColor]![selectedSize]!.stock
                : 0;
            maxStock = maxStock > availableStock ? availableStock : maxStock;
            if (quantity > maxStock) quantity = maxStock;

            // Get the initial image URL based on the selected variant
            String? imageUrl = selectedColor != null &&
                    selectedSize != null &&
                    productVariants[selectedColor]?[selectedSize]?.imageProduct !=
                        null
                ? 'http://pocketbase.anhpc.online:8090/api/files/variants/${productVariants[selectedColor]![selectedSize]!.id}/${productVariants[selectedColor]![selectedSize]!.imageProduct}'
                : item.imageUrl;

            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        Image.network(
                          imageUrl.toString(),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      const SizedBox(height: 10),
                      const Text(
                        'Màu sắc',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8,
                        children: colors.map((color) {
                          return ChoiceChip(
                            backgroundColor: Colors.white,
                            selectedColor: Colors.grey.shade200,
                            label: Text(color),
                            selected: selectedColor == color,
                            onSelected: (_) {
                              setModalState(() {
                                selectedColor = color;
                                localSizes =
                                    productVariants[selectedColor]!.keys.toList();
                                selectedSize = localSizes.isNotEmpty
                                    ? localSizes.first
                                    : null;
                                // Recalculate maxStock for new selection
                                int newTotalUsedQuantity = cart.items.values
                                    .where((cartItem) =>
                                        cartItem.productId == item.productId)
                                    .map((cartItem) => cartItem.quantity)
                                    .reduce((a, b) => a + b);
                                int newAvailableStock =
                                    remainingStockForProduct -
                                        (newTotalUsedQuantity -
                                            currentItemQuantity);
                                maxStock = selectedSize != null &&
                                        productVariants[selectedColor]?[
                                                selectedSize] !=
                                            null
                                    ? productVariants[selectedColor]![
                                            selectedSize]!.stock
                                    : 0;
                                maxStock = maxStock > newAvailableStock
                                    ? newAvailableStock
                                    : maxStock;
                                if (quantity > maxStock) quantity = maxStock;
                                // Update image URL when color changes
                                imageUrl = selectedSize != null &&
                                        productVariants[selectedColor]![
                                                selectedSize]!.imageProduct !=
                                            null
                                    ? 'http://pocketbase.anhpc.online:8090/api/files/variants/${productVariants[selectedColor]![selectedSize]!.id}/${productVariants[selectedColor]![selectedSize]!.imageProduct}'
                                    : item.imageUrl;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey[300]),
                      const Text(
                        'Size ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8,
                        children: localSizes.map((size) {
                          return ChoiceChip(
                            backgroundColor: Colors.white,
                            selectedColor: Colors.grey.shade200,
                            label: Text(size.toUpperCase()),
                            selected: selectedSize == size,
                            onSelected: (_) {
                              setModalState(() {
                                selectedSize = size;
                                // Recalculate maxStock for new selection
                                int newTotalUsedQuantity = cart.items.values
                                    .where((cartItem) =>
                                        cartItem.productId == item.productId)
                                    .map((cartItem) => cartItem.quantity)
                                    .reduce((a, b) => a + b);
                                int newAvailableStock =
                                    remainingStockForProduct -
                                        (newTotalUsedQuantity -
                                            currentItemQuantity);
                                maxStock = productVariants[selectedColor]![
                                        selectedSize]!.stock;
                                maxStock = maxStock > newAvailableStock
                                    ? newAvailableStock
                                    : maxStock;
                                if (quantity > maxStock) quantity = maxStock;
                                // Update image URL when size changes
                                imageUrl = productVariants[selectedColor]![
                                            selectedSize]!.imageProduct !=
                                        null
                                    ? 'http://pocketbase.anhpc.online:8090/api/files/variants/${productVariants[selectedColor]![selectedSize]!.id}/${productVariants[selectedColor]![selectedSize]!.imageProduct}'
                                    : item.imageUrl;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey[300]),
                      const Text(
                        'Số lượng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: quantity > 1
                                ? () => setModalState(() => quantity--)
                                : null,
                          ),
                          Text('$quantity / $maxStock'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: quantity < maxStock
                                ? () => setModalState(() => quantity++)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
  padding: const EdgeInsets.symmetric(horizontal: 10.0),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange, // Nền cam
        foregroundColor: Colors.white,  // Chữ trắng
        padding: const EdgeInsets.symmetric(vertical: 12), // Tăng chiều cao nút nếu cần
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8), // Bo tròn nhẹ 8px
  ),
      ),
      onPressed: () {
        final cart = Provider.of<CartProvider>(
          context,
          listen: false,
        );

        bool itemExists = false;
        CartItem? existingItem;

        for (var cartItem in cart.items.values) {
          if (cartItem.productId == item.productId &&
              cartItem.color == selectedColor &&
              cartItem.size == selectedSize &&
              cartItem.id != item.id) {
            itemExists = true;
            existingItem = cartItem;
            break;
          }
        }

        if (itemExists && existingItem != null) {
          cart.updateCartItem(
            existingItem.id,
            CartItem(
              id: existingItem.id,
              title: existingItem.title,
              quantity: existingItem.quantity + quantity,
              price: existingItem.price,
              discountPrice: existingItem.discountPrice,
              imageUrl: imageUrl ?? existingItem.imageUrl,
              productId: existingItem.productId,
              size: selectedSize,
              color: selectedColor,
              variantId:
                  productVariants[selectedColor]?[selectedSize]?.id,
            ),
          );
          cart.removeItem(item.id);
        } else {
          cart.updateCartItem(
            item.id,
            CartItem(
              id: item.id,
              title: item.title,
              quantity: quantity,
              price: item.price,
              discountPrice: item.discountPrice,
              imageUrl: imageUrl ?? item.imageUrl,
              productId: item.productId,
              size: selectedSize,
              color: selectedColor,
              variantId:
                  productVariants[selectedColor]?[selectedSize]?.id,
            ),
          );
        }

        Navigator.pop(ctx);
      },
      child: const Text('Xác nhận'),
    ),
  ),
),

                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();
    final cartTotal = cart.totalAmount;
    final totalPayable =
        cartTotal ;

    // Validate and adjust quantities against stock on build
    for (var item in cartItems) {
      if (_loadedProductIds.contains(item.productId)) {
        final productVariants = _variantStock[item.productId] ?? {};
        final variant = productVariants[item.color]?[item.size];
        if (variant != null && item.quantity > variant.stock) {
          cart.updateCartItem(
            item.id,
            CartItem(
              id: item.id,
              title: item.title,
              quantity: variant.stock,
              price: item.price,
              discountPrice: item.discountPrice,
              imageUrl: item.imageUrl,
              productId: item.productId,
              size: item.size,
              color: item.color,
              variantId: item.variantId,
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Giỏ hàng (${cart.itemCount})'),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Giỏ hàng của bạn đang trống!'))
          : Container(
              color: Colors.grey[200], // Màu nền xám nhạt cho toàn bộ body
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (ctx, i) {
                        final item = cartItems[i];
                        final effectivePrice = item.discountPrice != null &&
                                item.discountPrice! > 0
                            ? item.discountPrice!
                            : item.price;
                        final totalItemPrice = effectivePrice * item.quantity;

                        // Load variants for this item if not already loaded
                        if (!_loadedProductIds.contains(item.productId)) {
                          _loadVariants(item.productId);
                          _loadedProductIds.add(item.productId);
                        }

                        final productVariants = _variantStock[item.productId] ?? {};
                        final maxStock =
                            productVariants[item.color]?[item.size]?.stock ?? 0;

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Column 1: Image (larger and taller)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.imageUrl.startsWith('http')
                                        ? item.imageUrl
                                        : 'http://pocketbase.anhpc.online:8090/api/files/variants/${item.id}/${item.imageUrl}',
                                    width: 80,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Column 2: Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Product name (bold black)
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Color and size (gray background, clickable)
                                      GestureDetector(
                                        onTap: () => _showEditBottomSheet(
                                          context,
                                          item,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: Colors.grey[200],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "${convertColorToVietnamese(item.color.toString())}, ${item.size != null ? item.size.toString().toUpperCase() : 'Chưa chọn'}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_drop_down,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Price and quantity controls
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              // Discounted price (red) and original price (gray with strikethrough)
                                              Text(
                                                'đ${NumberFormat('#.###').format(effectivePrice)}.000',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'đ${NumberFormat('#.###').format(item.price)}.000',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  decoration:
                                                      TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Quantity controls (-, quantity, +) with gray border
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  onTap: item.quantity > 1
                                                      ? () {
                                                          final cart = Provider.of<
                                                                  CartProvider>(
                                                              context,
                                                              listen: false);
                                                          cart.updateCartItem(
                                                            item.id,
                                                            CartItem(
                                                              id: item.id,
                                                              title: item.title,
                                                              quantity:
                                                                  item.quantity - 1,
                                                              price: item.price,
                                                              discountPrice:
                                                                  item.discountPrice,
                                                              imageUrl:
                                                                  item.imageUrl,
                                                              productId:
                                                                  item.productId,
                                                              size: item.size,
                                                              color: item.color,
                                                              variantId:
                                                                  item.variantId,
                                                            ),
                                                          );
                                                        }
                                                      : null,
                                                  child: Container(
                                                    width: 24,
                                                    height: 24,
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                        Icons.remove,
                                                        size: 14),
                                                  ),
                                                ),
                                                // Đường phân cách 1
                                                Container(
                                                  width: 1,
                                                  height: 20,
                                                  color: Colors.grey[300],
                                                ),
                                                Container(
                                                  width: 28,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    item.quantity.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 13),
                                                  ),
                                                ),
                                                // Đường phân cách 2
                                                Container(
                                                  width: 1,
                                                  height: 20,
                                                  color: Colors.grey[300],
                                                ),
                                                GestureDetector(
                                                  onTap: item.quantity < maxStock
                                                      ? () {
                                                          final cart = Provider.of<
                                                                  CartProvider>(
                                                              context,
                                                              listen: false);
                                                          cart.updateCartItem(
                                                            item.id,
                                                            CartItem(
                                                              id: item.id,
                                                              title: item.title,
                                                              quantity:
                                                                  item.quantity + 1,
                                                              price: item.price,
                                                              discountPrice:
                                                                  item.discountPrice,
                                                              imageUrl:
                                                                  item.imageUrl,
                                                              productId:
                                                                  item.productId,
                                                              size: item.size,
                                                              color: item.color,
                                                              variantId:
                                                                  item.variantId,
                                                            ),
                                                          );
                                                        }
                                                      : null,
                                                  child: Container(
                                                    width: 24,
                                                    height: 24,
                                                    alignment: Alignment.center,
                                                    child: const Icon(Icons.add,
                                                        size: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      // Set background color of ListView to white
                  ),
                ),
                const Divider(thickness: 8, color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thanh toán:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'đ${NumberFormat.decimalPattern('vi').format(totalPayable)}.000',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: const Text('ĐẶT HÀNG'),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
    );
  }
}