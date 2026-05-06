import '../models/post_model.dart';
import '../services/post_service.dart';

class PostRepository {
  final PostService _postService;
  PostRepository(this._postService);

  Future<List<PostModel>> getPosts({int page = 1, int limit = 10}) async {
    final response = await _postService.getPosts(page: page, limit: limit);
    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => PostModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }

  Future<PostModel> createPost({
    required String type,
    required String content,
    String? sport,
    String? location,
    String? time,
    String? imagePath,
  }) async {
    final response = await _postService.createPost(
      type: type,
      content: content,
      sport: sport,
      location: location,
      time: time,
      imagePath: imagePath,
    );
    if (response.data['success'] == true) {
      return PostModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }

  Future<bool> likePost(String postId) async {
    final response = await _postService.likePost(postId);
    return response.data['success'] == true;
  }

  Future<PostModel> addComment(String postId, String text) async {
    final response = await _postService.addComment(postId, text);
    if (response.data['success'] == true) {
      return PostModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message']);
  }
}
