const matchRepository = require('../repositories/match.repository');

class MatchService {
    async getMyMatches(userId) {
        // chỉ cần gọi Repo
        // mọi logic sort/populate đã xử lý ở Repo
        return await matchRepository.getUserMatches(userId);
    }
}

module.exports = new MatchService();