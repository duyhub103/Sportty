// Model cho Hộp thư (Inbox)
class MatchModel {
  final String id; // matchId (conversationId)
  final String lastMessage;
  final DateTime updatedAt;
  final String partnerId;
  final String partnerName;
  final String partnerAvatar;

  MatchModel({
    required this.id,
    required this.lastMessage,
    required this.updatedAt,
    required this.partnerId,
    required this.partnerName,
    required this.partnerAvatar,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final partner = json['partner'] ?? {};
    return MatchModel(
      id: json['id'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      partnerId: partner['id'] ?? '',
      partnerName: partner['displayName'] ?? 'Người dùng',
      partnerAvatar: partner['avatar'] ?? '',
    );
  }
}

// Model cho Từng Tin nhắn
class MessageModel {
  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['senderId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}