const User = require('../models/user.model');

class UserRepository {
  async create(userData) {
    return await User.create(userData);
  }

  async findByEmail(email) {
    return await User.findOne({ email });
  }

  async findById(id) {
    return await User.findById(id).select('-password'); // Tránh trả về password
  }

  async update(id, updateData) {
    return await User.findByIdAndUpdate(id, updateData, { new: true }).select('-password');
  }

  // Tìm người xung quanh
    // Dùng Aggregation để tính khoảng cách chính xác
    async findNearby(long, lat, maxDistanceInMeters, sportFilter) {
        const pipeline = [
            {
              // tìm theo vị trí
                $geoNear: {
                    near: { type: "Point", coordinates: [long, lat] },
                    distanceField: "dist.calculated", // chứa khoảng cách (mét) trả về
                    maxDistance: maxDistanceInMeters, // bán kính tìm
                    spherical: true,
                    key: "location" // field tọa độ trong db
                }
            }
        ];

        // lọc theo môn thể thao
        if (sportFilter) {
            pipeline.push({
                $match: { sports: sportFilter }
            });
        }

        // Chọn các trường cần thiết trả về
        pipeline.push({ $project: { password: 0, fcmToken: 0, email: 0 } });

        return await User.aggregate(pipeline);
    }
}

module.exports = new UserRepository();