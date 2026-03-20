class NearbyUserModel {
  final String id;
  final String displayName;
  final String? avatar;
  final String? bio;
  final List<String> sports;
  final double distance;

  NearbyUserModel({
    required this.id,
    required this.displayName,
    this.avatar,
    this.bio,
    this.sports = const [],
    required this.distance,
  });

  factory NearbyUserModel.fromJson(Map<String, dynamic> json) {
    return NearbyUserModel(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? 'Người chơi hệ ẩn danh',
      avatar: json['avatar'],
      bio: json['bio'],
      sports: (json['sports'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Model hứng kết quả trả về khi gọi API quẹt
class SwipeResultModel {
  final bool isMatch;
  final String? matchId;

  SwipeResultModel({required this.isMatch, this.matchId});

  factory SwipeResultModel.fromJson(Map<String, dynamic> json) {
    return SwipeResultModel(
      isMatch: json['isMatch'] ?? false,
      matchId: json['matchId'],
    );
  }
}