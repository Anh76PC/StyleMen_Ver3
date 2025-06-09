import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:shop_quanao/providers/favorite_provider.dart';
import 'package:shop_quanao/providers/product_provider.dart';
import 'package:shop_quanao/screens/home_screen.dart';
import 'package:shop_quanao/providers/cart_provider.dart';
import 'package:shop_quanao/services/auth_service.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  final favoriteProvider = FavoriteProvider();
  await favoriteProvider.loadFavorites();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider<FavoriteProvider>.value(value: favoriteProvider),
        ChangeNotifierProvider(create: (_) => ProductProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthService>(context, listen: false).checkLoginStatus();
    return GetMaterialApp(
      title: 'StyleMen',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
        iconTheme: const IconThemeData(color: Colors.black),
        snackBarTheme: SnackBarThemeData( // Thêm snackBarTheme để đảm bảo giao diện
          backgroundColor: Colors.green,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: ScaffoldMessenger( // Bao bọc HomeScreen trong ScaffoldMessenger
        child: const HomeScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}