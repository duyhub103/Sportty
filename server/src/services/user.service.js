// src/services/user.service.js
const userRepository = require('../repositories/user.repository');

class UserService {
  // lấy profile
  async getProfile(userId) {
        const user = await userRepository.findById(userId);
        if (!user) throw new Error('User not found');
        return user;
    }

    // Cập nhật Profile
    async updateProfile(userId, data) {
        const updateData = { ...data };

        // Nếu có gửi tọa độ lên thì Format lại thành GeoJSON chuẩn MongoDB (long trước lat sau)
        if (data.long && data.lat) {
            updateData.location = {
                type: 'Point',
                coordinates: [parseFloat(data.long), parseFloat(data.lat)]
            };
            // Xóa trường long/lat thừa để không lưu rác vào DB
            delete updateData.long;
            delete updateData.lat;
        }

        const updatedUser = await userRepository.update(userId, updateData);
        if (!updatedUser) throw new Error('Update failed');
        
        return updatedUser;
    }

    // Tìm quanh đây
    async getNearbyUsers(currentUserId, { long, lat, distance = 10, sport }) {
        // Convert khoảng cách km sang mét (Default 10km)
        const maxDistanceMeters = parseFloat(distance) * 1000;
        const longitude = parseFloat(long);
        const latitude = parseFloat(lat);

        // lấy danh sách
        const users = await userRepository.findNearby(longitude, latitude, maxDistanceMeters, sport);

        // bỏ bản thân khỏi list
        // users trả về từ aggregate là array object thuần, id là objectId
        return users.filter(u => u._id.toString() !== currentUserId);
    }

}


module.exports = new UserService();