const TeamActivity = require('../models/TeamActivity');

class ActivityRepository {
    
    // Tạo bài viết mới
    async createActivity(data) {
        const activity = await TeamActivity.create(data);
        // Tự động populate người tạo ngay sau khi đăng
        return await activity.populate('createdBy', 'fullName displayName avatar');
    }

    // Lấy danh sách Bảng tin của 1 đội
    async getActivitiesByTeam(teamId, skip = 0, limit = 10) {
        return await TeamActivity.find({ teamId })
            .populate('createdBy', 'fullName displayName avatar')
            .populate('voteOptions.voters', 'fullName displayName avatar')
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 });
    }

    // Lấy 1 bài viết cụ thể
    async getActivityById(activityId) {
        return await TeamActivity.findById(activityId);
    }

    // Lưu lại sau khi thay đổi data trong RAM
    async saveActivity(activity) {
        return await activity.save();
    }
}

module.exports = new ActivityRepository();