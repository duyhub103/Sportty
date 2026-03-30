import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../../data/models/chat_model.dart';

class ChatDetailScreen extends StatefulWidget {
  final MatchModel matchInfo; // Nhận data của người đang chat từ màn hình trước truyền sang

  const ChatDetailScreen({super.key, required this.matchInfo});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 1. Tải lịch sử tin nhắn cũ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchMessages(widget.matchInfo.id);
    });

    // 2. Mở cổng Socket.IO để hóng tin nhắn mới của phòng này
    context.read<ChatProvider>().setupChatSocket(widget.matchInfo.id);
  }

  @override
  void dispose() {
    // 3. Tắt cổng lắng nghe khi thoát ra ngoài màn hình Inbox
    context.read<ChatProvider>().leaveChatSocket(widget.matchInfo.id);
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.matchInfo.partnerAvatar.isNotEmpty
                  ? NetworkImage(widget.matchInfo.partnerAvatar)
                  : null,
              child: widget.matchInfo.partnerAvatar.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              widget.matchInfo.partnerName,
              style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- KHU VỰC HIỂN THỊ TIN NHẮN ---
            Expanded(
              child: ListView.builder(
                // reverse: true giúp danh sách luôn cuộn xuống đáy (tin mới nhất ở dưới cùng)
                reverse: true, 
                padding: const EdgeInsets.all(16),
                itemCount: provider.currentMessages.length,
                itemBuilder: (context, index) {
                  final message = provider.currentMessages[index];
                  
                  // check tin nhắn: ID người gửi KHÁC với ID của partner
                  final isMe = message.senderId != widget.matchInfo.partnerId;

                  return _buildMessageBubble(message, isMe);
                },
              ),
            ),

            // --- KHU VỰC NHẬP TIN NHẮN ---
            _buildInputArea(provider),
          ],
        ),
      ),
    );
  }

  // Giao diện Bong bóng chat
  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.green : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Khung gõ chữ
  Widget _buildInputArea(ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (value) => _sendMessage(provider),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.green,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(provider),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatProvider provider) {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      // Gọi API gửi tin nhắn qua Provider
      provider.sendMessage(widget.matchInfo.id, text);
      _messageController.clear();
    }
  }
}