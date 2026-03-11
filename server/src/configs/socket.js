const messageService = require('../services/message.service');

module.exports = (io) => {
    // Lắng nghe sự kiện có 1 User (Client) kết nối tới Server
    io.on('connection', (socket) => {
        console.log('🟢 Một user vừa kết nối socket, ID:', socket.id);

        // Lắng nghe khi User MỞ màn hình chat (Gia nhập phòng)
        // chat 1-1
        socket.on('join_chat', (matchId) => {
            socket.join(matchId);
            console.log(`Báo cáo: Socket ${socket.id} đã vào phòng Match: ${matchId}`);
        });
    
        socket.on('join_notification', (userId) => {
            socket.join(userId); // User vào phòng mang tên ID của chính mình
            console.log(`🔔 Socket ${socket.id} đã bật chuông cho User: ${userId}`);
        });

        socket.on('send_message', async (data) => {
            try {
                // Service xử lý: Lưu DB, Cập nhật Match, và Phát loa (io)
                await messageService.sendMessage(data.senderId, data.matchId, 'PRIVATE', data.content, 'text', io);
            } catch (error) {
                console.error('🔴 Lỗi khi lưu tin nhắn 1-1:', error);
            }
        });

        // Lắng nghe khi User gửi 1 tin nhắn vào Nhóm
        socket.on('send_team_message', async (data) => {
            try {
                // Service xử lý: Lưu DB, Cập nhật Team, Populate và Phát loa
                await messageService.sendMessage(data.senderId, data.teamId, 'GROUP', data.content, 'text', io);
            } catch (error) {
                console.error('🔴 Lỗi khi lưu tin nhắn Team:', error);
            }
        });

        // Khi User thoát app
        socket.on('disconnect', () => {
            console.log('🔴 Một user đã ngắt kết nối:', socket.id);
        });
    });
};