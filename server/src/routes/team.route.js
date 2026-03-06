const express = require('express');
const router = express.Router();
const teamController = require('../controllers/team.controller');
const { protect } = require('../middlewares/auth.middleware');

const activityController = require('../controllers/activity.controller');

// Bắt buộc phải đăng nhập
router.use(protect);

router.post('/', teamController.createTeam);                // Tạo đội
router.get('/', teamController.getTeams);                   // Tìm đội
router.get('/:id', teamController.getTeamById);             // Xem chi tiết đội
router.post('/:id/join', teamController.requestToJoin);     // Xin gia nhập
router.put('/:id/requests', teamController.handleJoinRequest); // Duyệt yêu cầu
router.get('/:id/messages', teamController.getTeamMessages); // Lấy tin nhắn của đội

// Các route liên quan đến Bảng tin (Activities), đặt route này trong team.route vì nó có liên quan đến teamId
router.post('/:id/activities', activityController.createActivity); // :id ở đây chính là teamId
router.get('/:id/activities', activityController.getActivities);

module.exports = router;