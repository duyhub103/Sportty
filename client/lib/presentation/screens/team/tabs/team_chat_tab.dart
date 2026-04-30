import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/team_provider.dart';
import '../../../../data/models/team_model.dart';
import '../../../../data/models/chat_model.dart';

class TeamChatTab extends StatefulWidget {
  final TeamDetailModel team;
  final String currentUserId;

  const TeamChatTab({
    super.key,
    required this.team,
    required this.currentUserId,
  });

  @override
  State<TeamChatTab> createState() => _TeamChatTabState();
}

class _TeamChatTabState extends State<TeamChatTab> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().fetchTeamMessages(widget.team.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamProvider>();

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: provider.teamMessages.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có tin nhắn nào.\nHãy bắt đầu cuộc trò chuyện!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.teamMessages.length,
                    itemBuilder: (context, index) {
                      final message = provider.teamMessages[index];
                      final isMe = message.senderId == widget.currentUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
          ),
          _buildInputArea(provider),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar người khác (hiện bên trái)
            if (!isMe) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.green[50],
                backgroundImage: message.senderAvatar.isNotEmpty
                    ? NetworkImage(message.senderAvatar)
                    : null,
                child: message.senderAvatar.isEmpty
                    ? const Icon(Icons.person, size: 14, color: Colors.green)
                    : null,
              ),
              const SizedBox(width: 6),
            ],

            // Bubble
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Tên người gửi (chỉ hiện khi không phải mình)
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(
                        message.senderName,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Spacer bên phải cho tin nhắn người khác
            if (!isMe) const SizedBox(width: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(TeamProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(provider),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.green,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(provider),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(TeamProvider provider) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    provider.sendTeamMessage(widget.team.id, widget.currentUserId, text);
    _messageController.clear();
  }
}