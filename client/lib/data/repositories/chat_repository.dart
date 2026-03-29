import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatRepository {
  final ChatService _chatService;
  ChatRepository(this._chatService);

  // Lấy danh sách hộp thư
  Future<List<MatchModel>> getInbox() async {
    final response = await _chatService.getInbox();
    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((json) => MatchModel.fromJson(json)).toList();
    }
    throw Exception(response.data['message']);
  }

  // Lấy lịch sử tin nhắn của 1 phòng
  Future<List<MessageModel>> getMessages(String matchId) async {
    final response = await _chatService.getMessages(matchId);
    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((json) => MessageModel.fromJson(json)).toList();
    }
    throw Exception(response.data['message']);
  }

  // Gửi tin nhắn mới qua API
  Future<MessageModel> sendMessage(String matchId, String content) async {
    final response = await _chatService.sendMessage(matchId, content);
    if (response.data['success'] == true) {
      return MessageModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }
}