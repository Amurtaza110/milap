import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:milap/models/room.dart';
import 'package:milap/providers/user_provider.dart';
import 'package:milap/services/room_service.dart';
import 'package:milap/theme/app_colors.dart';
import 'package:milap/theme/app_text_styles.dart';

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

class _RoomsScreenState extends State<RoomsScreen> {
  final RoomService _roomService = RoomService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.milapPlusSecondary,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildSectionTitle('Live Vibes')),
            StreamBuilder<List<Room>>(
              stream: _roomService.getRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No active rooms found.',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                  );
                }

                final rooms = snapshot.data!
                    .where((room) => room.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                return _buildActiveRoomsList(rooms, user.id);
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        ),
      ),
      floatingActionButton: _buildCreateRoomFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                onChanged: (value) => setState(() => _searchQuery = value),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                room.imageUrl ?? 'https://picsum.photos/200/200',
                width: 76,
                height: 76,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.description,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${room.members.length} members',
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleJoinRoom(Room room, String currentUserId) async {
    if (!room.members.contains(currentUserId)) {
      await _roomService.joinRoom(room.id, currentUserId);
    }
    widget.onJoinRoom(room.id, room);
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
}
