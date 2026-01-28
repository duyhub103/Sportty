// quản lý trạng thái
//  nhiệm vụ cầu nói giữa service và UI, UI lắng nghe provider này để cập nhật loading

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isloading = false;
  String? _errorMessage;
  Map<String, dynamic>? _user; // lưu thông tin user tạm thời sau login

  bool get isLoading => _isloading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;

  Future<bool> login(String email, String password) async {
    _isloading = true;
    _errorMessage = null;
    notifyListeners(); // thông báo UI cập nhật trạng thái loading (hiện vòng xoay)

    try{
      final result = await _authService.login(email, password);
      // login thành cnông
      _user = result['data']['user']; // lưu thông tin user
      // TODO: Lưu token vào Shared Preferences

      _isloading = false;
      notifyListeners();
      return true; // báo oke

    }catch (e){
      _isloading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }

  }
}
