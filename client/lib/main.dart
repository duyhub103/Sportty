import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Core
import 'core/storage/local_storage.dart';

// Import Data Layer
import 'data/services/auth_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/profile_service.dart';
import 'data/repositories/profile_repository.dart';

// Import Presentation Layer
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main/main_screen.dart';
import 'presentation/providers/profile_provider.dart';

void main() async {
  // Bắt buộc phải có dòng này khi hàm main() có dùng async/await
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo kho lưu trữ cục bộ
  await LocalStorage.init();

  final authRepository = AuthRepository(AuthService());
  final authProvider = AuthProvider(authRepository);
  final profileService = ProfileService();
  final profileRepository = ProfileRepository(profileService);

  runApp(
    // Bọc MultiProvider ở ngoài cùng để sau này nhét các State vào
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(profileRepository)),
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