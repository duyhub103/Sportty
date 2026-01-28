const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const messageSchema = new Schema({
    conversationId: { type: Schema.Types.ObjectId, required: true }, // MatchID hoặc TeamID
    senderId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    type: { type: String, enum: ['PRIVATE', 'GROUP'], default: 'PRIVATE' },
    content: { type: String, required: true }, // Text hoặc URL ảnh
    contentType: { type: String, enum: ['text', 'image', 'location'], default: 'text' },
    isRead: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model('Message', messageSchema);