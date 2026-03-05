const activityService = require('../services/activity.service');
const asyncHandler = require('../utils/asyncHandler');
const { ActivityResponseDTO } = require('../_dtos/activity.dto');

class ActivityController {
    
    // POST /api/teams/:teamId/activities
    createActivity = asyncHandler(async (req, res) => {
        const userId = req.user.id;
        const teamId = req.params.id;
        
        const activity = await activityService.createActivity(teamId, userId, req.body);
        
        res.success(new ActivityResponseDTO(activity), 'Activity created successfully', 201);
    });

    // GET /api/teams/:teamId/activities
    getActivities = asyncHandler(async (req, res) => {
        const teamId  = req.params.id;
        
        const activities = await activityService.getActivities(teamId);
        const result = activities.map(act => new ActivityResponseDTO(act));
        
        res.success(result, 'Get activities successfully');
    });

    // POST /api/activities/:activityId/interact
    interactActivity = asyncHandler(async (req, res) => {
        const userId = req.user.id;
        const { activityId } = req.params;
        const { optionId } = req.body; // Gửi lên từ Client

        if (!optionId) {
             const error = new Error('optionId is required');
             error.statusCode = 400;
             throw error;
        }

        const result = await activityService.interactActivity(activityId, userId, optionId);
        res.success(null, result.message);
    });
}

module.exports = new ActivityController();