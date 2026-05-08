import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../providers/team_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../data/models/team_model.dart';
import '../../../../data/models/activity_model.dart';
import '../create_activity_screen.dart';

class TeamFeedTab extends StatefulWidget {
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
  State<TeamFeedTab> createState() => _TeamFeedTabState();
}

class _TeamFeedTabState extends State<TeamFeedTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<TeamProvider>();
        if (provider.hasMoreActivities && !provider.isLoadingActivities) {
          provider.fetchActivities(widget.team.id);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: widget.isLeader
          ? FloatingActionButton.extended(
              backgroundColor: Colors.green,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Đăng bài',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CreateActivityScreen(teamId: widget.team.id),
                ),
              ),
            )
          : null,
      body: Consumer<TeamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.activities.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.green));
          }

          return RefreshIndicator(
            color: Colors.green,
            onRefresh: () =>
                provider.fetchActivities(widget.team.id, refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: provider.activities.isEmpty
                  ? 1
                  : provider.activities.length +
                      (provider.hasMoreActivities ? 1 : 0),
              itemBuilder: (context, index) {
                if (provider.activities.isEmpty) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.feed_outlined,
                              size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có bài đăng nào.\nHãy đăng bài đầu tiên!',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (index == provider.activities.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child:
                            CircularProgressIndicator(color: Colors.green)),
                  );
                }

                return _buildActivityCard(
                    context, provider.activities[index], provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(
      BuildContext context, ActivityModel activity, TeamProvider provider) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + tên + thời gian
            _buildCardHeader(activity),
            const SizedBox(height: 12),

            // Badge loại bài
            _buildTypeBadge(activity.type),
            const SizedBox(height: 10),

            // Nội dung
            Text(
              activity.content,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),

            // Nếu là VOTE hoặc MATCH_SCHEDULE thì hiện options
            if (activity.options.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildVoteOptions(context, activity, provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(ActivityModel activity) {
    final timeAgo = _formatTimeAgo(activity.createdAt);
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.green[50],
          backgroundImage: (activity.authorAvatar != null &&
                  activity.authorAvatar!.isNotEmpty)
              ? NetworkImage(activity.authorAvatar!)
              : null,
          child: (activity.authorAvatar == null ||
                  activity.authorAvatar!.isEmpty)
              ? const Icon(Icons.person, color: Colors.green, size: 20)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.authorName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                timeAgo,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;
    IconData icon;

    switch (type) {
      case 'VOTE':
        color = Colors.blue;
        label = 'Bình chọn';
        icon = Icons.how_to_vote_outlined;
        break;
      case 'MATCH_SCHEDULE':
        color = Colors.orange;
        label = 'Lịch thi đấu';
        icon = Icons.sports_soccer;
        break;
      default: // NOTICE
        color = Colors.green;
        label = 'Thông báo';
        icon = Icons.campaign_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVoteOptions(
      BuildContext context, ActivityModel activity, TeamProvider provider) {
    // Tổng số vote
    final totalVotes =
        activity.options.fold(0, (sum, o) => sum + o.voterIds.length);

    return Column(
      children: activity.options.map((option) {
        final hasVoted = option.voterIds.contains(widget.currentUserId);
        final voteCount = option.voterIds.length;
        final percent =
            totalVotes == 0 ? 0.0 : voteCount / totalVotes;

        return GestureDetector(
          onTap: hasVoted
              ? null
              : () async {
                  final success = await provider.interactActivity(
                      activity.id, option.id);
                  if (!success) {
                    Fluttertoast.showToast(
                        msg: 'Có lỗi xảy ra',
                        backgroundColor: Colors.red);
                  }
                },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: hasVoted ? Colors.green[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasVoted ? Colors.green : Colors.grey[300]!,
                width: hasVoted ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: hasVoted
                              ? Colors.green[700]
                              : Colors.black87,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (hasVoted)
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$voteCount phiếu',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.grey[200],
                    color: hasVoted ? Colors.green : Colors.grey[400],
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}