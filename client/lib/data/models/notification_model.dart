class NotificationModel {
  final String id;
  final String type; // 'JOIN_REQUEST' | 'JOIN_APPROVED' | 'NEW_ACTIVITY'
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? teamId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.teamId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      teamId: json['teamId'],
    );
  }
}