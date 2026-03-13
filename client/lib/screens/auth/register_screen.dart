import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: SafeArea(
        child: SingleChildScrollView( // Chống lỗi bàn phím che khuất màn hình
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Họ và tên',
                  icon: Icons.person,
                ),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await context.read<AuthProvider>().register(
                                _emailController.text,
                                _passwordController.text,
                                _fullNameController.text,
                              );
                              Fluttertoast.showToast(msg: "Đăng ký thành công! Vui lòng đăng nhập.");
                              Navigator.pop(context); // Bắn ngược về màn hình Login
                            } catch (e) {
                              Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('ĐĂNG KÝ', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}