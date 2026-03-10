const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');
const { protect } = require('../middlewares/auth.middleware');

// bắt buộc phải đăng nhập
router.use(protect); 

router.get('/', notificationController.getNotifications);
// Đặt /read-all lên trên /:id/read để Express không hiểu nhầm chữ 'read-all' là 1 cái ID
router.put('/read-all', notificationController.markAllAsRead);
router.put('/:id/read', notificationController.markAsRead);

module.exports = router;