// Model cho 1 thành viên trong đội
class TeamMemberModel {
  final String id;
  final String displayName;
  final String? avatar;
  final String role;

  TeamMemberModel({
    required this.id,
    required this.displayName,
    this.avatar,
    required this.role,
  });

  // Dùng cho members chính thức: { user: {id, displayName, avatar}, role, joinedAt }
  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
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

  // Dùng cho pendingRequests: { id, displayName, avatar }
  factory TeamMemberModel.fromPending(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName'] ?? 'Người dùng',
      avatar: json['avatar']?.toString().isNotEmpty == true
          ? json['avatar']
          : null,
      role: 'PENDING',
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

// Model chi tiết đội (dùng cho màn hình detail)
class TeamDetailModel {
  final String id;
  final String name;
  final String sport;
  final String? avatar;
  final double fund;
  final List<TeamMemberModel> members;
  final List<TeamMemberModel> pendingRequests; 

  TeamDetailModel({
    required this.id,
    required this.name,
    required this.sport,
    this.avatar,
    required this.fund,
    required this.members,
    required this.pendingRequests, 
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
      pendingRequests: (json['pendingRequests'] as List<dynamic>?) 
              ?.map((e) => TeamMemberModel.fromPending(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

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