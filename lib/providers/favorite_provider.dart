import 'package:flutter/foundation.dart';

class FavoriteProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  Future<void> toggleFavorite(String productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _saveFavorites() async {
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.setStringList('favorites', _favoriteIds.toList());
  }

  Future<void> loadFavorites() async {
   // final prefs = await SharedPreferences.getInstance();
    // final List<String>? saved = prefs.getStringList('favorites');
    // if (saved != null) {
    //   _favoriteIds.clear();
    //   _favoriteIds.addAll(saved);
    //   notifyListeners();
    // }
  }
}
