const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const matchSchema = new Schema({
    users: [{ type: Schema.Types.ObjectId, ref: 'User' }], // luôn có 2 user
    lastMessage: { type: String, default: '' },
    lastMessageTime: { type: Date, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('Match', matchSchema);