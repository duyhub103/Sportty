import 'package:flutter/material.dart';
import '../../data/models/chat_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../core/network/socket_client.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;

  ChatProvider(this._repository);

  bool _isLoadingInbox = false;
  bool get isLoadingInbox => _isLoadingInbox;

  List<MatchModel> _inbox = [];
  List<MatchModel> get inbox => _inbox;

  List<MessageModel> _currentMessages = [];
  List<MessageModel> get currentMessages => _currentMessages;

  // Fetch Danh sách hộp thư
  Future<void> fetchInbox() async {
    _isLoadingInbox = true;
    notifyListeners();
    try {
      _inbox = await _repository.getInbox();
    } catch (e) {
      print('Lỗi lấy hộp thư: $e');
    }
    _isLoadingInbox = false;
    notifyListeners();
  }

  // Fetch Tin nhắn của 1 phòng Chat
  Future<void> fetchMessages(String matchId) async {
    try {
      _currentMessages = await _repository.getMessages(matchId);
      // Đảo ngược list nếu UI hiển thị từ dưới lên
      notifyListeners();
    } catch (e) {
      print('Lỗi lấy tin nhắn: $e');
    }
  }

  // Gửi tin nhắn
  Future<void> sendMessage(String matchId, String content) async {
    try {
      final newMessage = await _repository.sendMessage(matchId, content);
      
      // Thêm tạm tin nhắn vào list để UI hiện ngay
      _currentMessages.insert(0, newMessage); 
      notifyListeners();

    } catch (e) {
      print('Lỗi gửi tin nhắn: $e');
    }
  }

  // kết nối SOCKET.IO
  void setupChatSocket(String matchId) {
    // Lấy socket xài chung của toàn App ra
    final socket = SocketClient().socket;

    if (socket != null) {
      // Báo cho Server biết mình mở phòng chat này
      socket.emit('join_chat', matchId); 
      print('Đã join phòng chat: $matchId');

      // Lắng nghe tin nhắn mới 1-1
      // Dùng socket.off trước để tránh bị lắng nghe chồng chéo nếu user thoát ra vào lại nhiều lần
      socket.off('receive_message'); 
      socket.on('receive_message', (data) {
        print('Có tin nhắn 1-1 mới: $data');
        final newMsg = MessageModel.fromJson(data);
        
        // Nhét tin nhắn mới lên đầu danh sách để UI hiện ngay
        _currentMessages.insert(0, newMsg);
        notifyListeners();
      });
    }
  }

  void leaveChatSocket(String matchId) {
    final socket = SocketClient().socket;
    if (socket != null) {
      // Tắt lắng nghe sự kiện của phòng này khi User ấn nút Back thoát ra
      socket.off('receive_message');
    }
  }
}