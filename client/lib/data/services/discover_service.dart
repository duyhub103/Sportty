import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class DiscoverService {
  // Lấy danh sách xung quanh
  Future<Response> getNearbyUsers(double lat, double lng, int distance) async {
    return await ApiClient.dio.get(
      '/users/nearby',
      queryParameters: {
        'lat': lat,
        'long': lng,
        'distance': distance,
      },
    );
  }

  // Quẹt (like / next)
  Future<Response> swipe(String receiverId, String type) async {
    return await ApiClient.dio.post(
      '/swipes',
      data: {
        'receiverId': receiverId,
        'type': type,
      },
    );
  }
}