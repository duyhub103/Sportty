import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class PostService {
  // Lấy danh sách bài đăng
  Future<Response> getPosts({int page = 1, int limit = 10}) async {
    return await ApiClient.dio.get('/posts', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  // Tạo bài đăng mới (có thể kèm ảnh)
  Future<Response> createPost({
    required String type,
    required String content,
    String? sport,
    String? location,
    String? time,     // ISO 8601 string, VD: "2026-05-10T19:00:00.000Z"
    String? imagePath,
  }) async {
    // Dùng FormData vì có thể có upload ảnh
    final formData = FormData.fromMap({
      'type': type,
      'content': content,
      if (sport != null) 'sport': sport,
      if (location != null) 'location': location,
      if (time != null) 'time': time,
      if (imagePath != null)
        'image': await MultipartFile.fromFile(imagePath, filename: 'post_image.jpg'),
    });
    return await ApiClient.dio.post('/posts', data: formData);
  }

  // Like / Bỏ Like
  Future<Response> likePost(String postId) async {
    return await ApiClient.dio.put('/posts/$postId/like');
  }

  // Thêm comment
  Future<Response> addComment(String postId, String text) async {
    return await ApiClient.dio.post('/posts/$postId/comments', data: {
      'text': text,
    });
  }
}
