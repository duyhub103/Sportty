import 'package:flutter/material.dart';
import 'package:my_sport_app/presentation/providers/chat_provider.dart';
import 'package:provider/provider.dart';


// Import 3 màn hình con
import '../../../core/network/socket_client.dart';
import '../../providers/team_provider.dart';
import '../discover/discover_screen.dart';
import '../chat/chat_main_screen.dart';
import '../feed/feed_screen.dart';
import '../team/team_list_screen.dart';
import '../profile/profile_main_screen.dart';
import '../notification/notification_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().setupGlobalNotificationSocket();
    });
  }

  @override
  void dispose() {
    SocketClient().socket?.off('receive_notification');
    SocketClient().socket?.off('team_joined');
    super.dispose();
  }

  // Biến lưu vị trí Tab đang được chọn (Mặc định 0 là Tab Khám phá)
  int _currentIndex = 0;

  // Danh sách 3 màn hình con
  final List<Widget> _pages = [
    const DiscoverScreen(),
    const ChatMainScreen(),
    const FeedScreen(),
    const TeamListScreen(),
    const ProfileMainScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng IndexedStack để giữ nguyên State của các màn hình khi chuyển Tab
      body: Stack(
        children: [
          // Các màn hình tab
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // Nút chuông nổi trên tất cả màn hình trừ profile
          if (_currentIndex != 4)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8, // Tránh status bar
              right: 16,
              child: Consumer<TeamProvider>(
                builder: (context, provider, _) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.black87,
                            size: 22,
                          ),
                        ),
                        // Badge đỏ số lượng chưa đọc
                        if (provider.unreadCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                provider.unreadCount > 99 ? '99+' : '${provider.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),

      // +bottom nav
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() { 
            _currentIndex = index;  // Khi bấm vào icon, cập nhật lại biến _currentIndex để chuyển màn hình
          });

          if (index == 1) {
            // Provider gọi lại API lấy danh sách match mới nhất ngay lập tức
            context.read<ChatProvider>().fetchInbox();
          }
        },
        // Cấu hình UI 
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // Giữ các icon cố định, không bị nhún nhảy
        
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore), // home_filled
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Trò chuyện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),   // ← Icon tab mới
            label: 'Bảng tin',
          ),
          BottomNavigationBarItem(
            icon: Consumer<TeamProvider>(
              builder: (_, tp, __) => Badge(
                isLabelVisible: tp.unreadCount > 0,
                label: Text('${tp.unreadCount}'),
                child: const Icon(Icons.groups),
              ),
            ),
            label: 'Đội',
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