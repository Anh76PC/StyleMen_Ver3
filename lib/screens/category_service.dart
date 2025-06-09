import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/category.dart';

class CategoryService {
  final PocketBase _pb = PocketBase('http://pocketbase.anhpc.online:8090');

  Future<List<Category>> fetchCategories() async {
    try {
      debugPrint('📡 Starting categories fetch...');
      
      final records = await _pb.collection('categories').getFullList(
        sort: '-name',
        expand: 'subcategories', // Make sure this matches your PocketBase relation field name
        query: {
          'expand': 'subcategories',
        },
      );

      debugPrint('✅ Successfully fetched ${records.length} categories');

      final categories = records.map((record) => Category.fromJson(record.toJson()))
          .toList()
        ..sort((a, b) {
          if (a.id == '91167l972q8swln') return -1;
          if (b.id == '91167l972q8swln') return 1;
          return a.name.compareTo(b.name);
        });

      // Log categories and their subcategories
      for (var category in categories) {
        debugPrint('📋 Category: ${category.name}, Subcategories: ${category.getSubcategories.length}');
      }
      
      return categories;

    } catch (e, stack) {
      debugPrint('❌ Error fetching categories: $e');
      debugPrint('🧱 Stack trace: $stack');
      // Rethrow the error to be handled by the UI layer
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Optional: Add method to fetch a single category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final record = await _pb.collection('categories').getOne(id);
      return Category.fromJson(record.toJson());
    } catch (e) {
      debugPrint('❌ Error fetching category by ID: $e');
      return null;
    }
  }

  // Optional: Add method to search categories
  Future<List<Category>> searchCategories(String query) async {
    try {
      final records = await _pb.collection('categories').getList(
        page: 1,
        perPage: 20,
        filter: 'name ~ "$query"',
      );

      return records.items
          .map((record) => Category.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error searching categories: $e');
      return [];
    }
  }
  Future<void> checkSubcategoriesProducts(Category category) async {
  try {
    for (var subcategory in category.getSubcategories) {
      final products = await _pb.collection('products').getList(
        filter: 'sub_categories ~ "${subcategory.id}"',
        perPage: 1,
      );
      subcategory.hasProducts = products.items.isNotEmpty;
    }
  } catch (e) {
    debugPrint('❌ Error checking subcategories products: $e');
  }
}
}