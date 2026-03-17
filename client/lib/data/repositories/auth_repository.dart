import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../core/storage/local_storage.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<UserModel> register(String email, String password, String fullName) async {
    try {
      final response = await _authService.register(email, password, fullName);
      final responseData = response.data; // JSON có dạng {success, message, data: {...}}

      if (responseData['success'] == true) {
         // Parse thông tin user
        final user = UserModel.fromJson(responseData['data']);
        
        // save token nếu có
        if (responseData['data']['token'] != null) {
          await LocalStorage.saveToken(responseData['data']['token']);
        }
        
        return user;
      } else {
        throw Exception(responseData['message'] ?? 'Đăng ký thất bại');
      }
    } on DioException catch (e) {
      // Bắt lỗi
      final errorMessage = e.response?.data['message'] ?? 'Lỗi kết nối Server';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi hệ thống: $e');
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      final responseData = response.data; 

      if (responseData['success'] == true) {
        // Tùy cấu trúc API login của em, thường sẽ là responseData['data']['user']
        final userData = responseData['data']['user'] ?? responseData['data'];
        final token = responseData['data']['token'];

        final user = UserModel.fromJson(userData);

        if (token != null) {
          await LocalStorage.saveToken(token);
        }

        return user;
      } else {
        throw Exception(responseData['message'] ?? 'Đăng nhập thất bại');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Lỗi kết nối Server';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi hệ thống: $e');
    }
  }

  // Hàm logout
  Future<void> logout() async {
    await LocalStorage.removeToken();
  }
}