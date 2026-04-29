import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../providers/team_provider.dart';
import '../../../../data/models/team_model.dart';

class TeamMembersTab extends StatelessWidget {
  final TeamDetailModel team;
  final bool isLeader;
  final String currentUserId;

  const TeamMembersTab({
    super.key,
    required this.team,
    required this.isLeader,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: team.members.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final member = team.members[index];
        final isCurrentUser = member.id == currentUserId;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green[50],
            backgroundImage: member.avatar != null ? NetworkImage(member.avatar!) : null,
            child: member.avatar == null
                ? const Icon(Icons.person, color: Colors.green)
                : null,
          ),
          title: Row(
            children: [
              Text(member.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              if (isCurrentUser) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Bạn',
                      style: TextStyle(fontSize: 10, color: Colors.blue)),
                ),
              ]
            ],
          ),
          subtitle: Text(
            _roleLabel(member.role),
            style: TextStyle(
                color: _roleColor(member.role), fontWeight: FontWeight.w500),
          ),
          trailing: _buildRoleIcon(member.role),
          onLongPress: (isLeader && !isCurrentUser)
              ? () => _showKickDialog(context, member)
              : null,
        );
      },
    );
  }
    

  Widget _buildRoleIcon(String role) {
    if (role == 'CAPTAIN') {
      return const Icon(Icons.star, color: Colors.amber, size: 22);
    } else if (role == 'VICE_CAPTAIN') {
      return const Icon(Icons.star_half, color: Colors.amber, size: 22);
    }
    return const SizedBox.shrink();
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'CAPTAIN':
        return 'Đội trưởng';
      case 'VICE_CAPTAIN':
        return 'Đội phó';
      default:
        return 'Thành viên';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'CAPTAIN':
        return Colors.amber[700]!;
      case 'VICE_CAPTAIN':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showKickDialog(BuildContext context, TeamMemberModel member) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                member.displayName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text('Xóa khỏi đội',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _handleRequest(context, member.id, 'REJECT');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleRequest(BuildContext context, String userId, String action) async {
    final provider = context.read<TeamProvider>();
    final success = await provider.handleJoinRequest(team.id, userId, action);
    Fluttertoast.showToast(
      msg: success
          ? (action == 'APPROVE' ? 'Đã duyệt thành viên' : 'Đã từ chối')
          : 'Có lỗi xảy ra',
      backgroundColor: success ? null : Colors.red,
    );
  }
}