class UserModel {
  final String id;
  final String fullName;
  final String displayName;
  final String email;
  final String? avatar; // Có thể null vì người mới chưa có avatar
  final String? bio;
  final List<String> sports;
  final double? longitude;
  final double? latitude;

  

  UserModel({
    required this.id,
    required this.fullName,
    required this.displayName,
    required this.email,
    this.avatar,
    this.bio,
    this.sports = const [],
    this.longitude,
    this.latitude,
  });

  // Hàm dịch JSON của Postman sang Object Flutter
  factory UserModel.fromJson(Map<String, dynamic> json) {

    // Xử lý bóc tách tọa độ từ [long, lat]
    double? lng;
    double? lat;
    if (json['location'] != null && json['location']['coordinates'] != null) {
      final coords = json['location']['coordinates'] as List;
      if (coords.length >= 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    }


    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'], // link URL
      bio: json['bio'] ?? '',
      // Ép kiểu mảng dynamic sang mảng String
      sports: (json['sports'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      longitude: lng,
      latitude: lat,
    );
  }
}