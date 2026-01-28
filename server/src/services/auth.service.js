const userRepository = require('../repositories/user.repository');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

class AuthService {
  async register({ fullName, email, password }) {
    // Check user tồn tại
    const existingUser = await userRepository.findByEmail(email);
    if (existingUser) {
      // Ném lỗi, controller bắt được qua asyncHandler
      const error = new Error('Email already exists');
      error.statusCode = 409;
      throw error;
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Gọi repo tạo user
    const newUser = await userRepository.create({
      fullName,
      email,
      password: hashedPassword
    });

    return newUser;
  }

  async login({ email, password }) {
    // Tìm user
    const user = await userRepository.findByEmail(email);
    if (!user) {
      const error = new Error('Incorrect email or password');
      error.statusCode = 401;
      throw error;
    }

    // Check pass
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
        const error = new Error('Incorrect email or password');
        error.statusCode = 401;
        throw error;
    }

    // Tạo token
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1d' });

    return { token, user};
  }
}

module.exports = new AuthService();