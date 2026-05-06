import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/post_model.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchPosts(refresh: true);
    });

    // Lazy load khi cuộn xuống gần cuối
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        final provider = context.read<PostProvider>();
        if (provider.hasMore && !provider.isLoading) {
          provider.fetchPosts();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Bảng tin',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, _) {
          // Loading lần đầu
          if (provider.isLoading && provider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          // Danh sách trống
          if (provider.posts.isEmpty) {
            return RefreshIndicator(
              color: Colors.green,
              onRefresh: () => provider.fetchPosts(refresh: true),
              child: ListView(
                children: const [
                  SizedBox(
                    height: 500,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.newspaper_outlined, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có bài đăng nào.\nHãy là người đầu tiên chia sẻ!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: Colors.green,
            onRefresh: () => provider.fetchPosts(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator cuối danh sách
                if (index == provider.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(color: Colors.green)),
                  );
                }
                return _PostCard(
                  post: provider.posts[index],
                  currentUserId: currentUserId,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text('Đăng bài', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        ),
      ),
    );
  }
}

// ============================================================

// Widget hiển thị 1 bài đăng
class _PostCard extends StatefulWidget {
  final PostModel post;
  final String currentUserId;

  const _PostCard({required this.post, required this.currentUserId});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _showComments = false;
  final _commentController = TextEditingController();
  bool _isCommenting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isCommenting = true);
    final success = await context.read<PostProvider>().addComment(widget.post.id, text);
    if (success) _commentController.clear();
    setState(() => _isCommenting = false);
    if (!success && mounted) {
      Fluttertoast.showToast(msg: 'Gửi comment thất bại', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy post mới nhất từ provider (sau khi like/comment, post được cập nhật)
    final provider = context.watch<PostProvider>();
    final post = provider.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar + Tên + Thời gian
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green[50],
                      backgroundImage: (post.authorAvatar != null && post.authorAvatar!.isNotEmpty)
                          ? NetworkImage(post.authorAvatar!)
                          : null,
                      child: (post.authorAvatar == null || post.authorAvatar!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.green, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.authorName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(_formatTimeAgo(post.createdAt),
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                    // Badge loại bài
                    if (post.type == 'MATCH')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sports_soccer, size: 13, color: Colors.orange),
                            SizedBox(width: 4),
                            Text('Tìm kèo',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Nội dung
                Text(post.content, style: const TextStyle(fontSize: 15, color: Colors.black87)),

                // Thông tin trận đấu (chỉ khi MATCH)
                if (post.type == 'MATCH') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        if (post.sport != null)
                          _buildMatchInfo(Icons.sports, post.sport!),
                        if (post.location != null) ...[
                          const SizedBox(height: 6),
                          _buildMatchInfo(Icons.location_on_outlined, post.location!),
                        ],
                        if (post.matchTime != null) ...[
                          const SizedBox(height: 6),
                          _buildMatchInfo(
                            Icons.access_time,
                            '${post.matchTime!.hour.toString().padLeft(2, '0')}:${post.matchTime!.minute.toString().padLeft(2, '0')} — ${post.matchTime!.day}/${post.matchTime!.month}/${post.matchTime!.year}',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Ảnh (nếu có)
                if (post.image.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Đường kẻ + Nút Like / Comment
          const Divider(height: 1),
          Row(
            children: [
              // Nút Like
              Expanded(
                child: Builder(
                    builder: (_) {
                        final isLiked = post.likedBy.contains(widget.currentUserId);
                        return TextButton.icon(
                            onPressed: () => context.read<PostProvider>().likePost(
                            post.id,
                            widget.currentUserId,
                            ),
                            icon: Icon(
                            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 18,
                            color: isLiked ? Colors.blue : Colors.grey[600],
                            ),
                            label: Text(
                                post.likeCount > 0 ? '${post.likeCount} Thích' : 'Thích',
                                style: TextStyle(
                                    color: isLiked ? Colors.blue : Colors.grey[700],
                                    fontSize: 13,
                                    fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                                ),
                            ),
                        );
                    }
                ),
            ),

              // Nút Comment
              Expanded(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showComments = !_showComments),
                  icon: Icon(Icons.chat_bubble_outline,
                      size: 18, color: Colors.grey[600]),
                  label: Text(
                    post.commentCount > 0 ? '${post.commentCount} Bình luận' : 'Bình luận',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ),
              ),
            ],
        ),

          // Khu vực comment (ẩn/hiện) 
          if (_showComments) ...[
            const Divider(height: 1),
            // Danh sách comment hiện có
            if (post.comments.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: post.comments.length,
                itemBuilder: (_, i) {
                  final c = post.comments[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.green[50],
                          backgroundImage: (c.userAvatar != null && c.userAvatar!.isNotEmpty)
                              ? NetworkImage(c.userAvatar!)
                              : null,
                          child: (c.userAvatar == null || c.userAvatar!.isEmpty)
                              ? const Icon(Icons.person, size: 14, color: Colors.green)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.userName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(c.text, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            // Ô nhập comment
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Viết bình luận...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isCommenting
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2))
                      : GestureDetector(
                          onTap: _submitComment,
                          child: Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send, color: Colors.white, size: 18),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.orange[700]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

