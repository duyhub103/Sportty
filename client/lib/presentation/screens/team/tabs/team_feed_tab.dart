import 'package:flutter/material.dart';
import '../../../../data/models/team_model.dart';

class TeamFeedTab extends StatelessWidget {
  final TeamDetailModel team;
  final bool isLeader;
  final String currentUserId;

  const TeamFeedTab({
    super.key,
    required this.team,
    required this.isLeader,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Bảng tin — Bước 4 sẽ làm'),
    );
  }
}