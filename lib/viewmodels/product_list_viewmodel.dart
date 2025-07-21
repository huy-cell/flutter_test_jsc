import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ProductListViewModel extends ChangeNotifier {
  List<Product> _products = [];
  bool _loading = false;

  List<Product> get products => _products;
  bool get isLoading => _loading;

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();

    try {
      final conn = await Connectivity().checkConnectivity();

      if (conn != ConnectivityResult.none) {
        try {
          final products = await ApiService.fetchProducts();

          if (products.isNotEmpty) {
            print("✅ API trả về ${products.length} sản phẩm.");
            _products = products;
            await DatabaseService.insertProducts(products);
          } else {
            print("⚠️ API trả về danh sách rỗng → dùng cache");
            _products = await DatabaseService.getCachedProducts();
          }
        } catch (apiError) {
          print("❌ Lỗi khi gọi API fetchProducts: $apiError");
          _products = await DatabaseService.getCachedProducts();
        }
      } else {
        print("📴 Không có kết nối mạng → dùng cache");
        _products = await DatabaseService.getCachedProducts();
      }
    } catch (e) {
      print("❌ Lỗi không xác định: $e");
      _products = await DatabaseService.getCachedProducts();
    }

    _loading = false;
    notifyListeners();
  }


  List<Category> _categories = [];
  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    _categories = await ApiService.fetchCategories();
    notifyListeners();
  }

}
