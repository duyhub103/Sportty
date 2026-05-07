const postService = require('../services/post.service');
const asyncHandler = require('../utils/asyncHandler');
const { PostResponseDTO } = require('../_dtos/post.dto');

class PostController {

    // POST /api/posts — Tạo bài đăng mới
    createPost = asyncHandler(async (req, res) => {
        const userId = req.user.id;
        // req.file.path là URL ảnh từ Cloudinary (nếu có upload ảnh)
        const imageUrl = req.file ? req.file.path : null;

        const post = await postService.createPost(userId, req.body, imageUrl);
        res.success(new PostResponseDTO(post), 'Post created successfully', 201);
    });

    // GET /api/posts?page=1&limit=10 — Lấy danh sách bài đăng
    getPosts = asyncHandler(async (req, res) => {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;

        const posts = await postService.getPosts(page, limit);
        const result = posts.map(p => new PostResponseDTO(p));
        res.success(result, 'Get posts successfully');
    });

    // PUT /api/posts/:id/like — Like / Bỏ Like
    likePost = asyncHandler(async (req, res) => {
        const io = req.app.get('io');
        const result = await postService.likePost(req.params.id, req.user.id);
        
        res.success(result, result.liked ? 'Liked' : 'Unliked');

        const updatedPost = await postService.getPostById(req.params.id);
        if (updatedPost) {
            io.emit('post_updated', new PostResponseDTO(updatedPost));
        }
    });

    // POST /api/posts/:id/comments — Thêm comment
    addComment = asyncHandler(async (req, res) => {
        const io = req.app.get('io');
        const { text } = req.body;
        const post = await postService.addComment(req.params.id, req.user.id, text);
        res.success(new PostResponseDTO(post), 'Comment added successfully');
        // Broadcast cho tất cả user
        io.emit('post_updated', new PostResponseDTO(post));
    });
}

module.exports = new PostController();
