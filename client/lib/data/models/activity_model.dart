// Model cho 1 lựa chọn trong bài Vote / Match Schedule
class ActivityOptionModel {
  final String id;
  final String label;
  final List<String> voterIds; // danh sách userId đã chọn option này

  ActivityOptionModel({
    required this.id,
    required this.label,
    required this.voterIds,
  });

  factory ActivityOptionModel.fromJson(Map<String, dynamic> json) {
    return ActivityOptionModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      voterIds: (json['voterIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

// Model cho 1 bài đăng trên bảng tin
class ActivityModel {
  final String id;
  final String type; // 'NOTICE' | 'VOTE' | 'MATCH_SCHEDULE'
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final List<ActivityOptionModel> options;

  ActivityModel({
    required this.id,
    required this.type,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
    required this.options,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};
    return ActivityModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'NOTICE',
      content: json['content'] ?? '',
      authorId: author['id'] ?? '',
      authorName: author['displayName'] ?? 'Người dùng',
      authorAvatar: author['avatar'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => ActivityOptionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}