import 'package:flutter/material.dart';
import '../../data/models/nearby_user_model.dart';
import '../../data/repositories/discover_repository.dart';

class DiscoverProvider extends ChangeNotifier {
  final DiscoverRepository _repository;
  DiscoverProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<NearbyUserModel> _users = [];
  List<NearbyUserModel> get users => _users;

  // Gọi để tải danh sách (Ví dụ lấy tạm tọa độ cứng, sau này móc từ ProfileProvider qua)
  Future<void> fetchNearbyUsers(double lat, double lng, {int distance = 50}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fake tọa độ quận 10 lúc test Postman, em có thể tùy chỉnh
      _users = await _repository.getNearbyUsers(lat, lng, distance);
    } catch (e) {
      print('Lỗi fetch nearby: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // xử lý khi quẹt thẻ
  Future<SwipeResultModel?> handleSwipe(String receiverId, String type) async {
    try {
      final result = await _repository.swipe(receiverId, type);
      return result; 
    } catch (e) {
      print('Lỗi quẹt thẻ: $e');
      return null;
    }
  }
}