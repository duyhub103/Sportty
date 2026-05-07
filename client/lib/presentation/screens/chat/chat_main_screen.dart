import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import 'chat_detail_screen.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchInbox();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Trò chuyện',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingInbox) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (provider.inbox.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có cuộc trò chuyện nào.\nHãy sang tab Khám phá để tìm đồng đội nhé!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Lọc client-side theo tên bạn match
          final filtered = _searchQuery.isEmpty
              ? provider.inbox
              : provider.inbox
                  .where((m) => m.partnerName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bạn bè...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // --- Danh sách ---
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Không tìm thấy "$_searchQuery"',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 76),
                        itemBuilder: (context, index) {
                          final match = filtered[index];
                          final timeString =
                              "${match.updatedAt.hour.toString().padLeft(2, '0')}:${match.updatedAt.minute.toString().padLeft(2, '0')}";

                          return Dismissible(
                            key: Key(match.id),
                            direction: DismissDirection.endToStart, // Vuốt sang trái
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              color: Colors.red,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_remove, color: Colors.white, size: 26),
                                  SizedBox(height: 4),
                                  Text('Hủy kết bạn',
                                      style: TextStyle(color: Colors.white, fontSize: 11)),
                                ],
                              ),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hủy tương hợp?'),
                                  content: Text(
                                      'Bạn có chắc muốn hủy kết bạn với ${match.partnerName}?\nTất cả tin nhắn sẽ bị xóa.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Huỷ'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) async {
                              final success = await context.read<ChatProvider>().unmatch(match.id);
                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Hủy thất bại'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: ListTile(                              // ← Giữ nguyên ListTile cũ
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: match.partnerAvatar.isNotEmpty
                                    ? NetworkImage(match.partnerAvatar)
                                    : null,
                                child: match.partnerAvatar.isEmpty
                                    ? const Icon(Icons.person, color: Colors.grey, size: 30)
                                    : null,
                              ),
                              title: Text(
                                match.partnerName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                match.lastMessage.isNotEmpty
                                    ? match.lastMessage
                                    : 'Bắt đầu cuộc trò chuyện ngay!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: match.lastMessage.isEmpty ? Colors.green : Colors.grey[600],
                                  fontStyle: match.lastMessage.isEmpty ? FontStyle.italic : FontStyle.normal,
                                ),
                              ),
                              trailing: Text(timeString,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ChatDetailScreen(matchInfo: match)),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
