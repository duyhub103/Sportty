const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const postSchema = new Schema({
    author: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    type: {
        type: String,
        enum: ['DISCUSSION', 'MATCH'],
        default: 'DISCUSSION'
    },
    content: { type: String, required: true },
    image: { type: String, default: '' },
    sport: { type: String },       
    location: { type: String },   
    time: { type: Date },          

    likes: [{ type: Schema.Types.ObjectId, ref: 'User' }],

    comments: [{
        user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
        text: { type: String, required: true },
        createdAt: { type: Date, default: Date.now }
    }]

}, { timestamps: true });

// Index để query lấy bài mới nhất nhanh hơn
postSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Post', postSchema);
