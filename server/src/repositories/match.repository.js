const Match = require('../models/Match');

class MatchRepository {
    // 1. Kiểm tra xem 2 người này đã có phòng Match chưa (tránh tạo trùng)
    async checkMatchExists(user1Id, user2Id) {
        return await Match.findOne({
            // Tìm phòng mà mảng users chứa CẢ 2 ID này (không phân biệt thứ tự)
            users: { $all: [user1Id, user2Id] }
        });
    }

    // 2. Tạo phòng Match mới
    async createMatch(user1Id, user2Id) {
        return await Match.create({
            users: [user1Id, user2Id] // Lưu 2 ID vào mảng
            // lastMessage mặc định là rỗng
        });
    }

    async getUserMatches(userId) {
        return await Match.find({ users: userId })
        .populate('users', 'fullName displayName avatar') // populate Tự động móc sang bảng User để lấy tên và avatar, không lấy password
        .sort({ updatedAt: -1 }); // chat gần nhất đưa lên đầu
    }
}

module.exports = new MatchRepository();