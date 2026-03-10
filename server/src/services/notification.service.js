const notificationRepository = require('../repositories/notification.repository');

class NotificationService {
    
    // Lấy danh sách thông báo của User (Dùng cho App Flutter hiển thị)
    async getUserNotifications(userId, page = 1, limit = 20) {
        const skip = (page - 1) * limit;
        return await notificationRepository.getNotificationsByUser(userId, skip, limit);
    }

    // Đánh dấu 1 thông báo là đã đọc (Tắt chấm đỏ)
    async markAsRead(notificationId, userId) {
        const notification = await notificationRepository.markAsRead(notificationId, userId);
        if (!notification) {
            const error = new Error('Notification not found or unauthorized');
            error.statusCode = 404;
            throw error;
        }
        return notification;
    }

    // Đánh dấu TẤT CẢ là đã đọc
    async markAllAsRead(userId) {
        await notificationRepository.markAllAsRead(userId);
        return { message: 'All notifications marked as read' };
    }

    // hàm nội bộ: các service khác sẽ gọi hàm này khi có sự kiện cần tạo thông báo mới
    async createAndSendNotification(data, io) {
        // Lưu vào Database
        const notification = await notificationRepository.createNotification(data);
        
        // Nếu có Socket.io, phát loa ngay lập tức cho người nhận
        if (io && data.recipientId) {
            // Phát vào cái phòng mang tên ID của người nhận
            io.to(data.recipientId.toString()).emit('receive_notification', notification);
        }
        
        return notification;
    }
}

module.exports = new NotificationService();