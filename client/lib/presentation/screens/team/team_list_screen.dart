import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/team_model.dart';
import '../../providers/team_provider.dart';
import 'create_team_screen.dart';
import 'team_detail_screen.dart';

class TeamListScreen extends StatefulWidget {
  const TeamListScreen({super.key});

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedSport;

  final Map<String, String> _sportOptions = {
    'Tất cả': '',
    'Bóng đá': 'Bóng đá',
    'Bóng rổ': 'Bóng rổ',
    'Cầu lông': 'Cầu lông',
    'Tennis': 'Tennis',
    'Bóng chuyền': 'Bóng chuyền',
  };


  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().fetchMyTeams();
      context.read<TeamProvider>().fetchTeams(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<TeamProvider>();

        if (!provider.isLoading && provider.hasMoreTeams) {
          provider.fetchTeams(
            keyword: _searchController.text.trim(),
            sport: _selectedSport,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<TeamProvider>().fetchTeams(
          keyword: _searchController.text.trim(),
          sport: _selectedSport,
          refresh: true,
        );
  }

  Future<void> _requestJoinTeam(String teamId) async {
    final provider = context.read<TeamProvider>();
    final success = await provider.joinTeam(teamId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã gửi yêu cầu xin vào đội'
              : (provider.errorMessage ?? 'Gửi yêu cầu thất bại'),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _openCreateTeamScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTeamScreen()),
    );

    if (!mounted) return;

    context.read<TeamProvider>().fetchMyTeams();
    context.read<TeamProvider>().fetchTeams(refresh: true);
  }

  Future<void> _openTeamDetail(String teamId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamDetailScreen(teamId: teamId),
      ),
    );

    if (!mounted) return;

    context.read<TeamProvider>().fetchMyTeams();
    context.read<TeamProvider>().fetchTeams(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Đội bóng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.green,
              size: 28,
            ),
            onPressed: _openCreateTeamScreen,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(text: 'Đội của tôi'),
            Tab(text: 'Khám phá'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyTeamsList(),
          Column(
            children: [
              _buildSearchBar(),
              _buildSportFilter(),
              const Divider(height: 1),
              Expanded(child: _buildExploreTeamList()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyTeamsList() {
    return Consumer<TeamProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingMyTeams) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (provider.myTeams.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Bạn chưa tham gia đội nào.\nSang tab Khám phá để tìm đội!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Colors.green,
          onRefresh: () => context.read<TeamProvider>().fetchMyTeams(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.myTeams.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
            itemBuilder: (context, index) {
              final team = provider.myTeams[index];
              return _buildMyTeamTile(team);
            },
          ),
        );
      },
    );
  }

  Widget _buildExploreTeamList() {
    return Consumer<TeamProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.teams.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (provider.teams.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Không tìm thấy đội nào.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Colors.green,
          onRefresh: () => context.read<TeamProvider>().fetchTeams(
                keyword: _searchController.text.trim(),
                sport: _selectedSport,
                refresh: true,
              ),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.teams.length + (provider.hasMoreTeams ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.teams.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  ),
                );
              }

              final team = provider.teams[index];
              return _buildExploreTeamTile(team);
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _onSearch(),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm đội...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune, color: Colors.green),
            onPressed: _onSearch,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildSportFilter() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _sportOptions.length,
        itemBuilder: (context, index) {
          final label = _sportOptions.keys.elementAt(index);
          final value = _sportOptions.values.elementAt(index);

          final isSelected =
              _selectedSport == value || (value.isEmpty && _selectedSport == null);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSport = value.isEmpty ? null : value;
              });
              _onSearch();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyTeamTile(TeamModel team) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildTeamAvatar(team),
      title: Text(
        team.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: _buildTeamInfo(team),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _openTeamDetail(team.id),
    );
  }

  Widget _buildExploreTeamTile(TeamModel team) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: _buildTeamAvatar(team),
        title: Text(
          team.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: _buildTeamInfo(team),
        trailing: ElevatedButton(
          onPressed: () => _requestJoinTeam(team.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(72, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Xin vào',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () => _openTeamDetail(team.id),
      ),
    );
  }

  Widget _buildTeamAvatar(TeamModel team) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.green[50],
      backgroundImage: (team.avatar != null && team.avatar!.isNotEmpty)
          ? NetworkImage(team.avatar!)
          : null,
      child: (team.avatar == null || team.avatar!.isEmpty)
          ? const Icon(Icons.groups, color: Colors.green, size: 30)
          : null,
    );
  }

  Widget _buildTeamInfo(TeamModel team) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.sports_soccer, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              team.sport,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.people, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            '${team.memberCount} thành viên',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}