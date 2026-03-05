require('dotenv').config();
const http = require('http');
const app = require('./src/app');
const connectDB = require('./src/configs/db');
const { Server } = require('socket.io');
const setupSocket = require('./src/configs/socket');

// kết nối db
connectDB();

const PORT = process.env.PORT || 3000;
const server = http.createServer(app);

// Khởi tạo Socket.io và gắn vào HTTP server
const io = new Server(server, {
    cors: {
        origin: '*', // cho phép flutter kết nối tới
        methods: ['GET', 'POST']
    }
});

// Khởi động logic Socket
setupSocket(io);

server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`⚡ Socket.io đã sẵn sàng`);
});