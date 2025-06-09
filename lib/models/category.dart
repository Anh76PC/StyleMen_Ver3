import 'package:flutter/foundation.dart';

class Category {
  final String id;
  final String name;
  List<SubCategory>? subcategories; // Make this mutable

  Category({
    required this.id,
    required this.name,
    this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      List<SubCategory>? subs;
      if (json['expand']?['subcategories'] != null) {
        final subList = json['expand']['subcategories'] as List;
        subs = subList.map((sub) => SubCategory.fromJson(sub)).toList();
      }

      return Category(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        subcategories: subs,
      );
    } catch (e) {
      debugPrint('Error parsing Category: $e');
      rethrow;
    }
  }

  List<SubCategory> get getSubcategories => subcategories ?? [];
}

class SubCategory {
  final String id;
  final String name;
  final String categoryId;
  final String? image;  // Add image field
  bool hasProducts;

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    this.image,  // Add to constructor
    this.hasProducts = false,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryId: json['category']?.toString() ?? '',
      image: json['image']?.toString(),  // Parse image from JSON
      hasProducts: false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': categoryId,
    'image': image,
  };
}
