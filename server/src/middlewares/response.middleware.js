const responseMiddleware = (req, res, next) => {
    res.success = (data, message = 'Success', statusCode = 200) => {
        return res.status(statusCode).json({
            success: true,
            message,
            data,
        });
    };

    res.error = (message, statusCode = 400, errors = null) => {
        // controller trả về lỗi
        const error =  new Error(message);
        error.statusCode = statusCode;
        error.errors = errors;
        throw error;
    };

    next();
};

module.exports = responseMiddleware;
