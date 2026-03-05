const express = require('express');
const router = express.Router();
const activityController = require('../controllers/activity.controller');
const { protect } = require('../middlewares/auth.middleware');

router.use(protect);

router.post('/:activityId/interact', activityController.interactActivity);

module.exports = router;