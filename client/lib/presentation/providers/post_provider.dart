import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';

class PostProvider extends ChangeNotifier {
  final PostRepository _repository;
  PostProvider(this._repository);

  List<PostModel> _posts = [];
  List<PostModel> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _page = 1;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Lấy danh sách bài đăng (có phân trang + refresh)
  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _posts = [];
      _hasMore = true;
    }
    if (!_hasMore) return;

    _setLoading(true);
    try {
      final result = await _repository.getPosts(page: _page);
      if (result.isEmpty) {
        _hasMore = false;
      } else {
        _posts.addAll(result);
        _page++;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    _setLoading(false);
  }

  // Tạo bài đăng mới
  Future<bool> createPost({
    required String type,
    required String content,
    String? sport,
    String? location,
    String? time,
    String? imagePath,
  }) async {
    try {
      final post = await _repository.createPost(
        type: type,
        content: content,
        sport: sport,
        location: location,
        time: time,
        imagePath: imagePath,
      );
      // Thêm bài mới lên đầu danh sách ngay lập tức
      _posts.insert(0, post);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Like / Bỏ Like — Cập nhật UI optimistic (không cần gọi lại API)
  Future<void> likePost(String postId, String currentUserId) async {
    try {
      await _repository.likePost(postId);
      // TODO: Nếu muốn cập nhật likeCount chính xác, gọi lại API lấy post đó.
      // Vì đơn giản và đủ thời gian, tạm thời refresh toàn bộ list sau khi like.
      await fetchPosts(refresh: true);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Thêm comment
  Future<bool> addComment(String postId, String text) async {
    try {
      final updatedPost = await _repository.addComment(postId, text);
      // Tìm và thay thế post cũ bằng post mới nhất (đã có comment)
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
