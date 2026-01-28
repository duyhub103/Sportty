// src/middlewares/auth.middleware.js
const jwt = require('jsonwebtoken');
const asyncHandler = require('../utils/asyncHandler');
const userRepository = require('../repositories/user.repository');

const protect = asyncHandler(async (req, res, next) => {
  let token;

  // Kiểm tra header Authorization có dạng "Bearer <token>"
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      // Lấy token ra (bỏ Bearer)
      token = req.headers.authorization.split(' ')[1];

      // Giải mã token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      //check user
      req.user = await userRepository.findById(decoded.id);

      if (!req.user) {
         const error = new Error('User not found');
         error.statusCode = 401;
         throw error;
      }

      next();
    } catch (error) {
      console.error(error);
      const err = new Error('Not authorized, token failed');
      err.statusCode = 401;
      throw err;
    }
  }

  if (!token) {
    const error = new Error('Not authorized, no token');
    error.statusCode = 401;
    throw error;
  }
});

module.exports = { protect };