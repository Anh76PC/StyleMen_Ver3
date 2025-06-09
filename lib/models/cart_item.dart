class CartItem {
  final String id;
  final String title;
  int quantity; // Đã thay đổi từ final sang int để có thể thay đổi
  final double price;
  final double? discountPrice; // Added discountPrice field
  final String imageUrl;
  final String? size;
  final String? color;
  final String? accessory;
  final String productId;
  final String? variantId; // Added variantId field

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.productId,
    this.size,
    this.color,
    this.accessory,
    this.variantId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'quantity': quantity,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrl': imageUrl,
      'size': size,
      'productId': productId,
      'color': color,
      'accessory': accessory,
      'variantId': variantId,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      title: map['title'],
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
      discountPrice: map['discountPrice'] != null ? (map['discountPrice'] as num).toDouble() : null,
      imageUrl: map['imageUrl'],
      size: map['size'],
      productId: map['productId'],
      color: map['color'],
      accessory: map['accessory'],
      variantId: map['variantId'],
    );
  }
}