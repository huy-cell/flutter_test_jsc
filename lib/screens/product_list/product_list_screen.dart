import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/product_list_viewmodel.dart';
import '../../../models/product.dart';
import '../../../models/category.dart';
import '../add_edit_product/add_edit_product_screen.dart';
import '../product_detail/product_detail_screen.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchTerm = '';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ProductListViewModel>();
    Future.microtask(() async {
      await vm.fetchProducts();
      await vm.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductListViewModel>();

    final filteredProducts = vm.products.where((product) {
      final matchName = product.name.toLowerCase().contains(_searchTerm.toLowerCase());
      final matchCategory = (_selectedCategoryId == null || _selectedCategoryId == -1)
          ? true
          : product.categoryId == _selectedCategoryId;
      return matchName && matchCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
        actions: [
          PopupMenuButton<int?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedCategoryId = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: -1, child: Text('Tất cả')),
              ...vm.categories.map((cat) => PopupMenuItem(
                value: cat.id,
                child: Text(cat.name),
              ))
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => setState(() => _searchTerm = value),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: vm.fetchProducts,
        child: Builder(
          builder: (context) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (filteredProducts.isEmpty) {
              return const Center(child: Text('Không có sản phẩm'));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  final thumbnail = product.images.isNotEmpty ? product.images[0] : null;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: thumbnail != null
                          ? (thumbnail.startsWith('http')
                          ? Image.network(thumbnail, width: 50, height: 50, fit: BoxFit.cover)
                          : Image.file(File(thumbnail), width: 50, height: 50, fit: BoxFit.cover))
                          : const Icon(Icons.image_not_supported),
                      title: Text(product.name),
                      subtitle: Text('${NumberFormat('#,###', 'vi_VN').format(product.price)} VNĐ • Kho: ${product.stock}'),

                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );

                        if (result == true) {
                          vm.fetchProducts();
                        }
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProductScreen()),
          );
          if (result == true) {
            vm.fetchProducts(); // <-- phải có dòng này
          }

        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
