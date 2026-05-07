import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/socket_client.dart';
import '../../providers/team_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/team_model.dart';
import 'tabs/team_feed_tab.dart';
import 'tabs/team_members_tab.dart';
import 'tabs/team_chat_tab.dart';

class TeamDetailScreen extends StatefulWidget {
  final String teamId;

  const TeamDetailScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSendingJoinRequest = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TeamProvider>();
      provider.fetchTeamDetail(widget.teamId);
      provider.fetchActivities(widget.teamId, refresh: true);

      SocketClient().initSocket(onConnected: () {
      if (mounted) provider.setupTeamSocket(widget.teamId);
    });
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final provider = context.read<TeamProvider>();
      if (_tabController.index == 0) {
        provider.fetchActivities(widget.teamId, refresh: true);
      }
      if (_tabController.index == 1) {
        provider.fetchTeamDetail(widget.teamId);
      }
    });
  }

  @override
  void dispose() {
    context.read<TeamProvider>().leaveTeamSocket(widget.teamId);
    _tabController.dispose();
    super.dispose();
  }

  bool _isCurrentUserMember(TeamDetailModel team, String currentUserId) {
    if (currentUserId.isEmpty) return false;
    return team.members.any((member) => member.id == currentUserId);
  }

  Future<void> _sendJoinRequest(
    TeamProvider provider,
    TeamDetailModel team,
  ) async {
    if (_isSendingJoinRequest) return;

    setState(() {
      _isSendingJoinRequest = true;
    });

    final success = await provider.joinTeam(team.id);

    if (!mounted) return;

    setState(() {
      _isSendingJoinRequest = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã gửi yêu cầu tham gia đội'
              : (provider.errorMessage ?? 'Gửi yêu cầu thất bại'),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';

    return Consumer<TeamProvider>(
      builder: (context, provider, _) {
        final team = provider.currentTeam;

        final isMember = team == null ? false : _isCurrentUserMember(team, currentUserId);
        final isLeader = team?.isLeader(currentUserId) ?? false;
        // Thêm tạm vào build() sau dòng final isLeader = ...
        print('currentUserId: $currentUserId');
        print('members: ${team?.members.map((m) => m.id).toList()}');

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Colors.green),
            title: team == null
                ? const Text(
                    'Chi tiết đội',
                    style: TextStyle(color: Colors.black87),
                  )
                : Row(
                    children: [
                      GestureDetector(
                        onTap: isLeader
                            ? () => _pickTeamAvatar(context, provider)
                            : null,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green[50],
                              backgroundImage:
                                  team.avatar != null && team.avatar!.isNotEmpty
                                      ? NetworkImage(team.avatar!)
                                      : null,
                              child:
                                  team.avatar == null || team.avatar!.isEmpty
                                      ? const Icon(
                                          Icons.groups,
                                          color: Colors.green,
                                        )
                                      : null,
                            ),
                            if (isLeader)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              team.sport,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            actions: [
              if (team != null && isMember) ...[
                if (isLeader)
                  TextButton.icon(
                    onPressed: () => _showFundDialog(context, provider, team),
                    icon: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green,
                      size: 18,
                    ),
                    label: Text(
                      _formatFund(team.fund),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) =>
                      _handleMenuAction(context, value, provider),
                  itemBuilder: (_) => [
                    if (!isLeader)
                      const PopupMenuItem(
                        value: 'leave',
                        child: Text('Rời đội'),
                      ),
                    if (isLeader)
                      const PopupMenuItem(
                        value: 'members',
                        child: Text('Xem thành viên chờ duyệt'),
                      ),
                  ],
                ),
              ],
            ],
            bottom: team == null || !isMember
                ? null
                : TabBar(
                    controller: _tabController,
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.green,
                    tabs: const [
                      Tab(icon: Icon(Icons.feed_outlined), text: 'Bảng tin'),
                      Tab(
                        icon: Icon(Icons.people_outline),
                        text: 'Thành viên',
                      ),
                      Tab(
                        icon: Icon(Icons.chat_bubble_outline),
                        text: 'Chat nhóm',
                      ),
                    ],
                  ),
          ),
          body: team == null
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : isMember
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        TeamFeedTab(
                          team: team,
                          isLeader: isLeader,
                          currentUserId: currentUserId,
                        ),
                        TeamMembersTab(
                          team: team,
                          isLeader: isLeader,
                          currentUserId: currentUserId,
                        ),
                        TeamChatTab(
                          team: team,
                          currentUserId: currentUserId,
                        ),
                      ],
                    )
                  : _buildNotMemberView(provider, team),
        );
      },
    );
  }

  Widget _buildNotMemberView(
    TeamProvider provider,
    TeamDetailModel team,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.green[50],
              backgroundImage: team.avatar != null && team.avatar!.isNotEmpty
                  ? NetworkImage(team.avatar!)
                  : null,
              child: team.avatar == null || team.avatar!.isEmpty
                  ? const Icon(
                      Icons.groups,
                      color: Colors.green,
                      size: 52,
                    )
                  : null,
            ),
            const SizedBox(height: 18),
            Text(
              team.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              team.sport,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${team.members.length} thành viên',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Bạn chưa tham gia đội này.\nHãy gửi yêu cầu để được xem bảng tin, thành viên và chat nhóm.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSendingJoinRequest
                    ? null
                    : () => _sendJoinRequest(provider, team),
                icon: _isSendingJoinRequest
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.person_add_alt_1),
                label: Text(
                  _isSendingJoinRequest ? 'Đang gửi...' : 'Xin vào đội',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.green.withOpacity(0.6),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTeamAvatar(
    BuildContext context,
    TeamProvider provider,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final success = await provider.updateTeamAvatar(widget.teamId, image.path);

    Fluttertoast.showToast(
      msg: success
          ? 'Cập nhật ảnh thành công!'
          : (provider.errorMessage ?? 'Thất bại'),
      backgroundColor: success ? null : Colors.red,
    );
  }

  void _showFundDialog(
    BuildContext context,
    TeamProvider provider,
    TeamDetailModel team,
  ) {
    final controller = TextEditingController();
    String action = 'add';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text(
            'Cập nhật quỹ đội',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Số dư hiện tại: ${_formatFund(team.fund)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setStateDialog(() => action = 'add'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              action == 'add' ? Colors.green : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '+ Cộng tiền',
                            style: TextStyle(
                              color: action == 'add'
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setStateDialog(() => action = 'subtract'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: action == 'subtract'
                              ? Colors.red
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '- Trừ tiền',
                            style: TextStyle(
                              color: action == 'subtract'
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập số tiền...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixText: action == 'add' ? '+ ' : '- ',
                  prefixStyle: TextStyle(
                    color: action == 'add' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  suffixText: 'đ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final amount = double.tryParse(controller.text.trim());

                if (amount == null || amount <= 0) {
                  Fluttertoast.showToast(msg: 'Số tiền không hợp lệ');
                  return;
                }

                Navigator.pop(dialogContext);

                final finalAmount = action == 'add' ? amount : -amount;
                final success =
                    await provider.updateFund(widget.teamId, finalAmount);

                Fluttertoast.showToast(
                  msg: success ? 'Cập nhật quỹ thành công!' : 'Thất bại',
                  backgroundColor: success ? null : Colors.red,
                );
              },
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String value,
    TeamProvider provider,
  ) {
    if (value == 'leave') {
      _confirmLeaveTeam(context, provider);
    } else if (value == 'members') {
      _showPendingRequestsSheet(context, provider);
    }
  }
  
  Future<void> _confirmLeaveTeam(
    BuildContext context,
    TeamProvider provider,
  ) async {
    final team = provider.currentTeam;
    if (team == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rời đội?'),
        content: Text('Bạn có chắc muốn rời khỏi "${team.name}" không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rời đội', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final success = await provider.leaveTeam(team.id);
    if (!mounted) return;
    if (success) {
      Fluttertoast.showToast(
        msg: 'Đã rời khỏi "${team.name}"',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context); // Quay về màn hình trước (team list)
    } else {
      Fluttertoast.showToast(
        msg: provider.errorMessage ?? 'Rời đội thất bại',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showPendingRequestsSheet(BuildContext context, TeamProvider provider) {
    final team = provider.currentTeam;
    if (team == null) return;

    final pendingList = team.pendingRequests;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  const Text(
                    'Chờ duyệt',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${pendingList.length}',
                      style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: pendingList.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có yêu cầu nào đang chờ',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: pendingList.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (ctx, index) {
                        final user = pendingList[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.orange[50],
                            backgroundImage: user.avatar != null
                                ? NetworkImage(user.avatar!)
                                : null,
                            child: user.avatar == null
                                ? const Icon(Icons.person,
                                    color: Colors.orange)
                                : null,
                          ),
                          title: Text(user.displayName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: const Text('Đang chờ duyệt',
                              style: TextStyle(color: Colors.orange)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final success = await provider
                                      .handleJoinRequest(
                                          team.id, user.id, 'APPROVE');
                                  Fluttertoast.showToast(
                                    msg: success
                                        ? 'Đã duyệt thành viên'
                                        : 'Có lỗi xảy ra',
                                    backgroundColor:
                                        success ? null : Colors.red,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Duyệt',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final success = await provider
                                      .handleJoinRequest(
                                          team.id, user.id, 'REJECT');
                                  Fluttertoast.showToast(
                                    msg: success
                                        ? 'Đã từ chối'
                                        : 'Có lỗi xảy ra',
                                    backgroundColor:
                                        success ? null : Colors.red,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Từ chối',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFund(double fund) {
    if (fund >= 1000000) {
      return '${(fund / 1000000).toStringAsFixed(1)}M đ';
    }

    if (fund >= 1000) {
      return '${(fund / 1000).toStringAsFixed(0)}K đ';
    }

    return '${fund.toStringAsFixed(0)} đ';
  }
}