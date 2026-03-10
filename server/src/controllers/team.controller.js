const teamService = require('../services/team.service');
const asyncHandler = require('../utils/asyncHandler');
const { TeamResponseDTO } = require('../_dtos/team.dto');
const messageService = require('../services/message.service');
const { MessageResponseDTO } = require('../_dtos/chat.dto');

class TeamController {
    // POST /api/teams (Tạo đội mới)
    createTeam = asyncHandler(async (req, res) => {
        const userId = req.user.id; // Lấy ID của người tạo từ Token
        
        const team = await teamService.createTeam(userId, req.body);
        
        // Trả về data đã qua DTO
        res.success(new TeamResponseDTO(team), 'Team created successfully', 201);
    });

    // GET /api/teams (Lấy danh sách đội có bộ lọc)
    getTeams = asyncHandler(async (req, res) => {
        const filter = {
            sport: req.query.sport,
            keyword: req.query.keyword
        };
        
        const teams = await teamService.getTeams(filter);
        const result = teams.map(t => new TeamResponseDTO(t));
        
        res.success(result, 'Get teams successfully');
    });

    // GET /api/teams/:id (Xem chi tiết 1 đội)
    getTeamById = asyncHandler(async (req, res) => {
        const team = await teamService.getTeamById(req.params.id);
        res.success(new TeamResponseDTO(team), 'Get team details successfully');
    });

    // POST /api/teams/:id/join (yêu cầu tham gia đội)
    requestToJoin = asyncHandler(async (req, res) => {
        const userId = req.user.id; // Người đang bấm nút "Xin vào"
        
        const result = await teamService.requestToJoin(req.params.id, userId);
        
        res.success(null, result.message);
    });

    // PUT /api/teams/:id/requests (Đội trưởng duyệt/từ chối)
    handleJoinRequest = asyncHandler(async (req, res) => {
        const actionUserId = req.user.id; // ID của Đội trưởng (từ Token)
        const teamId = req.params.id;
        const { targetUserId, action } = req.body; // Bắn lên từ App Flutter
        
        if (!targetUserId || !action) {
            const error = new Error('targetUserId and action (APPROVE/REJECT) are required');
            error.statusCode = 400;
            throw error;
        }

        const result = await teamService.handleJoinRequest(teamId, actionUserId, targetUserId, action.toUpperCase());
        
        res.success(null, result.message);
    });

    // GET /api/teams/:id/messages?page=1&limit=20 (Lấy tin nhắn của đội)
    getTeamMessages = asyncHandler(async (req, res) => {
        const teamId = req.params.id;
        const userId = req.user.id;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;

        const messages = await messageService.getTeamMessages(teamId, userId, page, limit);
        
        // Bọc dữ liệu qua DTO để format lại giao diện
        const result = messages.map(msg => new MessageResponseDTO(msg));
        
        res.success(result, 'Get team messages successfully');
    });

    // PUT /api/teams/:id/fund (Cập nhật quỹ đội)
    updateTeamFund = asyncHandler(async (req, res) => {
        const actionUserId = req.user.id;
        const teamId = req.params.id;
        const { amount } = req.body; // Gửi lên từ Client (VD: 500000 hoặc -150000)

        const updatedTeam = await teamService.updateTeamFund(teamId, actionUserId, amount);
        
        res.success(new TeamResponseDTO(updatedTeam), 'Team fund updated successfully');

        // có thể chỉ trả về id và số tiền
        // res.success({ 
        // teamId: updatedTeam._id, 
        // currentFund: updatedTeam.fund 
        // }, 'Team fund updated successfully');
    });
}

module.exports = new TeamController();