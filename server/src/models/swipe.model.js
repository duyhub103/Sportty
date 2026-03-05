const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const swipeSchema = new Schema({
    swiperId: { type: Schema.Types.ObjectId, ref: 'User', required: true },   // Người quẹt (User A)
    receiverId: { type: Schema.Types.ObjectId, ref: 'User', required: true }, // Người bị quẹt (User B)
    type: { type: String, enum: ['LIKE', 'DISLIKE'], required: true }         // Hành động
}, { timestamps: true });

// Đảm bảo 1 người chỉ quẹt 1 người khác ĐÚNG 1 LẦN (tránh spam API)
swipeSchema.index({ swiperId: 1, receiverId: 1 }, { unique: true });

module.exports = mongoose.model('Swipe', swipeSchema);