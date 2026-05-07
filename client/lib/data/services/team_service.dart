import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class TeamService {
  // Tạo đội mới
  Future<Response> createTeam(String name, String sport) async {
    return await ApiClient.dio.post('/teams', data: {
      'name': name,
      'sport': sport,
    });
  }

  Future<Response> getMyTeams() async {
    return await ApiClient.dio.get('/teams/my-teams');
  }

  // Lấy danh sách đội (tìm kiếm + phân trang)
  Future<Response> getTeams({
    String? keyword,
    String? sport,
    int page = 1,
    int limit = 10,
  }) async {
    return await ApiClient.dio.get('/teams', queryParameters: {
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (sport != null && sport.isNotEmpty) 'sport': sport,
      'page': page,
      'limit': limit,
    });
  }

  // Xem chi tiết đội
  Future<Response> getTeamDetail(String teamId) async {
    return await ApiClient.dio.get('/teams/$teamId');
  }

  // Cập nhật avatar đội
  Future<Response> updateTeamAvatar(String teamId, String imagePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(imagePath, filename: 'team_avatar.jpg'),
    });
    return await ApiClient.dio.put('/teams/$teamId/avatar', data: formData);
  }

  // Cập nhật quỹ đội
  Future<Response> updateFund(String teamId, double amount) async {
    return await ApiClient.dio.put('/teams/$teamId/fund', data: {
      'amount': amount,
    });
  }

  // Đăng bài hoạt động
  Future<Response> createActivity(
    String teamId,
    String type,
    String content, {
    List<String>? options,
  }) async {
    return await ApiClient.dio.post('/teams/$teamId/activities', data: {
      'type': type,
      'content': content,
      if (options != null && options.isNotEmpty) 'options': options,
    });
  }

  // Lấy danh sách bài đăng
  Future<Response> getActivities(String teamId, {int page = 1, int limit = 10}) async {
    return await ApiClient.dio.get('/teams/$teamId/activities', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  // Tương tác bài đăng (vote)
  Future<Response> interactActivity(String activityId, String optionId) async {
    return await ApiClient.dio.post('/activities/$activityId/interact', data: {
      'optionId': optionId,
    });
  }

  // Xin vào đội
  Future<Response> joinTeam(String teamId) async {
    return await ApiClient.dio.post('/teams/$teamId/join');
  }

  // Duyệt / Từ chối yêu cầu
  Future<Response> handleJoinRequest(
    String teamId,
    String requestUserId,
    String action, // 'APPROVE' | 'REJECT'
  ) async {
    return await ApiClient.dio.put('/teams/$teamId/requests', data: {
      'targetUserId': requestUserId,
      'action': action,
    });
  }

  // Lấy tin nhắn nhóm
  Future<Response> getTeamMessages(String teamId, {int page = 1, int limit = 20}) async {
    return await ApiClient.dio.get('/teams/$teamId/messages', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  // Lấy thông báo
  Future<Response> getNotifications() async {
    return await ApiClient.dio.get('/notifications');
  }

  // Rời khỏi đội
  Future<Response> leaveTeam(String teamId) async {
    return await ApiClient.dio.delete('/teams/$teamId/leave');
  }
}