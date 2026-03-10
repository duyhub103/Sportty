// cấu hình express
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');


// import middlewares
const responseMiddleware = require('./middlewares/response.middleware');
const errorMiddleware = require('./middlewares/error.middleware');

// import routes
const authRoutes = require('./routes/auth.route');
const userRoutes = require('./routes/user.route');
const swipeRoutes = require('./routes/swipe.route');
const chatRoutes = require('./routes/chat.route');
const teamRoutes = require('./routes/team.route');
const activityRoutes = require('./routes/activity.route');
const notificationRoutes = require('./routes/notification.route');

const app = express();

app.use(helmet()); // bảo mật các header
app.use(cors()); // cho phép truy cập api từ mọi nguồn 
app.use(morgan('dev')); // log các request


// parser
app.use(express.json()); // đọc json từ body
app.use(express.urlencoded({ extended: true })); // đọc dữ liệu từ form data


// Response Helper (trước Routes để controller dùng res.success)
app.use(responseMiddleware);

// Routes
app.get('/', (req, res) => res.send('Sportty API is running...'));
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/swipes', swipeRoutes);
app.use('/api', chatRoutes); // URL sẽ tự động thành /api/matches và /api/messages/:matchId
app.use('/api/teams', teamRoutes);
app.use('/api/activities', activityRoutes);
app.use('/api/notifications', notificationRoutes);

// Error Handling (cuối cùng)
app.use(errorMiddleware);

// import các route

module.exports = app;