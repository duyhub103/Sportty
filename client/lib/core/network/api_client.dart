import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10), // Đợi 10s không thấy server trả lời là báo lỗi
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Tự động lấy Token và gắn vào mọi API trước khi gửi đi
          final token = LocalStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Bắt lỗi tập trung (Ví dụ: báo lỗi 401 thì tự động văng ra màn hình Login)
          if (e.response?.statusCode == 401) {
            LocalStorage.removeToken();
            // Xử lý chuyển trang ở UI sau
          }
          return handler.next(e);
        },
      ),
    );
}