import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../providers/discover_provider.dart';
import '../../../data/models/nearby_user_model.dart';
import '../../providers/profile_provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final CardSwiperController controller = CardSwiperController();

  @override
  void initState() {
    super.initState();
    // Tự động kéo API khi mở tab Khám phá
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Lấy thông tin user hiện tại
      final profile = context.read<ProfileProvider>().userProfile;
      
      // Check xem có tọa độ không rồi mới truyền vào
      if (profile != null && profile.latitude != null && profile.longitude != null) {
        context.read<DiscoverProvider>().fetchNearbyUsers(
          profile.latitude!, 
          profile.longitude!,
          distance: 50, // Test khoảng cách xa
        );
      } else {
        print("Chưa có tọa độ GPS của User");
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, 
      appBar: AppBar(
        title: const Text('Sportty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Consumer<DiscoverProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (provider.users.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: CardSwiper(
                  controller: controller,
                  cardsCount: provider.users.length,
                  onSwipe: (previousIndex, currentIndex, direction) => 
                      _onSwipe(provider, previousIndex, direction),
                  numberOfCardsDisplayed: provider.users.length > 1 ? 2 : 1, // Hiển thị hiệu ứng lớp thẻ bên dưới
                  backCardOffset: const Offset(0, 40),
                  padding: const EdgeInsets.all(16.0),
                  cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                    final user = provider.users[index];
                    return _buildCard(user);
                  },
                ),
              ),
              // Bộ nút bấm ở dưới cùng
              _buildBottomButtons(),
            ],
          );
        },
      ),
    );
  }

  // Giao diện Thẻ Bài
  Widget _buildCard(NearbyUserModel user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        image: DecorationImage(
          image: NetworkImage(user.avatar ?? 'https://via.placeholder.com/400'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Container(
        // Phủ Gradient đen từ dưới lên
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Colors.black87, Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.0, 0.5],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  'Cách ${user.distance} km',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            if (user.bio != null && user.bio!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(user.bio!, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: user.sports.map((sport) => 
                Chip(
                  label: Text(sport, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  side: BorderSide.none,
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Nút bấm bên dưới
  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: "pass_btn",
            onPressed: () => controller.swipe(CardSwiperDirection.left),
            backgroundColor: Colors.white,
            child: const Icon(Icons.close, color: Colors.red, size: 30),
          ),
          FloatingActionButton(
            heroTag: "like_btn",
            onPressed: () => controller.swipe(CardSwiperDirection.right),
            backgroundColor: Colors.white,
            child: const Icon(Icons.favorite, color: Colors.green, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Không tìm thấy ai xung quanh bạn', style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }

  // XỬ LÝ KHI QUẸT
  bool _onSwipe(DiscoverProvider provider, int previousIndex, CardSwiperDirection direction) {
    // Chỉ lấy hướng Trái (dislike) và Phải (Like)
    if (direction != CardSwiperDirection.right && direction != CardSwiperDirection.left) return true;

    final userSwiped = provider.users[previousIndex];
    final type = direction == CardSwiperDirection.right ? 'LIKE' : 'DISLIKE';

    // Gọi API ngầm trong nền
    provider.handleSwipe(userSwiped.id, type).then((result) {
      // nếu match thành công
      if (result != null && result.isMatch) {
        _showMatchDialog(userSwiped);
      }
    });

    return true; // Cho phép thẻ bay đi
  }

  void _showMatchDialog(NearbyUserModel matchUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.pinkAccent,
        title: const Text('It\'s a Match! 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn và ${matchUser.displayName} đã thích nhau. Vào nhắn tin rủ kèo ngay!',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tắt popup
            child: const Text('Tiếp tục quẹt', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Nhảy sang màn hình Chat với matchUser.id
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Nhắn tin', style: TextStyle(color: Colors.pinkAccent)),
          )
        ],
      ),
    );
  }
}