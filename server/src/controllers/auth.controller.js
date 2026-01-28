const authService = require('../services/auth.service');
const asyncHandler = require('../utils/asyncHandler');
const { UserResponse } = require('../_dtos/user.dto');

class AuthController {
  // POST /register
  register = asyncHandler(async (req, res) => {
    // validate req.body
    const { fullName, email, password } = req.body;
    
    const newUser = await authService.register({ fullName, email, password });

    const userDTO = new UserResponse(newUser);
    
    res.success(userDTO, 'User registered successfully', 201);
  });

  // POST /login
  login = asyncHandler(async (req, res) => {
    const { email, password } = req.body;
    
    const { token, user } = await authService.login({ email, password });

    const userDTO = new UserResponse(user);
    
    res.success({ token, user: userDTO }, 'Login successfully');
  });
}

module.exports = new AuthController();