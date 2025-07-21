# 📱 flutter_test_jsc – Ứng dụng quản lý sản phẩm

Ứng dụng Flutter đơn giản cho phép người dùng quản lý sản phẩm với các chức năng thêm, sửa, tìm kiếm, lọc theo danh mục và hỗ trợ chế độ offline bằng SQLite.

---

## 🎥 Video demo

![Preview](/gifdemo.gif)

---

## 🚀 Công nghệ sử dụng

| Công nghệ/Thư viện        | Mô tả                                                             |
|---------------------------|--------------------------------------------------------------------|
| **Flutter**               | Framework chính để xây dựng giao diện và logic ứng dụng           |
| **Provider**              | Quản lý trạng thái ứng dụng                                        |
| **Sqflite**               | Lưu trữ dữ liệu offline bằng SQLite                               |
| **Path Provider**         | Xác định đường dẫn lưu file cho SQLite                            |
| **Connectivity Plus**     | Kiểm tra trạng thái mạng để xử lý chế độ offline                  |
| **File Picker**           | Cho phép người dùng chọn ảnh từ thư viện                          |
| **Dart Model (toMap)**    | Chuyển đổi giữa SQLite/JSON ↔ Dart object                         |
| **Material Design**       | Dùng giao diện gốc từ Flutter                                     |

---

## 📂 Cấu trúc thư mục

```bash
lib/
├── models/               # Định nghĩa model: Product, Category  
├── services/             # API giả lập, SQLite  
├── viewmodels/           # Logic xử lý (Provider)  
├── screens/              # Giao diện chính chia theo màn hình  
│   ├── product_list/         # Màn hình danh sách sản phẩm  
│   ├── product_detail/       # Màn hình chi tiết sản phẩm  
│   └── add_edit_product/     # Màn hình thêm / chỉnh sửa sản phẩm  
├── main.dart             # Điểm khởi đầu ứng dụng  
```
---

## ✅ Tính năng nổi bật

- ✅ Hiển thị danh sách sản phẩm kèm hình ảnh, tên, giá, tồn kho
- ✅ Tìm kiếm theo tên (real-time search)
- ✅ Lọc theo danh mục (Dropdown filter)
- ✅ Thêm mới, chỉnh sửa sản phẩm với hình ảnh
- ✅ Pull to refresh danh sách
- ✅ Tự động cache dữ liệu bằng SQLite
- ✅ Chạy tốt khi offline

---

## 📱 Hướng dẫn chạy ứng dụng

### ⚙️ Yêu cầu môi trường

- Flutter SDK >= 3.x
- Android Studio hoặc VS Code
- Thiết bị Android hoặc iOS thật/emulator

### ▶️ Cài đặt và chạy

```bash
git clone https://github.com/huy-cell/flutter_test_jsc.git
cd flutter_test_jsc
flutter pub get
flutter run

🌐 Mock API (Node.js)
API giả lập được viết bằng Node.js để phục vụ kiểm thử.
cd mock_api
npm install
node server.js
API mặc định chạy ở: http://localhost:3000

📩 Liên hệ
Nếu bạn cần hỗ trợ hoặc góp ý:
📧 Email: huy.dev@example.com
📱 Zalo: 0912534481