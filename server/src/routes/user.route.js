// src/routes/user.route.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { protect } = require('../middlewares/auth.middleware');
const uploadCloud = require('../configs/cloudinary');

// Tất cả các route yêu cầu đăng nhập
router.use(protect);

router.get('/profile', userController.getProfile);
// Dùng uploadCloud.fields để hứng file trước khi vào Controller
router.put(
    '/profile', 
    uploadCloud.fields([
        { name: 'avatar', maxCount: 1 },     // Chỉ nhận 1 file cho field avatar
        { name: 'gallery', maxCount: 10 }     // Nhận tối đa 10 file cho field gallery
    ]), 
    userController.updateProfile
);
router.get('/nearby', userController.getNearbyUsers);

module.exports = router;