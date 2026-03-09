import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/room.dart';
import '../../../providers/user_provider.dart';
import '../../../services/room_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class RoomsScreen extends StatefulWidget {
  final Function(String roomId, Room room) onJoinRoom;
  final VoidCallback onCreateRoom;
  final VoidCallback onBack;

  const RoomsScreen({
    Key? key,
    required this.onJoinRoom,
    required this.onCreateRoom,
    required this.onBack,
  }) : super(key: key);

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen>
    with SingleTickerProviderStateMixin {
  RoomCategory? _selectedCategory;
  String _searchQuery = '';
  final _pinController = TextEditingController();
  late AnimationController _pulseController;
  final RoomService _roomService = RoomService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.milapPlusSecondary,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Room>>(
          stream: _roomService.streamActiveRooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allRooms = snapshot.data ?? [];
            final filteredRooms = allRooms.where((room) {
              final matchesCategory = _selectedCategory == null || room.category == _selectedCategory;
              final matchesSearch = _searchQuery.isEmpty || room.name.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(),
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverToBoxAdapter(child: _buildCategoryGrid()),

                if (filteredRooms.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No active rooms found.', style: TextStyle(color: Colors.white38))),
                  )
                else ...[
                  SliverToBoxAdapter(child: _buildSectionTitle('Live Vibes')),
                  _buildActiveRoomsList(filteredRooms, user.id),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildCreateRoomFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCreateRoomFAB() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 60,
      child: FloatingActionButton.extended(
        onPressed: widget.onCreateRoom,
        backgroundColor: AppColors.milapPlusPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded, color: Colors.black, size: 28),
        label: Text('CREATE ROOM',
            style: AppTextStyles.label.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.2,
            )),
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discovery',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    )),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.milapPlusPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('EXPLORE PREMIUM VIBES',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.milapPlusPrimary.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        )),
                  ],
                ),
              ],
            ),
            IconButton(
              onPressed: widget.onBack,
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.milapPlusSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.milapPlusPrimary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Search vibes, rooms or topics...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildCategoryItem(null, 'All Vibe', Icons.dashboard_rounded),
          ...RoomCategory.values.map((c) => _buildCategoryItem(c, c.name, _getCategoryIcon(c))),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(RoomCategory? category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.milapPlusPrimary : AppColors.milapPlusSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? AppColors.milapPlusPrimary : Colors.white.withOpacity(0.05)),
        ),
        child: Center(
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.black : Colors.white60, size: 18),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.label.copyWith(color: isSelected ? Colors.black : Colors.white60, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Text(title, style: AppTextStyles.h4.copyWith(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildActiveRoomsList(List<Room> rooms, String currentUserId) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildRoomListItem(rooms[index], currentUserId),
          childCount: rooms.length,
        ),
      ),
    );
  }

  Widget _buildRoomListItem(Room room, String currentUserId) {
    return GestureDetector(
      onTap: () => _handleJoinRoom(room, currentUserId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.milapPlusSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    room.coverImage ?? 'https://picsum.photos/200/200',
                    width: 76, height: 76, fit: BoxFit.cover,
                  ),
                ),
                if (room.requiresPin)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.lock_rounded, color: AppColors.milapPlusPrimary, size: 20),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(room.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h4.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                      _buildLiveIndicator(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(room.description, style: const TextStyle(color: Colors.white38, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_pin_circle_rounded, color: AppColors.milapPlusPrimary, size: 14),
                      const SizedBox(width: 4),
                      Text(room.hostName, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${room.participantCount}/${room.maxParticipants}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1 + (_pulseController.value * 0.1)),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red.withOpacity(0.3 + (_pulseController.value * 0.7))),
        ),
        child: const Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.w900)),
      ),
    );
  }

  void _handleJoinRoom(Room room, String currentUserId) async {
    if (room.requiresPin) {
      _showPinJoinDialog(room);
    } else {
      await _roomService.joinRoom(room.id, RoomParticipant(
        userId: currentUserId,
        name: 'User', // In real app, pull from provider
        avatar: '',
        joinedAt: DateTime.now(),
      ));
      widget.onJoinRoom(room.id, room);
    }
  }

  void _showPinJoinDialog(Room room) {
    _pinController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.milapPlusSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text('Private Room', style: AppTextStyles.h3.copyWith(color: Colors.white)),
        content: TextField(
          controller: _pinController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.milapPlusPrimary, fontSize: 24, letterSpacing: 8),
          decoration: const InputDecoration(hintText: 'PIN Code', hintStyle: TextStyle(color: Colors.white10)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (_pinController.text == room.pinCode) {
                Navigator.pop(context);
                widget.onJoinRoom(room.id, room);
              }
            },
            child: const Text('JOIN'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(RoomCategory category) {
    switch (category) {
      case RoomCategory.Dating: return Icons.favorite_rounded;
      case RoomCategory.Friendship: return Icons.handshake_rounded;
      case RoomCategory.Events: return Icons.celebration_rounded;
      case RoomCategory.General: return Icons.forum_rounded;
    }
  }
}
