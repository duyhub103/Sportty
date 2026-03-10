const notificationService = require('../services/notification.service');
const asyncHandler = require('../utils/asyncHandler');
const { NotificationResponseDTO } = require('../_dtos/notification.dto');

class NotificationController {
    
    // GET /api/notifications
    getNotifications = asyncHandler(async (req, res) => {
        const userId = req.user.id;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;

        const notifications = await notificationService.getUserNotifications(userId, page, limit);
        
        // Bọc dữ liệu qua DTO để lọc thông tin nhạy cảm của người gửi
        const result = notifications.map(notif => new NotificationResponseDTO(notif));
        
        res.success(result, 'Get notifications successfully');
    });

    // PUT /api/notifications/:id/read
    markAsRead = asyncHandler(async (req, res) => {
        const userId = req.user.id;
        const notificationId = req.params.id;

        const notification = await notificationService.markAsRead(notificationId, userId);
        
        res.success(new NotificationResponseDTO(notification), 'Notification marked as read');
    });

    // PUT /api/notifications/read-all
    markAllAsRead = asyncHandler(async (req, res) => {
        const userId = req.user.id;
        const result = await notificationService.markAllAsRead(userId);
        res.success(null, result.message);
    });
}

module.exports = new NotificationController();