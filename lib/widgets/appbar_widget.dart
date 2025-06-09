import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart'; // Verify this path

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
    final bool showBackButton;

  const CustomAppBar({super.key, required this.title,     this.showBackButton = false,});

  @override
  Widget build(BuildContext context) {
    return AppBar(
       leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              color: Colors.black,
            )
          : null,
      title: Text(title),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        Consumer<CartProvider>(
          builder: (ctx, cart, child) => Stack(
            children: [
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      //print("Navigating to CartScreen with context: $context");
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CartScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}