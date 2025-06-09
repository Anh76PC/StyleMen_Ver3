import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryBar extends StatelessWidget {
  final List<Category> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  const CategoryBar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onCategorySelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3), // giảm padding top/bottom
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color: isSelected ? Colors.black : Colors.transparent,
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter, // giúp sát chữ hơn
                child: Text(
                  categories[index].name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}