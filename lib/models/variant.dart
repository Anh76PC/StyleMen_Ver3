class Variant {
  final String id;
  final String color;
  final String size;
  final int stock;
  final String? imageProduct;
  final String productId;

  Variant({
    required this.id,
    required this.color,
    required this.size,
    required this.stock,
    this.imageProduct,
    required this.productId,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'],
      color: json['color'],
      size: json['size'],
      stock: json['stock'],
      imageProduct: json['image_product'],
      productId: json['product'],
    );
  }
}