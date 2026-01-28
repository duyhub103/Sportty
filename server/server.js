require('dotenv').config();
const http = require('http');
const app = require('./src/app');
const connectDB = require('./src/configs/db');
const { Server } = require('socket.io');
const { Socket } = require('engine.io');

// kết nối db
connectDB();

const PORT = process.env.PORT || 3000;
const server = http.createServer(app);

// cấu hình socket.io
const io = new Server(server, {
    cors: {
        origin: '*' // cho phép flutter kết nối
        //methods: ['GET', 'POST']
    }
});

io.on('connection', (socket) => {
    console.log('User connect socket', socket.id);

    socket.on('disconnect', () => {
        console.log('User disconnected');
    });
});

server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});