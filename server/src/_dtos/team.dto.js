class TeamResponseDTO{
    constructor(team){
        this.id = team._id || team.id;
        this.name = team.name;
        this.description = team.description || '';
        this.sport = team.sport;
        this.sportLevel = team.sportLevel || 'Beginner';
        this.avatar = team.avatar || '';
        this.coverImage = team.coverImage || '';
        this.fund = team.fund || 0; // Quỹ đội
        this.captainId = team.captainId;
        this.location = team.location; // Tọa độ hoạt động
        this.createdAt = team.createdAt;

        // lọc thông tin nhạy cảm
        if (team.members && Array.isArray(team.members)) {
            this.members = team.members.map(memberObj => {
                // check xem user có được móc sang bảng user chưa
                const userObj = memberObj.userId;

                // Nếu không có userObj thì trả về mặc định để không bị sập app
                if (!userObj) {
                    return { 
                        user: { id: 'Unknown', displayName: 'Unknown', avatar: '' }, 
                        role: memberObj.role,
                        joinedAt: memberObj.joinedAt
                    };
                }

                const memberId = (userObj._id || userObj).toString();
                const captainIdStr = team.captainId ? team.captainId.toString() : '';

                // Nếu ID trùng với Đội trưởng, đổi role thành CAPTAIN
                let displayRole = memberObj.role;
                if (memberId === captainIdStr) {
                    displayRole = 'CAPTAIN';
                }
                
                return {
                    user: {
                        id: userObj._id || userObj,
                        displayName: userObj.displayName || userObj.fullName || 'Unknown',
                        avatar: userObj.avatar || ''
                    },
                    role: displayRole,
                    joinedAt: memberObj.joinedAt
                };
            });
        }else {
            this.members = [];
        }
    }
}

module.exports = { TeamResponseDTO };