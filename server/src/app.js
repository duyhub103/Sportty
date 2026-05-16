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
const postRoutes = require('./routes/post.route');

const app = express();

app.use(helmet()); 
app.use(cors()); 
app.use(morgan('dev')); 


// parser
app.use(express.json()); 
app.use(express.urlencoded({ extended: true })); 


// Response Helper
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
app.use('/api/posts', postRoutes);

// Error Handling
app.use(errorMiddleware);


module.exports = app;