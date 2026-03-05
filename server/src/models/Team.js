const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const teamSchema = new Schema({
    name: { type: String, required: true },
    pendingRequests: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    captainId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    sport: { type: String, required: true },
    description: { type: String },
    avatar: { type: String, default: '' },
    // CẬP NHẬT: Thêm quản lý quỹ
    fund: { type: Number, default: 0 }, 
    members: [{
        userId: { type: Schema.Types.ObjectId, ref: 'User' },
        role: { type: String, enum: ['MEMBER', 'VICE_CAPTAIN'], default: 'MEMBER' },
        joinedAt: { type: Date, default: Date.now }
    }]
}, { timestamps: true });

module.exports = mongoose.model('Team', teamSchema);