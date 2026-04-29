class NotificationSender {
  final String id;
  final String displayName;
  final String? avatar;

  NotificationSender({
    required this.id,
    required this.displayName,
    this.avatar,
  });

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName'] ?? 'Hệ thống',
      avatar: json['avatar'],
    );
  }
}

class NotificationModel {
  final String id;
  final String type;
  final String content;     
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;  
  final NotificationSender? sender;

  NotificationModel({
    required this.id,
    required this.type,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
    this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      relatedId: json['relatedId']?.toString(),
      sender: json['sender'] != null
          ? NotificationSender.fromJson(json['sender'])
          : null,
    );
  }
}