const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chat.controller');
const { protect } = require('../middlewares/auth.middleware');

router.use(protect); // Bắt buộc đăng nhập

router.post('/messages', chatController.sendMessage);
router.get('/matches', chatController.getMatches);
router.get('/messages/:matchId', chatController.getMessages);

module.exports = router;