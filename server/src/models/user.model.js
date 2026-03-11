const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const userSchema = new Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    fullName: { type: String, required: true },
    displayName: {type: String },
    bio: { type: String, default: '' },
    avatar: { type: String, default: '' },
    gallery: [{ type: String }], // Mảng URL hình ảnh
    
    gender: { type: String, enum: ['Male', 'Female', 'Other'] },
    yob: { type: Number }, // Năm sinh
    // geoJSON Point
    location: {
        type: { type: String, default: 'Point' },
        coordinates: { type: [Number], index: '2dsphere', default: [0, 0] } // [Long, Lat]
    },

    sportLevel: { type: String, enum: ['Beginner', 'Intermediate', 'Pro'], default: 'Beginner' },
    sports: [{ type: String }], // Ví dụ: ["Football", "Badminton"]
    fcmToken: { type: String } // Token để bắn thông báo
}, { timestamps: true });

userSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('User', userSchema);