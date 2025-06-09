import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/product.dart';

class ProductService {
  final PocketBase _pb = PocketBase('http://pocketbase.anhpc.online:8090');

  Future<List<Product>> fetchProducts({String? categoryId, String? subcategoryId}) async {
    try {
      String? filter;
      if (categoryId != null) {
        filter = '_categories = "$categoryId"';
      }
      if (subcategoryId != null) {
        filter = 'sub_categories ~ "$subcategoryId"';
      }

      final records = await _pb.collection('products').getList(
        expand: '_categories,sub_categories',
        filter: filter,
      );

      return records.items.map((record) => Product.fromJson(record.toJson())).toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

}