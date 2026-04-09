// DTO cho 1 phòng Match
class MatchResponseDTO {
    constructor(match, currentUserId) {
        this.id = match._id;
        this.lastMessage = match.lastMessage || '';
        this.lastMessageTime = match.lastMessageTime;
        this.updatedAt = match.updatedAt;

        // Tìm ra người kia trong mảng users
        // Lọc bỏ id của chính mình, giữ lại id của người kia
        const partner = match.users.find(u => u._id.toString() !== currentUserId.toString());
        
        if (partner) {
            this.partner = {
                id: partner._id,
                displayName: partner.displayName || partner.fullName,
                avatar: partner.avatar || ''
            };
        } else {
            this.partner = null; // trường hợp lỗi data
        }
    }
}

// DTO cho 1 dòng tin nhắn
class MessageResponseDTO {
    constructor(message) {
        this.id = message._id || message.id;
        this.conversationId = message.conversationId;
        this.type = message.type;
        this.content = message.content;
        this.contentType = message.contentType; // text, image, file, ..
        this.isRead = message.isRead;
        this.createdAt = message.createdAt;

        // Mặc định senderId là Object do Repo đã bắt buộc populate
        if (message.senderId) {
            this.senderId = message.senderId._id || message.senderId;
            this.sender = {
                id: message.senderId._id,
                displayName: message.senderId.displayName || message.senderId.fullName || 'Unknown',
                avatar: message.senderId.avatar || ''
            };
        } else {
            this.senderId = null;
            this.sender = null;
        }
    }
}

module.exports = { MatchResponseDTO, MessageResponseDTO };