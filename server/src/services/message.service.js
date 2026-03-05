const messageRepository = require('../repositories/message.repository');
const matchRepository = require('../repositories/match.repository'); // Gọi chéo để check quyền

class MessageService {
    async getMatchMessages(userId, matchId, page = 1, limit = 20) {
        // check quyền truy cập phòng chat của user
        const match = await matchRepository.checkMatchExists(userId, userId); // Kiểm tra xem user có thuộc phòng chat này không

        const Match = require('../models/Match');
        const isMember = await Match.findOne({ _id: matchId, users: userId });

        if (!isMember) {
            const error = new Error('You do not have permission to view this chat');
            error.statusCode = 403;
            throw error; 
        }
        // Tính toán phân trang
        const skip = (page - 1) * limit;

        // Lấy tin nhắn
        const messages = await messageRepository.getMessagesByMatchId(matchId, skip, limit);
        return messages;
    }
}

module.exports = new MessageService();