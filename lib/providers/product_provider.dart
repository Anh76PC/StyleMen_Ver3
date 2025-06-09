import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => [..._products];

  void loadProducts(List<Product> newProducts) {
    _products.clear();
    _products.addAll(newProducts);
    notifyListeners();
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  Product? findById(String id) {
    return _products.firstWhere(
      (p) => p.id == id,
      orElse: () => Product(id: '', name: '', price: 0, description: ''),
    );
  }
}
