import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/category.dart';

class SubcategoryService {
  final PocketBase _pb = PocketBase('http://pocketbase.anhpc.online:8090');

  Future<List<SubCategory>> getSubcategoriesWithProductStatus(String categoryId) async {
    try {
      debugPrint('🔍 Fetching subcategories for category: $categoryId');
      
      final records = await _pb.collection('subcategories').getFullList(
        filter: 'category = "$categoryId"',
        fields: 'id,name,category,image', // Make sure to request image field
      );

      debugPrint('📦 Found ${records.length} subcategories');
      
      List<SubCategory> subcategories = [];
      
      for (var record in records) {
        final sub = SubCategory.fromJson(record.toJson());
        debugPrint('📸 Subcategory image: ${sub.image}'); // Debug log
        
        // Check for products
        final productsResult = await _pb.collection('products').getList(
          filter: 'sub_categories ~ "${sub.id}"',
          perPage: 1,
        );
        
        sub.hasProducts = productsResult.items.isNotEmpty;
        subcategories.add(sub);
        
        debugPrint('📑 Subcategory: ${sub.name}, Has Image: ${sub.image != null}, Has Products: ${sub.hasProducts}');
      }

      return subcategories;
    } catch (e) {
      debugPrint('❌ Error fetching subcategories: $e');
      return [];
    }
  }
}