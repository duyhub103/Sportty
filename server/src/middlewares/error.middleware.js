const errorMiddleware = (err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  console.error(`[Error] ${req.method} ${req.url}:`, err); // Log lỗi ra console server

  res.status(statusCode).json({
    success: false,
    message: message,
    errors: err.errors || null, // Chi tiết lỗi validation
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });
};

module.exports = errorMiddleware;