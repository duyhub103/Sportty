// src/routes/user.route.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { protect } = require('../middlewares/auth.middleware');

// Tất cả các route yêu cầu đăng nhập
router.use(protect);

router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);
router.get('/nearby', userController.getNearbyUsers);

module.exports = router;