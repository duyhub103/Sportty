const teamRepository = require('../repositories/team.repository');
const notificationService = require('./notification.service');

class TeamService {
    // Tạo đội mới 
    async createTeam(userId, teamData) {
        // Gắn người tạo vào mảng members với role là captain
        const newTeamData = {
            ...teamData,
            captainId: userId, // id của người tạo sẽ là captain
            members: [{
                userId: userId,
                role: 'MEMBER',
                joinedAt: new Date()
            }]
        };
        return await teamRepository.createTeam(newTeamData);
    }

    // Lấy danh sách đội
    async getTeams(filter) {
        return await teamRepository.getTeams(filter);
    }

    // Lấy chi tiết đội
    async getTeamById(teamId) {
        const team = await teamRepository.getTeamById(teamId);
        if (!team) throw Object.assign(new Error('Team not found'), { statusCode: 404 });
        return team;
    }

    // user gửi yêu cầu tham gia team
    async requestToJoin(teamId, userId, io) {
        const team = await this.getTeamById(teamId);

        // check xem có phải thành viên không
        const isMember = team.members.find(m => m.userId?._id.toString() === userId.toString());
        if (isMember) {
            throw Object.assign(new Error('You are already a member of this team'), { statusCode: 400 });
        }

        // check đã gửi yêu cầu
        const isPending = team.pendingRequests.includes(userId);
        if (isPending) {
            throw Object.assign(new Error('Your request is already pending approval'), { statusCode: 400 });
        }

        // Đẩy vào phòng chờ
        await teamRepository.addPendingRequest(teamId, userId);

        try {
            await notificationService.createAndSendNotification({
                recipientId: team.captainId,
                senderId: userId,
                type: 'TEAM_INVITE',
                content: `Có một thành viên mới vừa xin gia nhập đội ${team.name} của bạn.`,
                relatedId: team._id
            }, io);
        } catch (error) {
            console.error('🔴 Lỗi khi gửi Notification xin vào đội:', error);
        }
        
        return { message: 'Join request sent successfully. Waiting for Captain approval.' };
    }

    // captain duyệt yêu cầu
    async handleJoinRequest(teamId, actionUserId, targetUserId, action, io) {
        const team = await this.getTeamById(teamId);

        // check quyền captain
        const isCaptain = team.captainId.toString() === actionUserId.toString();
        // Hoặc có phải là Đội phó (VICE_CAPTAIN) không?
        const actionUserInMembers = team.members.find(m => m.userId?._id.toString() === actionUserId.toString());
        const isViceCaptain = actionUserInMembers && actionUserInMembers.role === 'VICE_CAPTAIN';
        if (!isCaptain && !isViceCaptain) {
            throw Object.assign(new Error('Only Captain or Vice Captain can approve requests'), { statusCode: 403 });
        }

        // check xem user có trong phòng chờ
        if (!team.pendingRequests.includes(targetUserId)) {
            throw Object.assign(new Error('This user has not requested to join'), { statusCode: 400 });
        }

        // Xử lý duyệt hoặc từ chối
        if (action === 'APPROVE') {
            // Rút khỏi phòng chờ, đẩy vào danh sách chính thức
            await teamRepository.removePendingRequest(teamId, targetUserId);
            await teamRepository.addMember(teamId, targetUserId, 'MEMBER');

            try {
                await notificationService.createAndSendNotification({
                    recipientId: targetUserId,
                    senderId: actionUserId,
                    type: 'TEAM_JOIN_APPROVED',
                    content: `Chúc mừng! Bạn đã được duyệt vào đội ${team.name}.`,
                    relatedId: team._id
                }, io);
            } catch (error) { 
                console.error(error); 
            }

            return { message: 'User approved and added to the team.' };

        } else if (action === 'REJECT') {
            // Chỉ cần rút khỏi phòng chờ
            await teamRepository.removePendingRequest(teamId, targetUserId);

            try {
                await notificationService.createAndSendNotification({
                    recipientId: targetUserId,
                    senderId: actionUserId,
                    type: 'TEAM_JOIN_REJECTED',
                    content: `Rất tiếc, yêu cầu gia nhập đội ${team.name} của bạn đã bị từ chối.`,
                    relatedId: team._id
                }, io);
            } catch (error) { console.error(error); }

            return { message: 'Join request rejected.' };

        } else {
            throw Object.assign(new Error('Invalid action. Must be APPROVE or REJECT'), { statusCode: 400 });
        }
    }

    // cập nhật quỹ đội
    async updateTeamFund(teamId, actionUserId, amount) {
        const team = await this.getTeamById(teamId);
        
        // check quyền captain hoặc vice-captain
        const isCaptain = team.captainId.toString() === actionUserId.toString();
        const actionUserInMembers = team.members.find(m => m.userId?._id.toString() === actionUserId.toString());
        const isViceCaptain = actionUserInMembers && actionUserInMembers.role === 'VICE_CAPTAIN';

        if (!isCaptain && !isViceCaptain) {
            const error = new Error('Only Captain or Vice Captain can manage team funds');
            error.statusCode = 403;
            throw error;
        }

        // check amount phải là số (âm là trừ tiền, dương là cộng tiền)
        if (typeof amount !== 'number' || isNaN(amount)) {
            const error = new Error('Invalid amount');
            error.statusCode = 400;
            throw error;
        }

        // Cập nhật quỹ đội
        return await teamRepository.updateFund(teamId, amount);
    }
}

module.exports = new TeamService();