import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController stockCtrl;
  int? selectedCategory;
  List<String> imageUrls = [];

  bool get isEditing => widget.product != null;

  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    nameCtrl = TextEditingController(text: p?.name ?? '');
    descCtrl = TextEditingController(text: p?.description ?? '');
    priceCtrl = TextEditingController(
      text: p != null ? NumberFormat('#,###', 'vi_VN').format(p.price) : '',
    );
    stockCtrl = TextEditingController(text: p?.stock.toString() ?? '');
    selectedCategory = p?.categoryId;
    imageUrls = p?.images ?? [];
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final result = await ApiService.fetchCategories();
      setState(() => categories = result);
    } catch (_) {}
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.paths.length <= 5) {
      setState(() {
        imageUrls = result.paths.whereType<String>().toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tối đa 5 ảnh')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id ?? 0,
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      price: int.tryParse(priceCtrl.text.replaceAll('.', '').trim()) ?? 0,
      stock: int.tryParse(stockCtrl.text.trim()) ?? 0,
      categoryId: selectedCategory ?? 0,
      images: imageUrls,
    );

    bool success = false;
    if (isEditing) {
      success = await ApiService.updateProduct(product);
    } else {
      success = await ApiService.createProduct(product);
    }

    if (success) {
      await DatabaseService.clearCache();

      await Future.delayed(const Duration(milliseconds: 300)); // Đợi server ổn định

      if (mounted) Navigator.pop(context, true);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                controller: descCtrl,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá (VND)'),
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                validator: (v) {
                  final raw = v?.replaceAll('.', '');
                  final value = int.tryParse(raw ?? '');
                  if (value == null || value <= 0) return 'Phải > 0';
                  if (value % 1000 != 0) return 'Phải chia hết cho 1000';
                  return null;
                },
              ),
              TextFormField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tồn kho'),
                validator: (v) {
                  final value = int.tryParse(v ?? '');
                  if (value == null) return 'Bắt buộc';
                  if (value < 0 || value > 10000) {
                    return 'Từ 0 đến 10000';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items: categories
                    .map((cat) => DropdownMenuItem<int>(
                  value: cat.id,
                  child: Text(cat.name),
                ))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator: (v) => v == null ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text('Chọn ảnh (tối đa 5)'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: imageUrls
                          .map((path) => Image.file(
                        File(path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Huỷ'),
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Lưu'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final formatter = NumberFormat('#,###', 'vi_VN');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return newValue;

    final number = int.parse(digitsOnly);
    final formatted = formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
