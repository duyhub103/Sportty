class UserModel {
  final String id;
  final String fullName;
  final String displayName;
  final String email;
  final String? avatar; // Có thể null vì người mới chưa có avatar

  UserModel({
    required this.id,
    required this.fullName,
    required this.displayName,
    required this.email,
    this.avatar,
  });

  // Hàm dịch JSON của Postman sang Object Flutter
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'], // link URL
    );
  }
}