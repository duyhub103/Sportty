import 'package:flutter/material.dart';

// Import 3 màn hình con
import '../discover/discover_screen.dart';
import '../chat/chat_main_screen.dart';
import '../profile/profile_main_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Biến lưu vị trí Tab đang được chọn (Mặc định 0 là Tab Khám phá)
  int _currentIndex = 0;

  // Danh sách 3 màn hình con
  final List<Widget> _pages = [
    const DiscoverScreen(),
    const ChatMainScreen(),
    const ProfileMainScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng IndexedStack để giữ nguyên State của các màn hình khi chuyển Tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // +bottom nav
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Khi bấm vào icon, cập nhật lại biến _currentIndex để chuyển màn hình
          setState(() {
            _currentIndex = index;
          });
        },
        // Cấu hình UI 
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // Giữ các icon cố định, không bị nhún nhảy
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Trò chuyện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}