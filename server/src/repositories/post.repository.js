const Post = require('../models/Post');

class PostRepository {

    // Tạo bài đăng mới
    async createPost(data) {
        const newPost = await Post.create(data);
        // Populate author ngay sau khi tạo để trả về đầy đủ thông tin
        return await newPost.populate('author', 'displayName fullName avatar');
    }

    // Lấy danh sách bài đăng (mới nhất lên đầu, có phân trang)
    async getPosts(skip = 0, limit = 10) {
        return await Post.find()
            .populate('author', 'displayName fullName avatar')
            .populate('comments.user', 'displayName fullName avatar')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .lean();
    }

    // Lấy chi tiết 1 bài đăng (dùng sau khi addComment để trả về post mới nhất)
    async getPostById(postId) {
        return await Post.findById(postId)
            .populate('author', 'displayName fullName avatar')
            .populate('comments.user', 'displayName fullName avatar');
    }

    // Thêm comment vào bài đăng
    async addComment(postId, userId, text) {
        await Post.findByIdAndUpdate(
            postId,
            { $push: { comments: { user: userId, text: text } } },
            { new: true }
        );
        // Trả về post đã được populate đầy đủ
        return await this.getPostById(postId);
    }

    // Toggle Like: Nếu đã like thì bỏ, chưa like thì thêm
    async toggleLike(postId, userId) {
        const post = await Post.findById(postId).select('likes');
        if (!post) throw Object.assign(new Error('Post not found'), { statusCode: 404 });

        const hasLiked = post.likes.some(id => id.toString() === userId.toString());

        if (hasLiked) {
            // Đã like rồi → bỏ like
            await Post.findByIdAndUpdate(postId, { $pull: { likes: userId } });
        } else {
            // Chưa like → thêm vào
            await Post.findByIdAndUpdate(postId, { $addToSet: { likes: userId } });
        }

        return { liked: !hasLiked };
    }
}

module.exports = new PostRepository();
