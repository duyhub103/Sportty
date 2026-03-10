const Notification = require('../models/Notification');

class NotificationRepository {
    
    // Tạo 1 thông báo mới (Sẽ được gọi ngầm khi có sự kiện xảy ra)
    async createNotification(data) {
        const notification = await Notification.create(data);
        // Trả về luôn thông tin người gửi để Socket.io có data phát loa
        return await notification.populate('senderId', 'fullName displayName avatar');
    }

    // Lấy danh sách thông báo của 1 User (phân trang)
    async getNotificationsByUser(userId, skip = 0, limit = 20) {
        return await Notification.find({ recipientId: userId })
            .populate('senderId', 'fullName displayName avatar')
            .sort({ createdAt: -1 }) // Mới nhất nổi lên đầu
            .skip(skip)
            .limit(limit);
    }

    // Đánh dấu 1 thông báo là đã đọc (Khi User bấm vào)
    async markAsRead(notificationId, userId) {
        return await Notification.findOneAndUpdate(
            { _id: notificationId, recipientId: userId }, // Đảm bảo đúng chủ mới được sửa
            { isRead: true },
            { new: true }
        );
    }

    // Đánh dấu tất cả là đã đọc
    async markAllAsRead(userId) {
        return await Notification.updateMany(
            { recipientId: userId, isRead: false },
            { isRead: true }
        );
    }
}

module.exports = new NotificationRepository();