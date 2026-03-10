class NotificationResponseDTO {
    constructor(notification) {
        this.id = notification._id || notification.id;
        this.type = notification.type;
        this.content = notification.content;
        this.relatedId = notification.relatedId;
        this.isRead = notification.isRead;
        this.createdAt = notification.createdAt;

        // Xử lý thông tin người tạo ra thông báo (Nếu có)
        if (notification.senderId && typeof notification.senderId === 'object') {
            this.sender = {
                id: notification.senderId._id,
                displayName: notification.senderId.displayName || notification.senderId.fullName || 'Hệ thống',
                avatar: notification.senderId.avatar || ''
            };
        } else {
            this.sender = null;
        }
    }
}

module.exports = { NotificationResponseDTO };