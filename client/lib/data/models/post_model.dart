// Model cho comment trong bài đăng
class PostCommentModel {
  final String id;
  final String text;
  final DateTime createdAt;
  final String userId;
  final String userName;
  final String? userAvatar;

  PostCommentModel({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final av = user['avatar']?.toString() ?? '';
    return PostCommentModel(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      userId: user['id']?.toString() ?? '',
      userName: user['displayName']?.toString() ?? 'Người dùng',
      userAvatar: av.isNotEmpty ? av : null,
    );
  }
}

// Model chính cho 1 bài đăng cộng đồng
class PostModel {
  final String id;
  final String type;      // 'DISCUSSION' | 'MATCH'
  final String content;
  final String image;
  final DateTime createdAt;

  // Thông tin tác giả
  final String authorId;
  final String authorName;
  final String? authorAvatar;

  // Thông tin trận đấu (chỉ có khi type = 'MATCH')
  final String? sport;
  final String? location;
  final DateTime? matchTime;

  // Tương tác
  final int likeCount;
  final List<String> likedBy; // Danh sách userId đã like
  final int commentCount;
  final List<PostCommentModel> comments;

  PostModel({
    required this.id,
    required this.type,
    required this.content,
    required this.image,
    required this.createdAt,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.sport,
    this.location,
    this.matchTime,
    required this.likeCount,
    required this.likedBy,
    required this.commentCount,
    required this.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    final av = author['avatar']?.toString() ?? '';

    return PostModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'DISCUSSION',
      content: json['content'] ?? '',
      image: json['image'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      authorId: author['id']?.toString() ?? '',
      authorName: author['displayName']?.toString() ?? 'Người dùng',
      authorAvatar: av.isNotEmpty ? av : null,
      sport: json['sport'],
      location: json['location'],
      matchTime: json['time'] != null
          ? DateTime.tryParse(json['time'])
          : null,
      likeCount: json['likeCount'] ?? 0,
      likedBy: (json['likedBy'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      commentCount: json['commentCount'] ?? 0,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => PostCommentModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
