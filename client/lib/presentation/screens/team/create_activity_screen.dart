import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/team_provider.dart';

class CreateActivityScreen extends StatefulWidget {
  final String teamId;
  const CreateActivityScreen({super.key, required this.teamId});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _contentController = TextEditingController();
  String _selectedType = 'NOTICE';
  final List<TextEditingController> _optionControllers = [];

  final List<Map<String, dynamic>> _types = [
    {'value': 'NOTICE', 'label': 'Thông báo', 'icon': Icons.campaign_outlined, 'color': Colors.green},
    {'value': 'VOTE', 'label': 'Bình chọn', 'icon': Icons.how_to_vote_outlined, 'color': Colors.blue},
    {'value': 'MATCH_SCHEDULE', 'label': 'Lịch thi đấu', 'icon': Icons.sports_soccer, 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    // Mặc định thêm 2 lựa chọn nếu là VOTE
    _optionControllers.add(TextEditingController());
    _optionControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _contentController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _needsOptions => _selectedType == 'VOTE';

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Vui lòng nhập nội dung');
      return;
    }

    List<String>? options;
    if (_needsOptions) {
      options = _optionControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (options.length < 2) {
        Fluttertoast.showToast(msg: 'Cần ít nhất 2 lựa chọn');
        return;
      }
    }

    final provider = context.read<TeamProvider>();
    final success = await provider.createActivity(
      widget.teamId,
      _selectedType,
      _contentController.text.trim(),
      options: options,
    );

    if (!mounted) return;

    if (success) {
      Fluttertoast.showToast(msg: 'Đã đăng bài!');
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
          msg: provider.errorMessage ?? 'Đăng bài thất bại',
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đăng bài',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.green),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: provider.isLoading ? null : _submit,
              child: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.green, strokeWidth: 2))
                  : const Text('Đăng',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chọn loại bài
            const Text('Loại bài đăng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: _types.map((type) {
                final isSelected = _selectedType == type['value'];
                final color = type['color'] as Color;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = type['value']),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey[300]!,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(type['icon'] as IconData,
                              color: isSelected ? color : Colors.grey,
                              size: 22),
                          const SizedBox(height: 4),
                          Text(
                            type['label'] as String,
                            style: TextStyle(
                              color: isSelected ? color : Colors.grey,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Nội dung
            const Text('Nội dung',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: _selectedType == 'NOTICE'
                    ? 'Nhập nội dung thông báo...'
                    : _selectedType == 'VOTE'
                        ? 'Câu hỏi bình chọn...'
                        : 'Mô tả lịch thi đấu...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // Options (chỉ hiện khi VOTE hoặc MATCH_SCHEDULE)
            if (_needsOptions) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedType == 'VOTE' ? 'Các lựa chọn' : 'Các khung giờ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() =>
                        _optionControllers.add(TextEditingController())),
                    icon: const Icon(Icons.add, color: Colors.green, size: 18),
                    label: const Text('Thêm',
                        style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._optionControllers.asMap().entries.map((entry) {
                final i = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Lựa chọn ${i + 1}',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      // Nút xóa (chỉ hiện khi có hơn 2 options)
                      if (_optionControllers.length > 2)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => setState(() {
                            controller.dispose();
                            _optionControllers.removeAt(i);
                          }),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}