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

    async getTeamMessages(teamId, skip = 0, limit = 20) {
        return await Message.find({ 
            conversationId: teamId, 
            type: 'GROUP' // Đảm bảo chỉ lấy tin nhắn nhóm
        })
        .populate('senderId', 'fullName displayName avatar') // Móc thông tin người gửi
        .sort({ createdAt: -1 }) // mới nhất
        .skip(skip)
        .limit(limit);
    }
}

module.exports = new MessageRepository();