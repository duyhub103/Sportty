import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  // Khai báo danh sách các môn thể thao có sẵn trong App
  final List<String> _availableSports = [
    '⚽ Bóng đá', '🏃 Chạy bộ', '🏓 Bóng bàn', 
    '🏸 Cầu lông', '🏀 Bóng rổ', '🏊 Bơi lội', '💪 Gym'
  ];

  // Mảng chứa các môn người dùng đã chọn
  List<String> _selectedSports = [];

  @override
  void initState() {
    super.initState();
    // Gắn dữ liệu cũ vào form ngay khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<ProfileProvider>().userProfile;
      if (user != null) {
        _displayNameController.text = user.displayName;
        _bioController.text = user.bio ?? '';
        // Load các môn thể thao cũ của user vào mảng selected
        setState(() {
          _selectedSports = List.from(user.sports); 
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _displayNameController, 
                label: 'Tên hiển thị', 
                icon: Icons.person
              ),
              CustomTextField(
                controller: _bioController, 
                label: 'Giới thiệu bản thân (Bio)', 
                icon: Icons.info
              ),
              // Hiển thị danh sách Chips có thể chọn nhiều
              Wrap(
                spacing: 8.0, // Khoảng cách ngang giữa các nút
                runSpacing: 8.0, // Khoảng cách dọc
                children: _availableSports.map((sport) {
                  // Kiểm tra xem môn này có nằm trong danh sách ĐÃ CHỌN không
                  final isSelected = _selectedSports.contains(sport);
                  return FilterChip(
                    label: Text(sport),
                    selected: isSelected,
                    selectedColor: Colors.green.withOpacity(0.2), // Màu nền khi được chọn
                    checkmarkColor: Colors.green, // Màu dấu tick
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSports.add(sport); // Bấm vào thì thêm
                        } else {
                          _selectedSports.remove(sport); // Bỏ chọn thì xóa
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isLoading ? null : () async {
                  // Tái sử dụng hàm update profile đã có trong Provider
                  final success = await provider.submitProfileSetup(
                    displayName: _displayNameController.text.trim(),
                    bio: _bioController.text.trim(),
                    sports: _selectedSports,
                  );

                  if (success) {
                    Fluttertoast.showToast(msg: "Cập nhật thành công!");
                    // Gọi lại hàm lấy Profile mới nhất để UI cập nhật ngay
                    if (context.mounted) {
                      await context.read<ProfileProvider>().fetchProfile();
                      Navigator.pop(context); // Quay lại Tab Hồ sơ
                    }
                  } else {
                    Fluttertoast.showToast(
                      msg: provider.errorMessage ?? "Lỗi cập nhật", 
                      backgroundColor: Colors.red
                    );
                  }
                },
                child: isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('LƯU THAY ĐỔI', style: TextStyle(fontSize: 16, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}