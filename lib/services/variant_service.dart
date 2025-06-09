import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/variant.dart';

class VariantService {
  static const String baseUrl = 'http://pocketbase.anhpc.online:8090/api';

  Future<List<Variant>> fetchVariantsByProductId(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/collections/variants/records?filter=(product="$productId")'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;
        return items.map((item) => Variant.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load variants');
      }
    } catch (e) {
      throw Exception('Error fetching variants: $e');
    }
  }
}