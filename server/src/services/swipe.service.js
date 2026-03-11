const swipeRepository = require('../repositories/swipe.repository');
const matchRepository = require('../repositories/match.repository');
const userRepository = require('../repositories/user.repository'); // Import để check user tồn tại
const NotificationService = require('./notification.service'); 

class SwipeService {
    async handleSwipe(swiperId, receiverId, type, io) {
        // Không cho phép tự quẹt chính mình
        if (swiperId === receiverId) {
            const error = new Error('You cannot swipe yourself');
            error.statusCode = 400;
            throw error;
        }

        // Người bị quẹt có tồn tại
        const receiverExists = await userRepository.findById(receiverId);
        if (!receiverExists) {
            const error = new Error('Receiver not found');
            error.statusCode = 404;
            throw error;
        }

        // Kiểm tra xem A đã quẹt B bao giờ chưa? (Tránh gọi API spam)
        const existingSwipe = await swipeRepository.checkAlreadySwiped(swiperId, receiverId);
        if (existingSwipe) {
            const error = new Error('You have already swiped this user');
            error.statusCode = 400;
            throw error;
        }

        // Lưu thao tác quẹt vào DB
        await swipeRepository.createSwipe(swiperId, receiverId, type);

        let isMatch = false;
        let matchId = null;

        // Nếu A quẹt LIKE B
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
                
                // thông báo
                try {
                    await notificationService.createAndSendNotification({
                        recipientId: swiperId,
                        senderId: receiverId,
                        type: 'NEW_MATCH',
                        content: `Bùm! Bạn và đối phương đã tương hợp. Vào chat ngay đi nào!`,
                        relatedId: matchId // Gắn ID phòng chat
                    }, io);

                    // Báo cho người kia biết
                    await notificationService.createAndSendNotification({
                        recipientId: receiverId,
                        senderId: swiperId,
                        type: 'NEW_MATCH',
                        content: `Bùm! Có người vừa tương hợp với bạn.`,
                        relatedId: matchId
                    }, io);
                } catch (error) {
                    console.error('🔴 Lỗi khi gửi Notification Match:', error);
                }
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