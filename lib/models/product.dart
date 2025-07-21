import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final int stock;
  final int categoryId;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.images,
  });

  // Dùng khi lấy từ JSON API
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      stock: json['stock'],
      categoryId: json['categoryId'],
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "stock": stock,
      "categoryId": categoryId,
      "images": images,
    };
  }

  // Dùng để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'categoryId': categoryId,
      'images': jsonEncode(images), // Encode List<String> an toàn
    };
  }

  // Dùng để đọc từ SQLite
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      stock: map['stock'],
      categoryId: map['categoryId'],
      images: List<String>.from(jsonDecode(map['images'])),
    );
  }
}
