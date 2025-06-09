import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../widgets/product_card.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/keep_alive_wrapper.dart';

class CategoryPageView extends StatelessWidget {
  final PageController pageController;
  final List<Category> categories;
  final List<List<Product>> productsPerCategory;
  final Function(int) onPageChanged;

  const CategoryPageView({
    super.key,
    required this.pageController,
    required this.categories,
    required this.productsPerCategory,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: 2000,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final realIndex = index % categories.length;
        final products = productsPerCategory[realIndex];

        return KeepAliveWrapper(
          child: products.isEmpty
              ? const Center(
                  child: Text('Không có sản phẩm nào trong danh mục này'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.only(bottom: 150),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, i) {
                    final product = products[i];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}