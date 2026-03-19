import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class ProfileService {
  Future<Response> updateProfile({
    String? displayName,
    String? bio,
    List<String>? sports, // Tạm thời gửi 1 môn thể thao
    double? lat,
    double? lng,
    String? avatarPath, // Đường dẫn file ảnh trong máy
  }) async {
    // Khởi tạo FormData
    final formData = FormData.fromMap({
      if (displayName != null) 'displayName': displayName,
      if (bio != null) 'bio': bio,
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'long': lng.toString(),
    });

    // Cách gửi mảng (Array) qua FormData chuẩn nhất
    if (sports != null && sports.isNotEmpty) {
      for (var sport in sports) {
        formData.fields.add(MapEntry('sports', sport));
      }
    }

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

  // Lấy thông tin Profile mới nhất
  Future<Response> getProfile() async {
    return await ApiClient.dio.get('/users/profile'); 
  }

  // Upload ảnh vào Gallery
  Future<Response> uploadGalleryImage(String imagePath) async {
    final formData = FormData.fromMap({
      'gallery': await MultipartFile.fromFile(imagePath, filename: 'gallery_image.jpg'),
    });

    return await ApiClient.dio.put('/users/profile', data: formData);
  }

}