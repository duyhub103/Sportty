const matchRepository = require('../repositories/match.repository');
const Match = require('../models/Match');
const Message = require('../models/Message');

class MatchService {
    async getMyMatches(userId) {
        // chỉ cần gọi Repo
        // mọi logic sort/populate đã xử lý ở Repo
        return await matchRepository.getUserMatches(userId);
    }

    async unmatch(matchId, userId) {    
        const match = await Match.findById(matchId);
        if (!match) {
            throw Object.assign(new Error('Match không tồn tại'), { statusCode: 404 });
        }

        // Chỉ 2 user trong match mới được xóa
        if (!match.users.some(u => u.toString() === userId.toString())) {
            throw Object.assign(new Error('Không có quyền thực hiện'), { statusCode: 403 });
        }

        // Xóa tất cả tin nhắn của match này
        await Message.deleteMany({ conversationId: matchId });

        // Xóa match
        await Match.findByIdAndDelete(matchId);
    }
}

module.exports = new MatchService();