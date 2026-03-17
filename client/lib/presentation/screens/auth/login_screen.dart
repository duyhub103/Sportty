import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';
import '../main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Dùng để bắt lỗi bỏ trống ô nhập

  @override
  Widget build(BuildContext context) {
    // Lắng nghe xem Provider có đang báo "Loading" không
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Sportty',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 40),
                
                // Lôi viên gạch ra xài
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                ),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  icon: Icons.lock,
                  isPassword: true,
                ),
                
                const SizedBox(height: 20),
                
                // Nút Đăng nhập
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading
                      ? null // Nếu đang loading thì khóa nút lại
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              // Gọi bộ não AuthProvider
                              await context.read<AuthProvider>().login(
                                _emailController.text,
                                _passwordController.text,
                              );
                              Fluttertoast.showToast(msg: "Đăng nhập thành công!");
                              // main_screen
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context, 
                                  MaterialPageRoute(builder: (_) => const MainScreen())
                                );
                              }
                            } catch (e) {
                              Fluttertoast.showToast(
                                msg: e.toString(), 
                                backgroundColor: Colors.red,
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                
                const SizedBox(height: 20),
                
                // Nút chuyển sang màn Đăng ký
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}