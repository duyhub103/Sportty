import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileMainScreen extends StatefulWidget {
  const ProfileMainScreen({super.key});

  @override
  State<ProfileMainScreen> createState() => _ProfileMainScreenState();
}

class _ProfileMainScreenState extends State<ProfileMainScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động gọi API lấy profile khi mở màn hình này
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          // Nút Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
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
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = provider.userProfile;
          if (user == null) {
            return const Center(child: Text('Không tải được thông tin'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null || user.avatar!.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 12),
                
                // Tên & Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.displayName.isNotEmpty ? user.displayName : user.fullName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_square, size: 20, color: Colors.grey),
                      onPressed: () {
                        // Chuyển sang màn hình Edit
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const EditProfileScreen())
                        );
                      },
                    ),
                  ],
                ),
                Text(user.email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),

                // Bio
                if (user.bio != null && user.bio!.isNotEmpty)
                  Text(user.bio!, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),

                // Sở thích (Tags)
                if (user.sports.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    children: user.sports.map((sport) => Chip(label: Text(sport))).toList(),
                  ),
                const Divider(height: 40),

                // Nút Thêm ảnh vào Gallery
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await provider.addImageToGallery();
                    if (success) {
                      Fluttertoast.showToast(msg: "Thêm ảnh thành công!");
                    } else if (provider.errorMessage != null) {
                      Fluttertoast.showToast(msg: provider.errorMessage!, backgroundColor: Colors.red);
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Thêm ảnh vào khoảnh khắc'),
                ),
                const SizedBox(height: 16),

                // Gallery (Hiển thị dạng Grid)
                if (provider.isLoading) const CircularProgressIndicator(),
                if (user.gallery.isEmpty)
                  const Text('Chưa có ảnh nào trong khoảnh khắc')
                else
                  GridView.builder(
                    shrinkWrap: true, // Quan trọng khi GridView nằm trong ScrollView
                    physics: const NeverScrollableScrollPhysics(), 
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 ảnh 1 hàng
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: user.gallery.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          user.gallery[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}