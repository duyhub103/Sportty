// UI test
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  void _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Gọi hàm login bên Provider
    final success = await authProvider.login(
      _emailController.text, 
      _passController.text
    );

    if (success) {
      // Chuyển sang màn hình Home (Tạm thời in ra console)
      print("LOGIN THÀNH CÔNG! User: ${authProvider.user}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đăng nhập thành công!")));
    } else {
      // Hiện lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? "Lỗi không xác định"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe state để hiện loading
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: Text("Đăng Nhập Sportty")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passController,
              decoration: InputDecoration(labelText: "Mật khẩu"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            isLoading 
              ? CircularProgressIndicator() // Nếu đang load thì xoay
              : ElevatedButton(
                  onPressed: _handleLogin,
                  child: Text("Đăng Nhập"),
                ),
          ],
        ),
      ),
    );
  }
}