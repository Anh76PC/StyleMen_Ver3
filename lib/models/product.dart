class Product {
  final String id;
  final String name;
  final List<String>? image;
  final int price;
  final int? discountPrice;
  final String description;
  final String? categoryName;
  final String? subCategoryName;

  Product({
    required this.id,
    required this.name,
    this.image,
    required this.price,
    this.discountPrice,
    required this.description,
    this.categoryName,
    this.subCategoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final expanded = json['expand'] ?? {};
    final category = expanded['_categories'] is Map ? expanded['_categories'] : null;
    final subCategory = expanded['sub_categories'] is Map ? expanded['sub_categories'] : null;

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: (json['image'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      price: (json['price'] is num) ? json['price'].toInt() : 0,
      discountPrice: (json['discount_price'] is num) ? json['discount_price'].toInt() : null,
      description: json['description']?.toString() ?? '',
      categoryName: category != null ? category['name']?.toString() : null,
      subCategoryName: subCategory != null ? subCategory['name']?.toString() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'price': price,
        'discountPrice': discountPrice,
        'description': description,
        'categoryName': categoryName,
        'subCategoryName': subCategoryName,
      };
}