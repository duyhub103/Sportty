const messageRepository = require('../repositories/message.repository');
const Match = require('../models/Match'); // Gọi trực tiếp Model để update
const Team = require('../models/Team'); // gọi model để update lastMessage

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

        // Lắng nghe khi User BẤM GỬI tin nhắn
        socket.on('send_message', async (data) => {
            /* Data từ Flutter gửi lên sẽ có dạng: 
               { matchId: "...", senderId: "...", content: "Xin chào!" } 
            */
            try {
                // Lưu tin nhắn mới vào Database (bảng Message)
                const newMessage = await messageRepository.createMessage({
                    conversationId: data.matchId,
                    senderId: data.senderId,
                    type: 'PRIVATE', // đánh dấu là tin nhắn riêng
                    content: data.content,
                    contentType: 'text' // Tạm thời hardcode là text
                });

                // Cập nhật lại cái preview "lastMessage" ở bảng Match
                await Match.findByIdAndUpdate(data.matchId, {
                    lastMessage: data.content,
                    lastMessageTime: new Date()
                });

                // BẮN TIN NHẮN CHO NGƯỜI KIA (REAL-TIME)
                // io.to(phòng).emit('tên_sự_kiện', dữ_liệu)
                // gửi tin nhắn đến mọi người đang mở cái phòng chat
                io.to(data.matchId).emit('receive_message', newMessage);

            } catch (error) {
                console.error('🔴 Lỗi khi lưu tin nhắn Socket:', error);
            }
        });

        // chat nhóm
        // Khi User mở màn hình Chat Nhóm
        socket.on('join_team_chat', (teamId) => {
            socket.join(teamId); // Socket.io sẽ tự gom mọi người chung teamId vào 1 phòng
            console.log(`Báo cáo: Socket ${socket.id} đã vào phòng Team: ${teamId}`);
        });

        // Khi User gửi 1 tin nhắn vào Nhóm
        socket.on('send_team_message', async (data) => {
            /* Data Flutter gửi lên: { teamId: "...", senderId: "...", content: "Đá sân nào anh em?" } */
            try {
                // Lưu tin nhắn vào db
                const newMessage = await messageRepository.createMessage({
                    conversationId: data.teamId,
                    senderId: data.senderId,
                    type: 'GROUP', // Đánh dấu tin nhắn nhóm
                    content: data.content,
                    contentType: 'text'
                });

                // CẬP NHẬT preview "lastMessage" ở bảng Team
                await Team.findByIdAndUpdate(data.teamId, { 
                    lastMessage: data.content, 
                    lastMessageTime: new Date() 
                });

                // Móc thông tin người gửi (Populate) trước khi phát loa
                // Vì chat nhóm cần hiện Avatar/Tên người gửi lên cho mọi người xem
                const populatedMessage = await newMessage.populate('senderId', 'fullName displayName avatar');

                // Phát loa (Broadcast) tin nhắn này cho các user trong phòng (teamId)
                io.to(data.teamId).emit('receive_team_message', populatedMessage);

            } catch (error) {
                console.error('🔴 Lỗi khi lưu tin nhắn Team:', error);
            }
        });

        socket.on('join_notification', (userId) => {
            socket.join(userId); // User vào phòng mang tên ID của chính mình
            console.log(`🔔 Socket ${socket.id} đã bật chuông cho User: ${userId}`);
        });

        // Khi User thoát app
        socket.on('disconnect', () => {
            console.log('🔴 Một user đã ngắt kết nối:', socket.id);
        });
    });
};