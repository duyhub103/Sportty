const swipeService = require('../services/swipe.service');
const asyncHandler = require('../utils/asyncHandler');

class SwipeController {
    // POST /api/swipes
    swipe = asyncHandler(async (req, res) => {
        const swiperId = req.user.id; // Lấy ID của người đang đăng nhập (nhờ authMiddleware)
        const { receiverId, type } = req.body;
        const io = req.app.get('io'); // Lấy instance Socket.io từ app.js

        // Validate cơ bản đầu vào
        if (!receiverId || !type) {
            const error = new Error('receiverId and type are required');
            error.statusCode = 400;
            throw error;
        }

        // Đảm bảo type chỉ gửi lên đúng 2 chữ này
        if (!['LIKE', 'DISLIKE'].includes(type.toUpperCase())) {
            const error = new Error('Invalid swipe type. Must be LIKE or DISLIKE');
            error.statusCode = 400;
            throw error;
        }

        // Gọi service xử lý
        const result = await swipeService.handleSwipe(swiperId, receiverId, type.toUpperCase(), io);

        res.success(result, 'Swiped successfully');
    });
}

module.exports = new SwipeController();