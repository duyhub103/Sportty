import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

class AuthService {
  // Đăng Nhập
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data; // Trả về {success, message, data: {token, user}}
    } on DioException catch (e) {
      // Bắt lỗi từ Backend (Ví dụ: Sai pass, không tìm thấy user)
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối Server');
    }
  }

  // Hàm Đăng Ký
  static Future<Map<String, dynamic>> register(String email, String password, String fullName) async {
    try {
      final response = await ApiClient.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'fullName': fullName,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối Server');
    }
  }
}