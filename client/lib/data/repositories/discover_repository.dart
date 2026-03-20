import '../models/nearby_user_model.dart';
import '../services/discover_service.dart';

class DiscoverRepository {
  final DiscoverService _discoverService;

  DiscoverRepository(this._discoverService);

  Future<List<NearbyUserModel>> getNearbyUsers(double lat, double lng, int distance) async {
    try {
      final response = await _discoverService.getNearbyUsers(lat, lng, distance);
      final responseData = response.data;

      if (responseData['success'] == true) {
        final List listData = responseData['data'] ?? [];
        return listData.map((json) => NearbyUserModel.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Lỗi tải danh sách');
      }
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  Future<SwipeResultModel> swipe(String receiverId, String type) async {
    try {
      final response = await _discoverService.swipe(receiverId, type);
      final responseData = response.data;

      if (responseData['success'] == true) {
        return SwipeResultModel.fromJson(responseData['data']);
      } else {
        // Có thể lỗi "You have already swiped this user"
        throw Exception(responseData['message']);
      }
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }
}