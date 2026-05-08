// Model cho 1 lựa chọn trong bài Vote / Match Schedule
class ActivityOptionModel {
  final String id;
  final String label;
  final List<String> voterIds; // danh sách userId đã chọn option này
  final int voteCount; // tổng số người đã chọn option này

  ActivityOptionModel({
    required this.id,
    required this.label,
    required this.voterIds,
    required this.voteCount,
  });

  factory ActivityOptionModel.fromJson(Map<String, dynamic> json) {
    return ActivityOptionModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      voteCount: json['voteCount'] ?? 0,
      voterIds: (json['voters'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map) return e['id']?.toString() ?? '';
                return e.toString();
              })
              .where((id) => id.isNotEmpty)
              .toList() ?? [],
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
    final creator = json['createdBy'];
    
    String authorId = '';
    String authorName = 'Người dùng';
    String? authorAvatar;

    // creator có thể là Map hoặc null
    if (creator is Map<String, dynamic>) {
      authorId = creator['id']?.toString() ?? '';
      authorName = creator['displayName']?.toString() ?? 'Người dùng';
      final av = creator['avatar']?.toString() ?? '';
      authorAvatar = av.isNotEmpty ? av : null;
    }

    return ActivityModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: json['type'] ?? 'NOTICE',
      content: json['content'] ?? '',
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      options: (json['voteOptions'] as List<dynamic>?)
              ?.map((e) => ActivityOptionModel.fromJson(e))
              .toList() ?? [],
    );
  }
}