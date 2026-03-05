const express = require('express');
const router = express.Router();
const swipeController = require('../controllers/swipe.controller');
const { protect } = require('../middlewares/auth.middleware');

// Bắt buộc phải đăng nhập mới được quẹt thẻ
router.use(protect);

router.post('/', swipeController.swipe);

module.exports = router;