import 'package:flutter/material.dart';
import '../../../../data/models/team_model.dart';

class TeamChatTab extends StatelessWidget {
  final TeamDetailModel team;
  final String currentUserId;

  const TeamChatTab({
    super.key,
    required this.team,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Chat nhóm — Bước 5 sẽ làm'),
    );
  }
}