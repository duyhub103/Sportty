const swipeRepository = require('../repositories/swipe.repository');
const matchRepository = require('../repositories/match.repository');
const userRepository = require('../repositories/user.repository'); // Import để check user tồn tại

class SwipeService {
    async handleSwipe(swiperId, receiverId, type) {
        // 1. Validate: Không cho phép tự quẹt chính mình
        if (swiperId === receiverId) {
            const error = new Error('You cannot swipe yourself');
            error.statusCode = 400;
            throw error;
        }

        // 2. Validate: Người bị quẹt có tồn tại
        const receiverExists = await userRepository.findById(receiverId);
        if (!receiverExists) {
            const error = new Error('Receiver not found');
            error.statusCode = 404;
            throw error;
        }

        // 3. Validate: Kiểm tra xem A đã quẹt B bao giờ chưa? (Tránh gọi API spam)
        const existingSwipe = await swipeRepository.checkAlreadySwiped(swiperId, receiverId);
        if (existingSwipe) {
            const error = new Error('You have already swiped this user');
            error.statusCode = 400;
            throw error;
        }

        // 4. Lưu thao tác quẹt vào DB
        await swipeRepository.createSwipe(swiperId, receiverId, type);

        let isMatch = false;
        let matchId = null;

        // 5. LOGIC MATCHING: Nếu A quẹt LIKE B
        if (type === 'LIKE') {
            // Lén kiểm tra xem trước đó B có LIKE A không?
            const hasReceiverLiked = await swipeRepository.checkReceiverLikedSwiper(receiverId, swiperId);
            
            if (hasReceiverLiked) {
                isMatch = true; // match thành công
                
                // check xem đã có phòng Match chưa (tránh tạo trùng)
                let existingMatch = await matchRepository.checkMatchExists(swiperId, receiverId);
                
                if (!existingMatch) {
                    // Tạo phòng Chat 1-1 cho 2 người
                    existingMatch = await matchRepository.createMatch(swiperId, receiverId);
                }
                matchId = existingMatch._id;
                
                // 💡 Tương lai (Trạm 2): Nơi này sẽ gọi hàm gửi Push Notification & Socket.io
            }
        }

        // Trả về kết quả cho Controller
        return {
            isMatch,
            matchId
        };
    }
}

module.exports = new SwipeService();