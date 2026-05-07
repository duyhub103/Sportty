import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class ChatService {
  // Lấy danh sách hộp thư
  Future<Response> getInbox() async {
    return await ApiClient.dio.get('/matches');
  }

  // Lấy lịch sử tin nhắn của 1 phòng
  Future<Response> getMessages(String matchId) async {
    return await ApiClient.dio.get('/messages/$matchId');
  }

  // Gửi tin nhắn mới qua API
  Future<Response> sendMessage(String matchId, String content) async {
    return await ApiClient.dio.post(
      '/messages/',
      data: {
        'conversationId': matchId,
        'type': 'PRIVATE',
        'content': content,
      },
    );
  }

  // Hủy tương hợp
  Future<Response> unmatch(String matchId) async {
    return await ApiClient.dio.delete('/matches/$matchId');
  }

  // Xóa tin nhắn
  Future<Response> deleteMessage(String messageId, String matchId, String type) async {
    return await ApiClient.dio.delete(
      '/messages/$messageId',
      data: {
        'conversationId': matchId,
        'type': type,
      },
    );
  }
}