const postRepository = require('../repositories/post.repository');

class PostService {

    // Tạo bài đăng mới
    async createPost(userId, body, imageUrl) {
        const { type, content, sport, location, time } = body;

        // Validate: Nếu là bài tìm kèo thì phải đủ thông tin
        if (type === 'MATCH') {
            if (!sport || !location || !time) {
                const error = new Error('Bài tìm kèo cần có môn thể thao, địa điểm và thời gian');
                error.statusCode = 400;
                throw error;
            }
        }

        const postData = {
            author: userId,
            type: type || 'DISCUSSION',
            content,
            image: imageUrl || '',
            sport: sport || undefined,
            location: location || undefined,
            time: time ? new Date(time) : undefined,
        };

        return await postRepository.createPost(postData);
    }

    // Lấy danh sách bài đăng (có phân trang)
    async getPosts(page = 1, limit = 10) {
        const skip = (page - 1) * limit;
        return await postRepository.getPosts(skip, limit);
    }

    // Like / Bỏ Like
    async likePost(postId, userId) {
        return await postRepository.toggleLike(postId, userId);
    }

    async getPostById(postId) {
        return await postRepository.getPostById(postId);
    }


    // Thêm comment
    async addComment(postId, userId, text) {
        if (!text || text.trim() === '') {
            const error = new Error('Nội dung comment không được để trống');
            error.statusCode = 400;
            throw error;
        }
        return await postRepository.addComment(postId, userId, text.trim());
    }
}

module.exports = new PostService();
