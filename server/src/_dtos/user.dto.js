
// detail profile information sent to client
class UserResponse {
    constructor(user) {
        this.id = user._id || user.id; 
        this.fullName = user.fullName;
        this.displayName = user.displayName || user.fullName;
        this.email = user.email;
        this.bio = user.bio || '';
        this.gallery = user.gallery || [];
        this.sports = user.sports || [];
        this.location = user.location;
        this.avatar = user.avatar || '';
    }
}

// list search nearby users (xem xét extends)
class NearbyUserDTO {
    constructor(user) {
        this.id = user._id || user.id;
        this.displayName = user.displayName || user.fullName;
        this.avatar = user.avatar || '';
        this.sports = user.sports || [];
        this.bio = user.bio || '';
        // Khoảng cách làm tròn 1 số thập phân
        // Nếu user.dist.calculated tồn tại thì lấy, không thì 0
        this.distance = user.dist ? parseFloat((user.dist.calculated / 1000).toFixed(1)) : 0; // Đổi m sang km
    }
}

module.exports = { UserResponse, NearbyUserDTO };