import 'package:dio/dio.dart';

import '../models/team_model.dart';
import '../models/activity_model.dart';
import '../models/notification_model.dart';
import '../models/chat_model.dart'; // tái dùng MessageModel
import '../services/team_service.dart';

class TeamRepository {
  final TeamService _teamService;
  TeamRepository(this._teamService);

  Future<TeamDetailModel> createTeam(String name, String sport) async {
    final response = await _teamService.createTeam(name, sport);
    if (response.data['success'] == true) {
      return TeamDetailModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  Future<List<TeamModel>> getTeams({
    String? keyword,
    String? sport,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _teamService.getTeams(
      keyword: keyword,
      sport: sport,
      page: page,
      limit: limit,
    );
    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => TeamModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }

  Future<List<TeamModel>> getMyTeams() async {
    final response = await _teamService.getMyTeams();
    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => TeamModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }

  Future<TeamDetailModel> getTeamDetail(String teamId) async {
    final response = await _teamService.getTeamDetail(teamId);
    if (response.data['success'] == true) {
      return TeamDetailModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  Future<TeamDetailModel> updateTeamAvatar(String teamId, String imagePath) async {
    final response = await _teamService.updateTeamAvatar(teamId, imagePath);
    if (response.data['success'] == true) {
      return TeamDetailModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  Future<bool> updateFund(String teamId, double amount) async {
    final response = await _teamService.updateFund(teamId, amount);
    return response.data['success'] == true;
  }

  Future<ActivityModel> createActivity(
    String teamId,
    String type,
    String content, {
    List<String>? options,
  }) async {
    final response = await _teamService.createActivity(teamId, type, content, options: options);
    if (response.data['success'] == true) {
      return ActivityModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  Future<List<ActivityModel>> getActivities(String teamId, {int page = 1}) async {
    final response = await _teamService.getActivities(teamId, page: page);
    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => ActivityModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }

  Future<bool> interactActivity(String activityId, String optionId) async {
    final response = await _teamService.interactActivity(activityId, optionId);
    return response.data['success'] == true;
  }

  Future<bool> joinTeam(String teamId) async {
    try {
      final response = await _teamService.joinTeam(teamId);
      return response.data['success'] == true;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Có lỗi xảy ra';
      throw Exception(message);
    }
  }

  Future<bool> handleJoinRequest(String teamId, String userId, String action) async {
    try {
      final response = await _teamService.handleJoinRequest(teamId, userId, action);
      return response.data['success'] == true;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Có lỗi xảy ra';
      throw Exception(message);
    }
  }

  Future<List<MessageModel>> getTeamMessages(String teamId, {int page = 1}) async {
    final response = await _teamService.getTeamMessages(teamId, page: page);
    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => MessageModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _teamService.getNotifications();
    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }

  Future<bool> leaveTeam(String teamId) async {
    final response = await _teamService.leaveTeam(teamId);
    return response.data['success'] == true;
  }
}