class UserResponse {
    constructor(user) {
        this.id = user._id || user.id; 
    this.fullName = user.fullName;
    this.email = user.email;
    this.avatar = user.avatar || '';
    }
}
module.exports = { UserResponse };