import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Hàm đăng ký
  Future<bool> register(String email, String password, String fullName) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authRepository.register(email, password, fullName);
      _setLoading(false);
      return true; 
    } catch (e) {
      // Bắt lỗi (ví dụ: Email đã tồn tại) từ Repository đẩy lên
      _errorMessage = e.toString().replaceAll('Exception: ', ''); 
      _setLoading(false);
      return false; 
    }
  }

  // Hàm login 
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authRepository.login(email, password);
      _setLoading(false);
      return true; 
    } catch (e) {
      // Bắt lỗi (ví dụ: Sai mật khẩu) từ Repository đẩy lên
      _errorMessage = e.toString().replaceAll('Exception: ', ''); 
      _setLoading(false);
      return false; 
    }
  }

  Future<void> logout() async {
    // Gọi Repository xóa token dưới Local Storage
    await _authRepository.logout();
    
    // Xóa dữ liệu user hiện tại đang lưu trong state
    _currentUser = null;
    
    // Thông báo cho UI biết state đã thay đổi
    notifyListeners();
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}