const messageRepository = require('../repositories/message.repository');
const matchRepository = require('../repositories/match.repository'); // Gọi chéo để check quyền

const teamRepository = require('../repositories/team.repository');

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

    async getTeamMessages(teamId, userId, page = 1, limit = 20) {
        // check team tồn tại
        const team = await teamRepository.getTeamById(teamId);
        if (!team) {
            const error = new Error('Team not found');
            error.statusCode = 404;
            // format lỗi trả về cho client dễ xử lý
            error.errors = { code: 'TEAM_NOT_FOUND', details: 'Không tìm thấy đội bóng này' }; 
            throw error;
        }

        // check user có phải là thành viên của đội không
        const isMember = team.members.find(m => m.userId?._id.toString() === userId.toString());
        if (!isMember) {
            const error = new Error('Permission denied');
            error.statusCode = 403;
            error.errors = { code: 'NOT_TEAM_MEMBER', details: 'Bạn phải là thành viên mới được xem tin nhắn' };
            throw error;
        }

        // Phân trang và lấy dữ liệu
        const skip = (page - 1) * limit;
        return await messageRepository.getTeamMessages(teamId, skip, limit);
    }

    // gửi tin nhắn (1-1 và Chat Nhóm)
    async sendMessage(senderId, conversationId, type, content, contentType, io) {
        if (type === 'PRIVATE') {
            const match = await matchRepository.getMatchById(conversationId);
            
            // Kiểm tra Match có tồn tại không, và người gửi có nằm trong mảng users của Match không
            if (!match || !match.users.some(id => id.toString() === senderId.toString())) {
                const error = new Error('Match not found or permission denied');
                error.statusCode = 403;
                throw error;
            }
        } else if (type === 'GROUP') {
            const team = await teamRepository.getTeamById(conversationId);
            if (!team || !team.members.some(m => m.userId?._id.toString() === senderId.toString())) {
                const error = new Error('Team not found or permission denied');
                error.statusCode = 403;
                throw error;
            }
        }
        // Lưu tin nhắn vào DB
        const newMessage = await messageRepository.createMessage({
            conversationId,
            senderId,
            type, 
            content,
            contentType
        });

        // Lấy thêm thông tin người gửi (Tên, Avatar) để App hiển thị
        const populatedMessage = await newMessage.populate('senderId', 'fullName displayName avatar');

        // Cập nhật Tin nhắn cuối và Phát loa
        if (type === 'GROUP') {
            await teamRepository.updateTeam(conversationId, {
                lastMessage: content,
                lastMessageTime: new Date()
            });
            // Phát cho anh em trong đội
            if (io) io.to(conversationId.toString()).emit('receive_team_message', populatedMessage);
            
        } else if (type === 'PRIVATE') {
            // Cập nhật lastMessage cho Match (đảm bảo matchRepository có hàm updateMatch)
            await matchRepository.updateMatch(conversationId, {
                lastMessage: content,
                lastMessageTime: new Date()
            });
            // Phát cho 2 người trong phòng chat 1-1
            if (io) io.to(conversationId.toString()).emit('receive_message', populatedMessage);
        }

        return populatedMessage;
    }

    async deleteMessage(messageId, conversationId, type) {
        // Xóa tin nhắn khỏi DB
        await messageRepository.deleteById(messageId);

        // Móc tin nhắn sát ngay trước đó lên
        const lastMsg = await messageRepository.getLatestMessage(conversationId);

        // Nếu còn tin nhắn thì lấy nội dung, nếu hết sạch thì gán chuỗi rỗng
        const lastMessageText = lastMsg ? lastMsg.content : "";
        const lastMessageTime = lastMsg ? lastMsg.createdAt : null;

        // Cập nhật lại phòng Chat
        if (type === 'PRIVATE') {
            await matchRepository.updateMatch(conversationId, {
                lastMessage: lastMessageText,
                lastMessageTime: lastMessageTime
            });
        } else if (type === 'GROUP') {
            await teamRepository.updateTeam(conversationId, {
                lastMessage: lastMessageText,
                lastMessageTime: lastMessageTime
            });
        }

        return { message: "Message deleted successfully" };
    }
}

module.exports = new MessageService();