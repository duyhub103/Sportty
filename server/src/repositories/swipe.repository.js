const Swipe = require('../models/swipe.model');

class SwipeRepository {
    // 1. Tạo bản ghi quẹt mới
    async createSwipe(swiperId, receiverId, type) {
        return await Swipe.create({ swiperId, receiverId, type });
    }

    // 2. Kiểm tra xem A đã quẹt B bao giờ chưa?
    async checkAlreadySwiped(swiperId, receiverId) {
        return await Swipe.findOne({ swiperId, receiverId });
    }

    // 3. Quan trọng nhất: Kiểm tra xem B có LIKE A trước đó không? (Để tạo Match)
    async checkReceiverLikedSwiper(receiverId, swiperId) {
        return await Swipe.findOne({ 
            swiperId: receiverId, // B là người quẹt
            receiverId: swiperId, // A là người bị quẹt
            type: 'LIKE' 
        });
    }

    // 4. Lấy danh sách ID của những người mà A đã quẹt (Dùng để loại trừ ở màn hình Home)
    async getSwipedIds(swiperId) {
        const swipes = await Swipe.find({ swiperId }).select('receiverId');
        // Map mảng object thành mảng các chuỗi ID: ['id_1', 'id_2']
        return swipes.map(swipe => swipe.receiverId.toString());
    }
}

module.exports = new SwipeRepository();