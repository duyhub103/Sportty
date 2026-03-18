import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository(this._profileService);

  Future<UserModel> updateProfile({
    String? displayName,
    String? bio,
    String? sport,
    double? lat,
    double? lng,
    String? avatarPath,
  }) async {
    try {
      final response = await _profileService.updateProfile(
        displayName: displayName,
        bio: bio,
        sport: sport,
        lat: lat,
        lng: lng,
        avatarPath: avatarPath,
      );

      final responseData = response.data;

      if (responseData['success'] == true) {
        // Trả về User đã được update mới nhất
        return UserModel.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Cập nhật thất bại');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối Server');
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }
}