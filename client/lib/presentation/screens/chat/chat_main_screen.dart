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
  @override
  void initState() {
    super.initState();
    // Tự động kéo API danh sách hộp thư khi mở tab này
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchInbox();
    });
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
        elevation: 0.5, // Tạo một đường kẻ mờ dưới AppBar
        centerTitle: false,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          // Đang tải dữ liệu
          if (provider.isLoadingInbox) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          // Nếu chưa có ai match
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

          // Hiển thị danh sách người đã Match
          return ListView.separated(
            itemCount: provider.inbox.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 76), // Kẻ vạch ngăn cách
            itemBuilder: (context, index) {
              final match = provider.inbox[index];
              
              // Format giờ đơn giản (VD: 14:05)
              final timeString = "${match.updatedAt.hour.toString().padLeft(2, '0')}:${match.updatedAt.minute.toString().padLeft(2, '0')}";

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                // Avatar người chat
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
                // Tên người chat
                title: Text(
                  match.partnerName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                // Tin nhắn cuối cùng (lời chào mời nếu chưa nhắn gì)
                subtitle: Text(
                  match.lastMessage.isNotEmpty ? match.lastMessage : 'Bắt đầu cuộc trò chuyện ngay!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Nếu dài quá thì hiện ...
                  style: TextStyle(
                    color: match.lastMessage.isEmpty ? Colors.green : Colors.grey[600],
                    fontStyle: match.lastMessage.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                // Thời gian
                trailing: Text(
                  timeString,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {                 
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => ChatDetailScreen(matchInfo: match)));
                },
              );
            },
          );
        },
      ),
    );
  }
}