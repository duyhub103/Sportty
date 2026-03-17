import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class AuthService {
  // Đăng Nhập
  Future<Response> login(String email, String password) async {
    return await ApiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  // Hàm Đăng Ký
  Future<Response> register(String email, String password, String fullName) async {
    return await ApiClient.dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'fullName': fullName,
    });
  }
}