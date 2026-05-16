const activityRepository = require('../repositories/activity.repository');
const teamRepository = require('../repositories/team.repository');
const notificationService = require('./notification.service');

class ActivityService {
    
    async createActivity(teamId, userId, data, io) {
        const team = await teamRepository.getTeamById(teamId);
        if (!team) {
            const error = new Error('Team not found');
            error.statusCode = 404;
            throw error;
        }

        const isMember = team.members.find(m => m.userId?._id.toString() === userId.toString());
        // Lấy ID Đội trưởng
        const captainIdStr = team.captainId ? team.captainId.toString() : '';

        if (!isMember || (isMember.userId._id.toString() !== captainIdStr && isMember.role !== 'VICE_CAPTAIN')) {
             const error = new Error('Only Captain or Vice Captain can create activities');
             error.statusCode = 403;
             throw error;
        }

        // Xử lý dữ liệu tùy theo loại bài đăng
        let newActivityData = {
            teamId,
            createdBy: userId,
            type: data.type.toUpperCase(),
            content: data.content,
            voteOptions: []
        };

        if (newActivityData.type === 'NOTICE') {
            newActivityData.voteOptions = [];
        } else if (newActivityData.type === 'VOTE') {
            if (!data.options || !Array.isArray(data.options) || data.options.length < 2) {
                const error = new Error('VOTE must have at least 2 options');
                error.statusCode = 400;
                throw error;
            }
            newActivityData.voteOptions = data.options.map(opt => ({ label: opt, voters: [] }));
        } else if (newActivityData.type === 'MATCH_SCHEDULE') {
             newActivityData.voteOptions = [
                 { label: 'Có mặt', voters: [] },
                 { label: 'Vắng mặt', voters: [] }
             ];
        } else {
            const error = new Error('Invalid activity type');
            error.statusCode = 400;
            throw error;
        }

        if (io && (newActivityData.type === 'MATCH_SCHEDULE' || newActivityData.type === 'VOTE')) {
            try {
                for (const member of team.members) {
                    const memberId = member.userId._id ? member.userId._id.toString() : member.userId.toString();
                    
                    if (memberId !== userId.toString()) {
                        await notificationService.createAndSendNotification({
                            recipientId: memberId,
                            senderId: userId,
                            type: newActivityData.type, 
                            content: `Đội trưởng vừa tạo một ${newActivityData.type === 'VOTE' ? 'cuộc bình chọn' : 'lịch điểm danh'} mới trong đội ${team.name}. Vào xem ngay!`,
                            relatedId: team._id
                        }, io);
                    }
                };
            } catch (error) {
                console.error('🔴 Lỗi khi gửi Notification Bảng tin:', error);
            }
        }

        const saved = await activityRepository.createActivity(newActivityData);

        // Populate lại để có đủ thông tin trả về và emit
        const TeamActivity = require('../models/TeamActivity');
        const populated = await TeamActivity.findById(saved._id)
            .populate('createdBy', 'fullName displayName avatar')
            .populate('voteOptions.voters', 'fullName displayName avatar');

        const { ActivityResponseDTO } = require('../_dtos/activity.dto');

        // Emit real-time cho cả phòng team
        if (io) {
            console.log('Emitting new_activity to room:', teamId.toString());
            io.to(teamId.toString()).emit('new_activity', new ActivityResponseDTO(populated));
        }

        return populated;
    }

    // Lấy danh sách Bảng tin
    async getActivities(teamId, page = 1, limit = 20) {
        const skip = (page - 1) * limit;
        return await activityRepository.getActivitiesByTeam(teamId, skip, limit);
    }

    // User tương tác (Vote hoặc Điểm danh)
    async interactActivity(activityId, userId, optionId, io) {
        const activity = await activityRepository.getActivityById(activityId);
        
        if (!activity) {
            const error = new Error('Activity not found');
            error.statusCode = 404;
            throw error;
        }

        // Chỉ cho phép Vote với loại VOTE hoặc MATCH_SCHEDULE
        if (activity.type === 'NOTICE') {
            const error = new Error('Cannot interact with a NOTICE');
            error.statusCode = 400;
            throw error;
        }

        // Tìm Option mà User vừa bấm
        const targetOption = activity.voteOptions.find(opt => opt._id.toString() === optionId.toString());
        if (!targetOption) {
            const error = new Error('Vote option not found');
            error.statusCode = 404;
            throw error;
        }

        activity.voteOptions.forEach(opt => {
            opt.voters = opt.voters.filter(voterId => voterId.toString() !== userId.toString());
        });

        targetOption.voters.push(userId);

        await activityRepository.saveActivity(activity);

        if (io) {
            const TeamActivity = require('../models/TeamActivity');
            const populated = await TeamActivity.findById(activityId)
                .populate('createdBy', 'fullName displayName avatar')
                .populate('voteOptions.voters', 'fullName displayName avatar');

            const { ActivityResponseDTO } = require('../_dtos/activity.dto');
            const teamId = populated.teamId.toString();

            io.to(teamId).emit('activity_updated', new ActivityResponseDTO(populated));
        }
        
        return { message: 'Vote recorded successfully' };
    }
}

module.exports = new ActivityService();