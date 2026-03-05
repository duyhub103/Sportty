const messageRepository = require('../repositories/message.repository');
const Match = require('../models/Match'); // Gọi trực tiếp Model để update

module.exports = (io) => {
    // Lắng nghe sự kiện có 1 User (Client) kết nối tới Server
    io.on('connection', (socket) => {
        console.log('🟢 Một user vừa kết nối socket, ID:', socket.id);

        // 1. Lắng nghe khi User MỞ màn hình chat (Gia nhập phòng)
        socket.on('join_chat', (matchId) => {
            socket.join(matchId);
            console.log(`Báo cáo: Socket ${socket.id} đã vào phòng Match: ${matchId}`);
        });

        // 2. Lắng nghe khi User BẤM GỬI tin nhắn
        socket.on('send_message', async (data) => {
            /* Data từ Flutter gửi lên sẽ có dạng: 
               { matchId: "...", senderId: "...", content: "Xin chào!" } 
            */
            try {
                // Lưu tin nhắn mới vào Database (bảng Message)
                const newMessage = await messageRepository.createMessage({
                    conversationId: data.matchId,
                    senderId: data.senderId,
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

        // Khi User thoát app
        socket.on('disconnect', () => {
            console.log('🔴 Một user đã ngắt kết nối:', socket.id);
        });
    });
};