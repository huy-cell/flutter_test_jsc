import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../config/app_config.dart';

class ApiService {
  static final String base = AppConfig.baseUrl;

  static Future<List<Product>> fetchProducts() async {
    final res = await http.get(Uri.parse('$base/products'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      return list.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải sản phẩm');
    }
  }

  static Future<List<Category>> fetchCategories() async {
    final res = await http.get(Uri.parse('$base/categories'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      return list.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải danh mục');
    }
  }

  static Future<bool> deleteProduct(int id) async {
    final url = Uri.parse('${AppConfig.baseUrl}/products/$id');
    final response = await http.delete(url);

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> createProduct(Product product) async {
    final url = Uri.parse('${AppConfig.baseUrl}/products');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    print('CREATE PRODUCT status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response.statusCode == 201;
  }


  static Future<bool> updateProduct(Product product) async {
    final url = Uri.parse('${AppConfig.baseUrl}/products/${product.id}');
    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    return res.statusCode == 200;
  }



}
