const matchService = require('../services/match.service');
const messageService = require('../services/message.service');
const asyncHandler = require('../utils/asyncHandler');
const { MatchResponseDTO, MessageResponseDTO } = require('../_dtos/chat.dto');

class ChatController {

    // GET /api/matches
    getMatches = asyncHandler(async (req, res) => {
        const userId = req.user.id;
        const matches = await matchService.getMyMatches(userId);
        
        // Dùng DTO map lại dữ liệu, truyền thêm userId để xác định partner
        const result = matches.map(m => new MatchResponseDTO(m, userId));
        
        res.success(result, 'Get matches successfully');
    });

    // GET /api/messages/:matchId?page=1&limit=20
    getMessages = asyncHandler(async (req, res) => {
        const userId = req.user.id;
        const { matchId } = req.params;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;

        const messages = await messageService.getMatchMessages(userId, matchId, page, limit);
        
        const result = messages.map(msg => new MessageResponseDTO(msg));
        
        res.success(result, 'Get messages successfully');
    });

    // POST /api/messages
    sendMessage = asyncHandler(async (req, res) => {
        const senderId = req.user.id;
        const { conversationId, type, content, contentType } = req.body;
        const io = req.app.get('io'); // Lấy loa Socket

        if (!conversationId || !content) {
            const error = new Error('conversationId and content are required');
            error.statusCode = 400;
            throw error;
        }

        const message = await messageService.sendMessage(senderId, conversationId, type, content, contentType || 'text', io);
        
        // Trả về DTO
        res.success(new MessageResponseDTO(message), 'Message sent successfully', 201);
    });
}

module.exports = new ChatController();