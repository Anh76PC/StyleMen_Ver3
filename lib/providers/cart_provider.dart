import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      final effectivePrice = (cartItem.discountPrice != null && cartItem.discountPrice! > 0)
          ? cartItem.discountPrice!
          : cartItem.price;
      total += effectivePrice * cartItem.quantity;
    });
    return total;
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void addItem(
    String productId,
    String title,
    double price,
    double? discountPrice,
    String imageUrl, {
    String? size,
    String? color,
    String? accessory,
    required int quantity,
    required String variantId,
  }) {
    final cartId = "$productId-$variantId"; // Use variantId for unique cart ID

    if (_items.containsKey(cartId)) {
      _items.update(
        cartId,
        (existingItem) => CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          title: existingItem.title,
          quantity: existingItem.quantity + quantity,
          price: existingItem.price,
          discountPrice: existingItem.discountPrice,
          imageUrl: existingItem.imageUrl,
          size: existingItem.size,
          color: existingItem.color,
          variantId: existingItem.variantId,
          accessory: existingItem.accessory,
        ),
      );
    } else {
      _items.putIfAbsent(
        cartId,
        () => CartItem(
          id: cartId,
          productId: productId,
          title: title,
          quantity: quantity,
          price: price,
          discountPrice: discountPrice,
          imageUrl: imageUrl,
          size: size,
          color: color,
          variantId: variantId,
          accessory: accessory,
        ),
      );
    }
    notifyListeners();
  }

  void updateCartItem(String id, CartItem updatedItem) {
    if (_items.containsKey(id)) {
      _items[id] = updatedItem;
      notifyListeners();
    }
  }
}