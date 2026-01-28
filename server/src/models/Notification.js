const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const notificationSchema = new Schema({
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true }, // Người nhận
    title: { type: String, required: true },
    body: { type: String, required: true },
    type: { type: String, enum: ['MATCH', 'TEAM_INVITE', 'SYSTEM'], default: 'SYSTEM' },
    isRead: { type: Boolean, default: false },
    data: { type: Object } // Lưu ID để click vào nhảy trang
}, { timestamps: true });

module.exports = mongoose.model('Notification', notificationSchema);