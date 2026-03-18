import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class ProfileService {
  Future<Response> updateProfile({
    String? displayName,
    String? bio,
    String? sport, // Tạm thời gửi 1 môn thể thao
    double? lat,
    double? lng,
    String? avatarPath, // Đường dẫn file ảnh trong máy
  }) async {
    // Khởi tạo FormData
    final formData = FormData.fromMap({
      if (displayName != null) 'displayName': displayName,
      if (bio != null) 'bio': bio,
      if (sport != null) 'sports': sport,
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'long': lng.toString(),
    });

    // Nếu người dùng có chọn ảnh, đính kèm file ảnh vào Form
    if (avatarPath != null) {
      formData.files.add(MapEntry(
        'avatar',
        await MultipartFile.fromFile(avatarPath, filename: 'avatar.jpg'),
      ));
    }

    // Gọi API PUT
    return await ApiClient.dio.put(
      '/users/profile',
      data: formData,
    );
  }
}