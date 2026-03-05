class ActivityResponseDTO {
    constructor(activity) {
        this.id = activity._id || activity.id;
        this.teamId = activity.teamId;
        this.type = activity.type;
        this.content = activity.content;
        this.createdAt = activity.createdAt;

        // Xử lý thông tin người đăng bài
        const creator = activity.createdBy;
        if (creator) {
            this.createdBy = {
                id: creator._id || creator,
                displayName: creator.displayName || creator.fullName || 'Unknown',
                avatar: creator.avatar || ''
            };
        } else {
            this.createdBy = null;
        }

        // Xử lý các lựa chọn Vote / Điểm danh
        if (activity.voteOptions && Array.isArray(activity.voteOptions)) {
            this.voteOptions = activity.voteOptions.map(opt => {
                return {
                    id: opt._id, // Mongoose tự sinh _id cho mỗi phần tử trong mảng con
                    label: opt.label,
                    voteCount: (opt.voters || []).length, // Tính tổng số lượt Vote nhanh
                    voters: (opt.voters || []).map(voter => {
                        // Nếu đã được populate thì bóc tách lấy tên/avatar
                        if (typeof voter === 'object' && voter._id) {
                            return {
                                id: voter._id,
                                displayName: voter.displayName || voter.fullName || 'Unknown',
                                avatar: voter.avatar || ''
                            };
                        }
                        // Nếu chưa populate thì trả về ID thô
                        return { id: voter };
                    })
                };
            });
        } else {
            this.voteOptions = [];
        }
    }
}

module.exports = { ActivityResponseDTO };