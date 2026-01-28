const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const teamActivitySchema = new Schema({
    teamId: { type: Schema.Types.ObjectId, ref: 'Team', required: true },
    type: { type: String, enum: ['NOTICE', 'VOTE', 'MATCH_SCHEDULE'], required: true },
    content: { type: String, required: true },
    createdBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    // Dùng cho chức năng Vote
    voteOptions: [{
        label: { type: String }, // Ví dụ: "Thứ 7", "Chủ nhật"
        voters: [{ type: Schema.Types.ObjectId, ref: 'User' }]
    }]
}, { timestamps: true });

module.exports = mongoose.model('TeamActivity', teamActivitySchema);