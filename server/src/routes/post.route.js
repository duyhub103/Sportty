const express = require('express');
const router = express.Router();
const postController = require('../controllers/post.controller');
const { protect } = require('../middlewares/auth.middleware');
const uploadCloud = require('../configs/cloudinary');

// Tất cả route đều yêu cầu đăng nhập
router.use(protect);

// Lấy danh sách bài đăng
router.get('/', postController.getPosts);

// Tạo bài đăng mới (có thể kèm ảnh, field name là 'image')
router.post('/', uploadCloud.single('image'), postController.createPost);

// Like / Bỏ Like
router.put('/:id/like', postController.likePost);

// Thêm comment
router.post('/:id/comments', postController.addComment);

module.exports = router;
