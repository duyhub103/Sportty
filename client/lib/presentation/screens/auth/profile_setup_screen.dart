import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../main/main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 1; // Info & Avatar, 2: Location & Submit

  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  // Khai báo danh sách các môn thể thao có sẵn
  final List<String> _availableSports = [
    '⚽ Bóng đá', '🏃 Chạy bộ', '🏓 Bóng bàn', 
    '🏸 Cầu lông', '🏀 Bóng rổ', '🏊 Bơi lội', '💪 Gym'
  ];

  // Mảng chứa các môn người dùng chọn
  final List<String> _selectedSports = [];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiết lập Hồ sơ'),
        automaticallyImplyLeading: false, // Ẩn nút back
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh tiến trình Text đơn giản
              Text('Bước $_currentStep / 2', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),

              // Vùng hiển thị UI theo Step
              Expanded(
                child: SingleChildScrollView(
                  child: _currentStep == 1 ? _buildStep1(provider) : _buildStep2(provider),
                ),
              ),

              // Nút bấm điều hướng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep == 2)
                    TextButton(
                      onPressed: isLoading ? null : () => setState(() => _currentStep = 1),
                      child: const Text('Quay lại'),
                    )
                  else
                    const SizedBox.shrink(), // Dummy widget để giữ layout

                  ElevatedButton(
                    onPressed: isLoading ? null : () => _handleNextOrSubmit(provider),
                    child: isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                        : Text(_currentStep == 1 ? 'Tiếp tục' : 'Hoàn tất'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Giao diện Bước 1: Avatar, Tên, Bio, Sport
  Widget _buildStep1(ProfileProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
      children: [
        GestureDetector(
          onTap: () => provider.pickImage(),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: provider.avatarPath != null ? FileImage(File(provider.avatarPath!)) : null,
            child: provider.avatarPath == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) : null,
          ),
        ),
        const SizedBox(height: 10),
        const Text('Chạm để chọn Avatar'),
        const SizedBox(height: 20),
        CustomTextField(controller: _displayNameController, label: 'Tên hiển thị (Tinder Name)', icon: Icons.person),
        CustomTextField(controller: _bioController, label: 'Giới thiệu bản thân (Bio)', icon: Icons.info),
        const SizedBox(height: 16),
        const Text('Sở thích thể thao', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Render danh sách Chip chọn thể thao
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _availableSports.map((sport) {
            final isSelected = _selectedSports.contains(sport);
            return FilterChip(
              label: Text(sport),
              selected: isSelected,
              selectedColor: Colors.green.withOpacity(0.2),
              checkmarkColor: Colors.green,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSports.add(sport);
                  } else {
                    _selectedSports.remove(sport);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Giao diện Bước 2: GPS
  Widget _buildStep2(ProfileProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, size: 80, color: Colors.green),
        const SizedBox(height: 20),
        const Text(
          'Chúng tôi cần vị trí của bạn để tìm kiếm đồng đội xung quanh.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () async {
            final success = await provider.getCurrentLocation();
            if (success) {
              Fluttertoast.showToast(msg: "Đã lấy được tọa độ!");
            } else {
              Fluttertoast.showToast(msg: provider.errorMessage ?? "Lỗi GPS", backgroundColor: Colors.red);
            }
          },
          icon: const Icon(Icons.my_location),
          label: const Text('Lấy vị trí hiện tại'),
        ),
        const SizedBox(height: 20),
        if (provider.latitude != null)
          Text('Tọa độ: ${provider.latitude}, ${provider.longitude}', style: const TextStyle(color: Colors.green)),
      ],
    );
  }

  // nút Bấm dưới cùng
  void _handleNextOrSubmit(ProfileProvider provider) async {
    if (_currentStep == 1) {
      if (_displayNameController.text.isEmpty) {
        Fluttertoast.showToast(msg: "Vui lòng nhập Tên hiển thị");
        return;
      }
      // Chọn ít nhất 1 môn thể thao
      if (_selectedSports.isEmpty) {
        Fluttertoast.showToast(msg: "Vui lòng chọn ít nhất 1 môn thể thao");
        return;
      }
      setState(() => _currentStep = 2);
    } else {
      if (provider.latitude == null) {
        Fluttertoast.showToast(msg: "Vui lòng lấy vị trí trước khi hoàn tất");
        return;
      }

      // Gọi API cập nhật
      final success = await provider.submitProfileSetup(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        sports: _selectedSports,
      );

      if (success) {
        Fluttertoast.showToast(msg: "Cập nhật hồ sơ thành công!");
        // Chuyển sang MainScreen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        Fluttertoast.showToast(msg: provider.errorMessage ?? "Lỗi cập nhật", backgroundColor: Colors.red);
      }
    }
  }
}