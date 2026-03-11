const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const notificationSchema = new Schema({
    // Người nhận thông báo
    recipientId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    
    // Người gây ra hành động (VD: Văn A xin vào đội, thì senderId là Văn A)
    // Có thể null nếu thông báo do Hệ thống tự phát
    senderId: { type: Schema.Types.ObjectId, ref: 'User' },
    
    // Loại thông báo (để App điều hướng)
    type: { 
        type: String, 
        enum: [
            'TEAM_INVITE',          // Có người xin gia nhập đội
            'TEAM_JOIN_APPROVED',   // Đơn xin gia nhập được duyệt
            'TEAM_JOIN_REJECTED',   // Đơn xin gia nhập bị từ chối
            'MATCH_SCHEDULE',       // Đội trưởng lên lịch điểm danh
            'SYSTEM',                // Thông báo chung từ hệ thống
            'VOTE',
            'NEW_MATCH'
        ], 
        required: true 
    },
    
    // Nội dung ngắn gọn hiển thị ra ngoài
    content: { type: String, required: true },
    
    // ID của Đội bóng hoặc Trận đấu liên quan (Để App biết đường bấm vào thì mở trang nào)
    relatedId: { type: Schema.Types.ObjectId },
    
    // Trạng thái (Đã đọc chưa? Dùng để đếm số lượng chấm đỏ)
    isRead: { type: Boolean, default: false }
}, { timestamps: true });

// Đánh index để truy vấn thông báo của 1 user nhanh hơn
notificationSchema.index({ recipientId: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);