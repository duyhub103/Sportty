// src/controllers/user.controller.js
const userService = require('../services/user.service');
const asyncHandler = require('../utils/asyncHandler');
const { UserResponse, NearbyUserDTO } = require('../_dtos/user.dto');

class UserController {

  // GET /api/users/profile
  getProfile = asyncHandler(async (req, res) => {
    // req.user.id lấy từ authMiddleware
    const userId = req.user.id; 
    
    const user = await userService.getProfile(userId);
    
    // DTO lọc data
    const userDTO = new UserResponse(user);
    
    res.success(userDTO, 'Get profile successfully');
  });

  // PUT /api/users/profile
  updateProfile = asyncHandler(async (req, res) => {
        const userId = req.user.id;
        // req.body chứa: { displayName, bio, sports, gallery, long, lat ... }

        const updateData = { ...req.body }; // tạo object chứa data cập nhật từ body

        // check có file upload
        if (req.files) {
            // Nếu có up avatar thì lấy URL do Cloudinary trả về
            if (req.files['avatar'] && req.files['avatar'].length > 0) {
                updateData.avatar = req.files['avatar'][0].path;
            }
            
            // Nếu có up gallery thì tạo mảng chứa các URL
            if (req.files['gallery'] && req.files['gallery'].length > 0) {
                updateData.gallery = req.files['gallery'].map(file => file.path);
            }
        }

        
        const updatedUser = await userService.updateProfile(userId, updateData);
        
        const userDTO = new UserResponse(updatedUser);
        res.success(userDTO, 'Profile updated successfully');
    });

    // GET /api/users/nearby (Tìm quanh đây)
    getNearbyUsers = asyncHandler(async (req, res) => {
        const userId = req.user.id;
        const { long, lat, distance, sport } = req.query;

        // Validate bắt buộc phải có tọa độ
        if (!long || !lat) {
            res.error('Longitude and Latitude are required', 400);
            return;
        }

        const users = await userService.getNearbyUsers(userId, { long, lat, distance, sport });

        // Map sang DTO rút gọn
        const nearbyUsersDTO = users.map(user => new NearbyUserDTO(user));

        res.success(nearbyUsersDTO, 'Found nearby users');
    });
  
}

module.exports = new UserController();