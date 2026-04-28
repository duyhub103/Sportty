// Model cho 1 thành viên trong đội
class TeamMemberModel {
  final String id;
  final String displayName;
  final String? avatar;
  final String role; // 'Captain' | 'Vice Captain' | 'Member'

  TeamMemberModel({
    required this.id,
    required this.displayName,
    this.avatar,
    required this.role,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    // Server trả về { user: {id, displayName, avatar}, role, joinedAt }
    final userInfo = json['user'] as Map<String, dynamic>? ?? {};
    return TeamMemberModel(
      id: userInfo['id'] ?? '',
      displayName: userInfo['displayName'] ?? 'Người dùng',
      avatar: userInfo['avatar']?.toString().isNotEmpty == true 
          ? userInfo['avatar'] 
          : null,
      role: json['role'] ?? 'MEMBER',
    );
  }
}

// Model cho 1 đội (dùng cho danh sách)
class TeamModel {
  final String id;
  final String name;
  final String sport;
  final String? avatar;
  final int memberCount;
  final double fund;

  TeamModel({
    required this.id,
    required this.name,
    required this.sport,
    this.avatar,
    required this.memberCount,
    required this.fund,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sport: json['sport'] ?? '',
      avatar: json['avatar'],
      memberCount: (json['members'] as List?)?.length ?? json['memberCount'] ?? 0,
      fund: (json['fund'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Model chi tiết đội (dùng cho màn hình detail, có thêm members)
class TeamDetailModel {
  final String id;
  final String name;
  final String sport;
  final String? avatar;
  final double fund;
  final List<TeamMemberModel> members;

  TeamDetailModel({
    required this.id,
    required this.name,
    required this.sport,
    this.avatar,
    required this.fund,
    required this.members,
  });

  factory TeamDetailModel.fromJson(Map<String, dynamic> json) {
    return TeamDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sport: json['sport'] ?? '',
      avatar: json['avatar'],
      fund: (json['fund'] as num?)?.toDouble() ?? 0.0,
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => TeamMemberModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  // Helper: lấy role của currentUser trong đội này
  String? getRoleOf(String userId) {
    try {
      return members.firstWhere((m) => m.id == userId).role;
    } catch (_) {
      return null;
    }
  }

  bool isLeader(String userId) {
    final role = getRoleOf(userId);
    return role == 'CAPTAIN' || role == 'VICE_CAPTAIN';
  }
}