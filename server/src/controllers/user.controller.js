// src/controllers/user.controller.js
const userService = require('../services/user.service');
const asyncHandler = require('../utils/asyncHandler');
const { UserResponse } = require('../_dtos/user.dto');

class UserController {

  getProfile = asyncHandler(async (req, res) => {
    // req.user.id lấy từ authMiddleware
    const userId = req.user.id; 
    
    const user = await userService.getProfile(userId);
    
    // DTO lọc data
    const userDTO = new UserResponse(user);
    
    res.success(userDTO, 'Get profile successfully');
  });
}

module.exports = new UserController();