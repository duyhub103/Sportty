import 'package:flutter/material.dart';
import '../../core/network/socket_client.dart';
import '../../data/models/team_model.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/team_repository.dart';

class TeamProvider extends ChangeNotifier {
  final TeamRepository _repository;
  TeamProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Danh sách đội của tôi
  List<TeamModel> _myTeams = [];
  List<TeamModel> get myTeams => _myTeams;
  bool _isLoadingMyTeams = false;
  bool get isLoadingMyTeams => _isLoadingMyTeams;

  // Danh sách đội (khám phá)
  List<TeamModel> _teams = [];
  List<TeamModel> get teams => _teams;
  bool _hasMoreTeams = true;
  bool get hasMoreTeams => _hasMoreTeams;
  int _teamsPage = 1;

  // Chi tiết đội đang xem
  TeamDetailModel? _currentTeam;
  TeamDetailModel? get currentTeam => _currentTeam;

  // Bảng tin
  List<ActivityModel> _activities = [];
  List<ActivityModel> get activities => _activities;
  bool _hasMoreActivities = true;
  bool get hasMoreActivities => _hasMoreActivities;
  int _activitiesPage = 1;

  // Chat nhóm
  List<MessageModel> _teamMessages = [];
  List<MessageModel> get teamMessages => _teamMessages;

  // Thông báo
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // --- MY TEAMS ---
  Future<void> fetchMyTeams() async {
    _isLoadingMyTeams = true;
    notifyListeners();
    try {
      _myTeams = await _repository.getMyTeams();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    _isLoadingMyTeams = false;
    notifyListeners();
  }

  // --- TEAM LIST ---
  Future<void> fetchTeams({String? keyword, String? sport, bool refresh = false}) async {
    if (refresh) {
      _teamsPage = 1;
      _teams = [];
      _hasMoreTeams = true;
    }
    if (!_hasMoreTeams) return;

    _setLoading(true);
    try {
      final result = await _repository.getTeams(
        keyword: keyword,
        sport: sport,
        page: _teamsPage,
      );
      if (result.isEmpty) {
        _hasMoreTeams = false;
      } else {
        _teams.addAll(result);
        _teamsPage++;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    _setLoading(false);
  }

  // --- TEAM DETAIL ---
  Future<void> fetchTeamDetail(String teamId) async {
    _setLoading(true);
    try {
      _currentTeam = await _repository.getTeamDetail(teamId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    _setLoading(false);
  }

  // --- TẠO ĐỘI ---
  Future<TeamDetailModel?> createTeam(String name, String sport) async {
    _setLoading(true);
    try {
      final team = await _repository.createTeam(name, sport);
      _setLoading(false);
      return team;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return null;
    }
  }

  // --- CẬP NHẬT AVATAR ---
  Future<bool> updateTeamAvatar(String teamId, String imagePath) async {
    try {
      _currentTeam = await _repository.updateTeamAvatar(teamId, imagePath);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // --- CẬP NHẬT QUỸ ---
  Future<bool> updateFund(String teamId, double amount) async {
    try {
      final success = await _repository.updateFund(teamId, amount);
      if (success) await fetchTeamDetail(teamId);
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // --- ACTIVITIES ---
  Future<void> fetchActivities(String teamId, {bool refresh = false}) async {
    if (refresh) {
      _activitiesPage = 1;
      _activities = [];
      _hasMoreActivities = true;
    }
    if (!_hasMoreActivities) return;

    try {
      final result = await _repository.getActivities(teamId, page: _activitiesPage);
      if (result.isEmpty) {
        _hasMoreActivities = false;
      } else {
        _activities.addAll(result);
        _activitiesPage++;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createActivity(
    String teamId,
    String type,
    String content, {
    List<String>? options,
  }) async {
    try {
      final activity = await _repository.createActivity(teamId, type, content, options: options);
      _activities.insert(0, activity);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> interactActivity(String activityId, String optionId) async {
    try {
      final success = await _repository.interactActivity(activityId, optionId);
      if (_currentTeam != null) {
        fetchActivities(_currentTeam!.id, refresh: true);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // --- JOIN / REQUEST ---
  Future<bool> joinTeam(String teamId) async {
    try {
      return await _repository.joinTeam(teamId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleJoinRequest(String teamId, String userId, String action) async {
    try {
      final success = await _repository.handleJoinRequest(teamId, userId, action);
      if (success) await fetchTeamDetail(teamId);
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // --- TEAM CHAT ---
  Future<void> fetchTeamMessages(String teamId) async {
    try {
      _teamMessages = await _repository.getTeamMessages(teamId);
      notifyListeners();
    } catch (e) {
      print('Lỗi lấy tin nhắn nhóm: $e');
    }
  }

  void setupTeamSocket(String teamId) {
    final socket = SocketClient().socket;
    if (socket == null) return;
    socket.emit('join_team_chat', teamId);

    // Tin nhắn nhóm
    socket.off('team_message');
    socket.on('team_message', (data) {
      final newMsg = MessageModel.fromJson(data);
      bool isDuplicate = _teamMessages.any((m) => m.id == newMsg.id);
      if (!isDuplicate) {
        _teamMessages.insert(0, newMsg);
        notifyListeners();
      }
    });

    //Lắng nghe bài đăng mới real-time
    socket.off('new_activity');
    socket.on('new_activity', (data) {
      try {
        final newActivity = ActivityModel.fromJson(data);
        bool isDuplicate = _activities.any((a) => a.id == newActivity.id);
        if (!isDuplicate) {
          _activities.insert(0, newActivity);
          notifyListeners();
        }
      } catch (e) {
        print('Lỗi parse new_activity: $e');
      }
    });

    socket.off('activity_updated');
    socket.on('activity_updated', (data) {
      try {
        final updated = ActivityModel.fromJson(data);
        // Tìm và thay thế activity cũ trong list
        final index = _activities.indexWhere((a) => a.id == updated.id);
        if (index != -1) {
          _activities[index] = updated;
          notifyListeners();
        }
      } catch (e) {
        print('Lỗi parse activity_updated: $e');
      }
    });

    // Thông báo
    socket.off('notification');
    socket.on('notification', (data) {
      final notif = NotificationModel.fromJson(data);
      _notifications.insert(0, notif);
      notifyListeners();
    });
  }

  void leaveTeamSocket(String teamId) {
    final socket = SocketClient().socket;
    if (socket == null) return;
    socket.off('team_message');
    socket.off('new_activity');
    socket.off('notification');
    socket.off('activity_updated');
  }

  // --- NOTIFICATIONS ---
  Future<void> fetchNotifications() async {
    try {
      _notifications = await _repository.getNotifications();
      notifyListeners();
    } catch (e) {
      print('Lỗi lấy thông báo: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}