import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../providers/discover_provider.dart';
import '../../../data/models/nearby_user_model.dart';
import '../../providers/profile_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../data/models/chat_model.dart';
import '../chat/chat_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final CardSwiperController controller = CardSwiperController();
  ProfileProvider? _profileProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileProvider = context.read<ProfileProvider>();
      _profileProvider!.addListener(_onProfileChanged); // ← Lắng nghe profile thay đổi
      _tryFetchNearbyUsers(); // Thử ngay lần đầu
    });
  }
  

  @override
  void dispose() {
    _profileProvider?.removeListener(_onProfileChanged);
    controller.dispose();
    super.dispose();
  }

  // Gọi lại mỗi khi ProfileProvider notify (profile vừa load xong)
  void _onProfileChanged() {
    _tryFetchNearbyUsers();
  }

  // Logic fetch — chỉ chạy khi có tọa độ và chưa có users
  void _tryFetchNearbyUsers() {
    if (!mounted) return;
    final profile = context.read<ProfileProvider>().userProfile;
    final discoverProvider = context.read<DiscoverProvider>();
    if (profile != null &&
        profile.latitude != null &&
        profile.longitude != null &&
        discoverProvider.users.isEmpty &&
        !discoverProvider.isLoading) {
      discoverProvider.fetchNearbyUsers(
        profile.latitude!,
        profile.longitude!,
        distance: 50,
      );
    }
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
    final hasAvatar = user.avatar != null && user.avatar!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Nền gradient tối làm fallback khi không có avatar
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: hasAvatar
            ? DecorationImage(
                image: NetworkImage(user.avatar!),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(hasAvatar ? 0.75 : 0.4),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0.0, 0.6],
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Cách ${user.distance} km',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
            if (user.bio != null && user.bio!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  user.bio!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // Môn thể thao: thay chip emoji bằng chip text gọn gàng
            if (user.sports.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: user.sports.map((sport) =>
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30, width: 1),
                    ),
                    child: Text(
                      sport,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ).toList(),
              ),
            ],
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

    provider.removeUser(userSwiped.id);

    // Gọi API ngầm trong nền
    provider.handleSwipe(userSwiped.id, type).then((result) {
      // nếu match thành công
      if (result != null && result.isMatch) {
        _showMatchDialog(userSwiped, result.matchId!);
      }
    });

    return true; // Cho phép thẻ bay đi
  }

  // void _showMatchDialog(NearbyUserModel matchUser) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Colors.pinkAccent,
  //       title: const Text('It\'s a Match! 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  //       content: Text(
  //         'Bạn và ${matchUser.displayName} đã thích nhau. Vào nhắn tin rủ kèo ngay!',
  //         style: const TextStyle(color: Colors.white),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context), // Tắt popup
  //           child: const Text('Tiếp tục quẹt', style: TextStyle(color: Colors.white)),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context); 
  //             Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(matchId: result.matchId)));
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
  //           child: const Text('Nhắn tin', style: TextStyle(color: Colors.pinkAccent)),
  //         )
  //       ],
  //     ),
  //   );
  // }

  void _showMatchDialog(NearbyUserModel matchUser, String matchId) {
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục quẹt', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 

              // TẠO ĐỐI TƯỢNG MatchModel TẠM THỜI ĐỂ TRUYỀN ĐI
              final tempMatchInfo = MatchModel(
                id: matchId,
                lastMessage: '',
                updatedAt: DateTime.now(),
                partnerId: matchUser.id,
                partnerName: matchUser.displayName,
                partnerAvatar: matchUser.avatar ?? '',
              );

              // CHUYỂN TRANG VỚI THAM SỐ ĐÚNG 👇
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(matchInfo: tempMatchInfo)
                )
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Nhắn tin', style: TextStyle(color: Colors.pinkAccent)),
          )
        ],
      ),
    );
  }
}