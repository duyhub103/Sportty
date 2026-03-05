const Message = require('../models/Message');

class MessageRepository {
    // lấy lịch sử tin nhắn 1 phòng phân trang
    async getMessagesByMatchId(matchId, skip = 0, limit = 20) {
        return await Message.find({ conversationId: matchId })
            .sort({ createdAt: -1 }) // Sắp xếp mới nhất lên trước
            .skip(skip)
            .limit(limit);
    }

    // tạo tin nhắn mới
    async createMessage(data){
        return await Message.create(data);
    }
}

module.exports = new MessageRepository();