import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import '../../providers/post_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _sportController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedType = 'DISCUSSION'; // Mặc định là thảo luận
  DateTime? _selectedTime;
  String? _imagePath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _sportController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _pickDateTime() async {
    // Bước 1: Chọn ngày
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.green),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    // Bước 2: Chọn giờ
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.green),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _selectedTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Vui lòng nhập nội dung bài đăng');
      return;
    }
    if (_selectedType == 'MATCH') {
      if (_sportController.text.trim().isEmpty ||
          _locationController.text.trim().isEmpty ||
          _selectedTime == null) {
        Fluttertoast.showToast(msg: 'Bài tìm kèo cần đủ môn, địa điểm và thời gian');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<PostProvider>();
    final success = await provider.createPost(
      type: _selectedType,
      content: _contentController.text.trim(),
      sport: _selectedType == 'MATCH' ? _sportController.text.trim() : null,
      location: _selectedType == 'MATCH' ? _locationController.text.trim() : null,
      time: _selectedTime?.toUtc().toIso8601String(),
      imagePath: _imagePath,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Đăng bài thành công!', backgroundColor: Colors.green);
    } else {
      Fluttertoast.showToast(
        msg: provider.errorMessage ?? 'Đăng bài thất bại',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Tạo bài đăng',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSubmitting
                ? const Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Đăng', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Chọn loại bài ---
            const Text('Loại bài đăng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeButton('DISCUSSION', 'Thảo luận', Icons.forum_outlined, Colors.blue),
                const SizedBox(width: 10),
                _buildTypeButton('MATCH', 'Tìm kèo', Icons.sports_soccer, Colors.orange),
              ],
            ),
            const SizedBox(height: 20),

            // --- Nội dung ---
            const Text('Nội dung *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: _selectedType == 'MATCH'
                    ? 'Mô tả về trận đấu, trình độ yêu cầu...'
                    : 'Chia sẻ điều gì đó về thể thao...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Chỉ hiện khi chọn MATCH ---
            if (_selectedType == 'MATCH') ...[
              const Text('Thông tin trận đấu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),

              // Môn thể thao
              _buildTextField(
                controller: _sportController,
                hint: 'VD: Bóng đá, Cầu lông, Bóng rổ...',
                label: 'Môn thể thao *',
                icon: Icons.sports,
              ),
              const SizedBox(height: 12),

              // Địa điểm
              _buildTextField(
                controller: _locationController,
                hint: 'VD: Sân Chảo Lửa, Q.Tân Bình, TP.HCM',
                label: 'Địa điểm *',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),

              // Thời gian
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: _selectedTime != null ? Colors.green : Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        _selectedTime != null
                            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')} — ${_selectedTime!.day}/${_selectedTime!.month}/${_selectedTime!.year}'
                            : 'Chọn thời gian diễn ra *',
                        style: TextStyle(
                          color: _selectedTime != null ? Colors.black87 : Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // --- Upload ảnh ---
            const Text('Thêm ảnh (tuỳ chọn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            if (_imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_imagePath!), height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() => _imagePath = null),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Xoá ảnh', style: TextStyle(color: Colors.red)),
              ),
            ] else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 32, color: Colors.grey),
                        SizedBox(height: 6),
                        Text('Chọn ảnh', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
