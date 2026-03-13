import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'core/storage/local_storage.dart';

void main() async {
  // Bắt buộc phải có dòng này khi hàm main() có dùng async/await
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo kho lưu trữ cục bộ
  await LocalStorage.init();

  runApp(
    // Bọc MultiProvider ở ngoài cùng để sau này nhét các State vào
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const SporttyApp(),
    ),
  );
}

class SporttyApp extends StatelessWidget {
  const SporttyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // check token
    final hasToken = LocalStorage.getToken() != null;

    return MaterialApp(
      title: 'Sportty App',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: hasToken ? const MainScreen() : const LoginScreen(),
    );
  }
}