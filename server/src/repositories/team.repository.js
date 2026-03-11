const Team = require('../models/Team');

class TeamRepository {
    // Tạo đội mới
    async createTeam(teamData) {
        const newTeam = await Team.create(teamData);
        return await newTeam.populate('members.userId', 'fullName displayName avatar');   
    }

    // Lấy danh sách Đội (tìm kiếm theo tên và lọc theo môn)
    async getTeams(filter = {}) {
        const query = {};
        
        // Nếu client gửi lên môn thể thao (VD: Football)
        if (filter.sport) query.sport = filter.sport;
        
        // Nếu client gõ tìm kiếm (VD: "Manchester")
        if (filter.keyword) {
            query.name = { $regex: filter.keyword, $options: 'i' }; // 'i' là không phân biệt hoa/thường
        }
        
        return await Team.find(query)
            .populate('members.userId', 'fullName displayName avatar') // Kéo theo info thành viên
            .sort({ createdAt: -1 }); // Mới nhất lên đầu
    }

    // Lấy chi tiết 1 đội
    async getTeamById(teamId) {
        return await Team.findById(teamId)
            .populate('members.userId', 'fullName displayName avatar');
    }

    // Thêm 1 thành viên vào mảng members
    async addMember(teamId, userId, role = 'MEMBER') {
        return await Team.findByIdAndUpdate(
            teamId,
            {
                $push: { // đẩy phần tử mới vào mảng
                    members: { userId: userId, role: role, joinedAt: new Date() }
                }
            },
            { new: true } // Trả về data mới nhất sau khi update
        ).populate('members.userId', 'fullName displayName avatar');
    }

    // Cập nhật quỹ đội (Cộng/Trừ tiền)
    async updateFund(teamId, amount) {
        return await Team.findByIdAndUpdate(
            teamId,
            { $inc: { fund: amount } }, // $inc: Tăng/giảm giá trị hiện tại (âm thì giảm, dương thì tăng)
            { new: true }
        );
    }

    // Thêm user vào danh sách chờ duyệt
    async addPendingRequest(teamId, userId) {
        return await Team.findByIdAndUpdate(
            teamId,
            { $addToSet: { pendingRequests: userId } }, // $addToSet: Thêm vào mảng nếu chưa có (tránh trùng lặp)
            { new: true }
        );
    }

    // Xóa user khỏi danh sách chờ khi đã duyệt hoặc từ chối
    async removePendingRequest(teamId, userId) {
        return await Team.findByIdAndUpdate(
            teamId,
            { $pull: { pendingRequests: userId } }, // $pull: Rút ID này ra khỏi mảng
            { new: true }
        );
    }

    // Cập nhật thông tin bất kỳ của Đội
    async updateTeam(teamId, updateData) {
        return await Team.findByIdAndUpdate(
            teamId, 
            updateData, 
            { new: true } // Trả về data mới nhất sau khi sửa
        ).populate('captainId', 'fullName displayName avatar'); // Nhớ populate nếu DTO của bạn cần thông tin Captain
    }
}

module.exports = new TeamRepository();