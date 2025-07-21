import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../add_edit_product/add_edit_product_screen.dart'; // Đường dẫn có thể khác tuỳ dự án
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductScreen(product: product),
                ),
              );

              if (result == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã cập nhật sản phẩm")),
                );
                Navigator.pop(context, true); // Trả về `true` về ProductListScreen
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carousel
            if (product.images.isNotEmpty)
              CarouselSlider(
                items: product.images.map((url) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Colors.white), // nền trắng để ẩn checkerboard
                      url.startsWith('http')
                          ? Image.network(
                        url,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 100);
                        },
                      )
                          : Image.file(
                        File(url),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 100);
                        },
                      ),
                    ],
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 250,
                  enlargeCenterPage: true,
                  autoPlay: true,
                ),
              )
            else
              const Icon(Icons.image_not_supported, size: 150),

            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Tên sản phẩm"),
                    subtitle: Text(product.name),
                  ),
                  ListTile(
                    title: const Text("Mô tả"),
                    subtitle: Text(product.description),
                  ),
                  ListTile(
                    title: const Text("Giá"),
                    subtitle: Text('${NumberFormat('#,###', 'vi_VN').format(product.price)} VNĐ • Kho: ${product.stock}'),
                  ),
                  ListTile(
                    title: const Text("Tồn kho"),
                    subtitle: Text("${product.stock}"),
                  ),
                  ListTile(
                    title: const Text("Danh mục"),
                    subtitle: Text("${product.categoryId}"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xoá"),
        content: const Text("Bạn có chắc muốn xoá sản phẩm này?"),
        actions: [
          TextButton(
            child: const Text("Huỷ"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Xoá", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog xác nhận

              final success = await ApiService.deleteProduct(product.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã xoá sản phẩm")),
                );

                // ✅ Đợi server xử lý xong hoàn toàn
                await Future.delayed(const Duration(milliseconds: 300));

                Navigator.pop(context, true); // Trả về `true` về ProductListScreen
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Xoá thất bại")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
