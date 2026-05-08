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
  bool _isLoadingActivities = false;
    bool get isLoadingActivities => _isLoadingActivities;

    Future<void> fetchActivities(String teamId, {bool refresh = false}) async {
      // Không cho nhiều request chạy cùng lúc
      if (_isLoadingActivities && !refresh) return;

      if (refresh) {
        _activitiesPage = 1;
        _activities = [];
        _hasMoreActivities = true;
      }
      if (!_hasMoreActivities) return;

      _isLoadingActivities = true;
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
      } finally {
        _isLoadingActivities = false; // Luôn mở cờ sau khi xong
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
    final actIndex = _activities.indexWhere((a) => a.id == activityId);
  
    // Nếu tìm thấy activity → Cập nhật UI ngay (optimistic)
    if (actIndex != -1) {
      final activity = _activities[actIndex];
      final updatedOptions = activity.options.map((option) {
        if (option.id == optionId) {
          // Thêm 1 voteCount cho option được chọn
          return ActivityOptionModel(
            id: option.id,
            label: option.label,
            voteCount: option.voteCount + 1,
            voterIds: option.voterIds, // giữ nguyên, chỉ cần UI cập nhật count
          );
        }
        return option;
      }).toList();
      _activities[actIndex] = ActivityModel(
        id: activity.id,
        type: activity.type,
        content: activity.content,
        authorId: activity.authorId,
        authorName: activity.authorName,
        authorAvatar: activity.authorAvatar,
        createdAt: activity.createdAt,
        options: updatedOptions,
      );
      notifyListeners(); 
    }
    // Gọi API ngầm
    try {
      return await _repository.interactActivity(activityId, optionId);
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

  Future<void> sendTeamMessage(String teamId, String senderId, String content) async {
    final socket = SocketClient().socket;
    print('Socket: ${socket?.id}');
    print('Connected: ${socket?.connected}');
    print('Gửi: $content');

    if (socket == null || content.trim().isEmpty) return;
    
    socket.emit('send_team_message', {
      'senderId': senderId,
      'teamId': teamId,
      'content': content,
    });
  }

  void setupTeamSocket(String teamId) {
    final socket = SocketClient().socket;
    if (socket == null) return;
    socket.emit('join_team_chat', teamId);

    // Tin nhắn nhóm
    socket.off('receive_team_message');
    socket.on('receive_team_message', (data) {
      print('receive_team_message data: $data');
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
    socket.off('receive_notification');
    socket.on('receive_notification', (data) {
      final notif = NotificationModel.fromJson(data);
      _notifications.insert(0, notif);
      notifyListeners();
    });
  }

  void leaveTeamSocket(String teamId) {
    final socket = SocketClient().socket;
    if (socket == null) return;
    socket.off('receive_team_message');
    socket.off('new_activity');
    socket.off('receive_notification');
    socket.off('activity_updated');
  }

  void setupGlobalNotificationSocket() {
    final socket = SocketClient().socket;
    if (socket == null) return;

    socket.off('receive_notification');
    socket.on('receive_notification', (data) {
      final notif = NotificationModel.fromJson(data);
      _notifications.insert(0, notif);
      notifyListeners();
    });

    socket.off('team_joined');
    socket.on('team_joined', (data) {
      fetchMyTeams();

      if (currentTeam != null) {
        fetchTeamDetail(currentTeam!.id);
      }
    });
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

  Future<bool> leaveTeam(String teamId) async {
    try {
      await _repository.leaveTeam(teamId);
      // Xóa khỏi danh sách myTeams ngay lập tức (optimistic)
      _myTeams.removeWhere((t) => t.id == teamId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Đánh dấu 1 thông báo là đã đọc
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _repository.markNotificationAsRead(notificationId);
      // Cập nhật local ngay (optimistic)
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final old = _notifications[index];
        _notifications[index] = NotificationModel(
          id: old.id,
          type: old.type,
          content: old.content,
          isRead: true, // ← Đổi thành đã đọc
          createdAt: old.createdAt,
          relatedId: old.relatedId,
          sender: old.sender,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Lỗi markAsRead: $e');
    }
  }

  // Đánh dấu tất cả đã đọc
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();
      // Optimistic update
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        type: n.type,
        content: n.content,
        isRead: true,
        createdAt: n.createdAt,
        relatedId: n.relatedId,
        sender: n.sender,
      )).toList();
      notifyListeners();
    } catch (e) {
      print('Lỗi markAllAsRead: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}