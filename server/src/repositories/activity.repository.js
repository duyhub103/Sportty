const TeamActivity = require('../models/TeamActivity'); // Cập nhật tên file model nếu cần

class ActivityRepository {
    
    // Tạo bài viết mới (Thông báo, Vote, Lịch đá)
    async createActivity(data) {
        const activity = await TeamActivity.create(data);
        // Tự động populate người tạo ngay sau khi đăng
        return await activity.populate('createdBy', 'fullName displayName avatar');
    }

    // Lấy danh sách Bảng tin của 1 đội
    async getActivitiesByTeam(teamId) {
        return await TeamActivity.find({ teamId })
            .populate('createdBy', 'fullName displayName avatar') // Lấy người đăng
            .populate('voteOptions.voters', 'fullName displayName avatar') // Lấy danh sách người đã vote
            .sort({ createdAt: -1 }); // Bài mới nhất nổi lên đầu
    }

    // Lấy 1 bài viết cụ thể (Dùng nội bộ để xử lý logic khi có người bấm Vote)
    async getActivityById(activityId) {
        return await TeamActivity.findById(activityId);
    }

    // Lưu lại sau khi thay đổi data trong RAM (Dùng cho logic Vote)
    async saveActivity(activity) {
        return await activity.save();
    }
}

module.exports = new ActivityRepository();