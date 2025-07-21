import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY,
            name TEXT,
            description TEXT,
            price INTEGER,
            stock INTEGER,
            categoryId INTEGER,
            images TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY,
            name TEXT
          );
        ''');
      },
    );

    return _db!;
  }

  /// Xóa toàn bộ và lưu lại danh sách sản phẩm mới
  static Future<void> insertProducts(List<Product> products) async {
    final db = await getDatabase();
    final batch = db.batch();

    await db.delete('products');

    for (final p in products) {
      batch.insert(
        'products',
        p.toMap(), // toMap đã xử lý encode images
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Lấy danh sách sản phẩm từ SQLite (offline)
  static Future<List<Product>> getCachedProducts() async {
    final db = await getDatabase();
    final maps = await db.query('products');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Xoá toàn bộ bảng products
  static Future<void> clearCache() async {
    final db = await getDatabase();
    await db.delete('products');
  }
}
