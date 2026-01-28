// gửi http request
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/api_constants.dart';

class AuthService{
  // login
  Future<Map<String, dynamic>> login(String email, String password) async{
    try{
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200){
        return data; // trả về suscess: true, data: {token: ...}
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    }
    catch(e){
      throw Exception(e.toString());
    }
  }
}