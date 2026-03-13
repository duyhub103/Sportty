import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  // Gọi hàm này 1 lần duy nhất lúc mở app
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // lưu Token
  static Future<void> saveToken(String token) async {
    await _prefs.setString('token', token);
  }

  // Lấy Token 
  static String? getToken() {
    return _prefs.getString('token');
  }

  // Đăng xuất (Xóa Token)
  static Future<void> removeToken() async {
    await _prefs.remove('token');
  }
}