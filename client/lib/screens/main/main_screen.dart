import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ Sportty'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Nút Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Gọi hàm logout trong AuthProvider (Hàm này sẽ xóa Token)
              await context.read<AuthProvider>().logout();
              
              // Đẩy người dùng về lại màn hình Login và xóa sạch lịch sử trang
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Chào mừng sếp đến với Sportty!', 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}