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
  final String senderName;
  final String senderAvatar;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderRaw = json['sender'];
    final sender = senderRaw is Map
        ? Map<String, dynamic>.from(senderRaw)
        : <String, dynamic>{};

    return MessageModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      content: json['content'] ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: sender['displayName'] ?? 'Người dùng',   
      senderAvatar: sender['avatar'] ?? '',               
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}