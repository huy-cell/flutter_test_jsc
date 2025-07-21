import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/product_list_viewmodel.dart';
import 'screens/product_list/product_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductListViewModel()..fetchProducts(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý sản phẩm',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      debugShowCheckedModeBanner: false,
      home: const ProductListScreen(),
    );
  }
}
