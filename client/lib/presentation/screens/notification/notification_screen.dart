import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../../data/models/notification_model.dart';
import '../team/team_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().fetchNotifications();
    });
  }

  // Icon theo loại thông báo
  Widget _buildLeadingIcon(NotificationModel notif) {
    IconData icon;
    Color color;

    switch (notif.type) {
      case 'TEAM_INVITE':
        icon = Icons.person_add;
        color = Colors.orange;
        break;
      case 'TEAM_JOIN_APPROVED':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'TEAM_JOIN_REJECTED':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'NEW_MATCH':
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      case 'VOTE':
        icon = Icons.how_to_vote;
        color = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    // Ưu tiên hiển thị avatar sender, nếu không có thì hiện icon
    if (notif.sender?.avatar != null && notif.sender!.avatar!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(notif.sender!.avatar!),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: color.withOpacity(0.15),
      child: Icon(icon, color: color, size: 22),
    );
  }

  // Format thời gian tương đối (VD: "5 phút trước")
  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  // Điều hướng khi bấm vào thông báo
  void _onTapNotification(BuildContext context, NotificationModel notif) {
    // Đánh dấu đã đọc
    context.read<TeamProvider>().markNotificationAsRead(notif.id);

    // Điều hướng theo loại
    if (notif.relatedId != null) {
      switch (notif.type) {
        case 'TEAM_INVITE':
        case 'TEAM_JOIN_APPROVED':
        case 'TEAM_JOIN_REJECTED':
        case 'VOTE':
        case 'MATCH_SCHEDULE':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeamDetailScreen(teamId: notif.relatedId!),
            ),
          );
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Nút "Đọc hết"
          Consumer<TeamProvider>(
            builder: (_, provider, __) {
              if (provider.unreadCount == 0) return const SizedBox();
              return TextButton(
                onPressed: () => provider.markAllNotificationsAsRead(),
                child: const Text(
                  'Đọc hết',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, _) {
          if (provider.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có thông báo nào',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: provider.notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final notif = provider.notifications[index];
              return InkWell(
                onTap: () => _onTapNotification(context, notif),
                child: Container(
                  // Nền xanh nhạt nếu chưa đọc
                  color: notif.isRead ? Colors.white : Colors.green.withOpacity(0.06),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLeadingIcon(notif),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.content,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notif.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(notif.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: notif.isRead ? Colors.grey : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Chấm xanh nếu chưa đọc
                      if (!notif.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
