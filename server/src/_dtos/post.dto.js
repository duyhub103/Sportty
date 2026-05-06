class PostResponseDTO {
    constructor(post) {
        this.id = post._id;
        this.type = post.type;
        this.content = post.content;
        this.image = post.image || '';
        this.createdAt = post.createdAt;

        // Thông tin trận đấu (chỉ có khi type = 'MATCH')
        this.sport = post.sport || null;
        this.location = post.location || null;
        this.time = post.time || null;

        // Đếm lượt tương tác
        this.likeCount = post.likes?.length || 0;
        this.commentCount = post.comments?.length || 0;

        // Thông tin tác giả (đã populate từ bảng User)
        if (post.author && typeof post.author === 'object') {
            this.author = {
                id: post.author._id,
                displayName: post.author.displayName || post.author.fullName || 'Người dùng',
                avatar: post.author.avatar || ''
            };
        } else {
            this.author = null;
        }

        // Danh sách comment (mỗi comment có thông tin user đã populate)
        this.comments = (post.comments || []).map(c => ({
            id: c._id,
            text: c.text,
            createdAt: c.createdAt,
            user: (c.user && typeof c.user === 'object') ? {
                id: c.user._id,
                displayName: c.user.displayName || c.user.fullName || 'Người dùng',
                avatar: c.user.avatar || ''
            } : null
        }));
    }
}

module.exports = { PostResponseDTO };
