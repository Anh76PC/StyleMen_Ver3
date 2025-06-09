import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final favoriteProducts =
        productProvider.products
            .where((product) => favoriteProvider.isFavorite(product.id))
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Sản phẩm yêu thích")),
      body:
          favoriteProducts.isEmpty
              ? const Center(child: Text('Không có sản phẩm yêu thích'))
              : ListView.builder(
                itemCount: favoriteProducts.length,
                itemBuilder: (ctx, i) {
                  final product = favoriteProducts[i];
                  return ListTile(
                    leading:
                        product.image != null
                            ? Image.network(
                              product.image! as String,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.image),
                    title: Text(product.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
