import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../core/storage/local_storage.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // Xử lý Login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners(); // Báo cho UI hiện vòng xoay Loading

    try {
      final data = await AuthService.login(email, password);
      
      if (data['success'] == true) {
        // lưu Token vào LocalStorage để lần sau tự động gắn vào header
        final token = data['data']['token'];
        await LocalStorage.saveToken(token);
        
        // Dịch JSON thành UserModel
        _user = UserModel.fromJson(data['data']['user']);
        
        _isLoading = false;
        notifyListeners(); // Báo cho UI tắt Loading, chuyển trang
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Quăng lỗi ra UI để hiện Toast
    }
  }

  // Xử lý Đăng ký
  Future<void> register(String email, String password, String fullName) async {
    _isLoading = true;
    notifyListeners(); 

    try {
      final data = await AuthService.register(email, password, fullName);
      
      if (data['success'] == true) {
        // Đăng ký thành công
        // Backend sẽ không trả về Token ở bước này, tắt Loading để UI hiện thông báo và về màn Login.
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      // Nếu lỗi (VD: Email đã tồn tại, pass quá ngắn...)
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Xử lý Đăng xuất
  Future<void> logout() async {
    await LocalStorage.removeToken();
    _user = null;
    notifyListeners();
  }
}