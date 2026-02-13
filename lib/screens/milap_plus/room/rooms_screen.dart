import 'package:flutter/material.dart';
import '../../../models/room.dart';
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
  final _idController = TextEditingController();
  final _pinController = TextEditingController();
  late AnimationController _pulseController;

  final List<Room> _mockRooms = [
    Room(
      id: '1',
      name: 'Late Night Vibes 🌙',
      description: 'Chill conversations for night owls',
      category: RoomCategory.General,
      hostId: '1',
      hostName: 'Ayesha Khan',
      hostAvatar: 'https://i.pravatar.cc/150?img=1',
      participants: [],
      maxParticipants: 50,
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      messageCount: 234,
      coverImage:
          'https://images.unsplash.com/photo-1514525253361-bee8718a340b?w=800',
    ),
    Room(
      id: '2',
      name: 'Dating & Relationships 💕',
      description: 'Find your soulmate, share experiences',
      category: RoomCategory.Dating,
      hostId: '2',
      hostName: 'Ahmed Ali',
      hostAvatar: 'https://i.pravatar.cc/150?img=12',
      participants: [],
      maxParticipants: 30,
      isPublic: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      messageCount: 156,
      coverImage:
          'https://images.unsplash.com/photo-1511733351957-2cdd9f232a43?w=800',
    ),
    Room(
      id: '3',
      name: 'VIP Lounge 👑',
      description: 'Exclusive room for premium members',
      category: RoomCategory.General,
      hostId: '3',
      hostName: 'Sara Ahmed',
      hostAvatar: 'https://i.pravatar.cc/150?img=5',
      participants: [],
      maxParticipants: 20,
      isPublic: false,
      pinCode: '1234',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      messageCount: 89,
      coverImage:
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    for (var room in _mockRooms) {
      final count =
          (room.maxParticipants * 0.3).toInt() + (room.id.hashCode % 10);
      room.participants.addAll(
        List.generate(
            count,
            (i) => RoomParticipant(
                  userId: 'user_$i',
                  name: 'User $i',
                  avatar: 'https://i.pravatar.cc/150?img=${i + 10}',
                  joinedAt: DateTime.now().subtract(Duration(minutes: i * 5)),
                )),
      );
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<Room> get _filteredRooms {
    return _mockRooms.where((room) {
      final matchesCategory =
          _selectedCategory == null || room.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          room.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.milapPlusSecondary,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategoryGrid()),
            SliverToBoxAdapter(child: _buildSectionTitle('Featured Vibes')),
            SliverToBoxAdapter(child: _buildFeaturedRooms()),
            SliverToBoxAdapter(child: _buildSectionTitle('Live Rooms')),
            _buildActiveRoomsList(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
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
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 20),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded,
                color: AppColors.milapPlusPrimary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search vibes, rooms or topics...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: Colors.white70, size: 18),
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
          ...RoomCategory.values
              .map((c) => _buildCategoryItem(c, c.name, _getCategoryIcon(c))),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      RoomCategory? category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.milapPlusPrimary
              : AppColors.milapPlusSurface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.milapPlusPrimary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : null,
          border: Border.all(
              color: isSelected
                  ? AppColors.milapPlusPrimary
                  : Colors.white.withOpacity(0.05)),
        ),
        child: Center(
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.black : Colors.white60, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.black : Colors.white60,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: AppTextStyles.h4.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              )),
          Text('View all',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.milapPlusPrimary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFeaturedRooms() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: _mockRooms.length,
        itemBuilder: (context, index) {
          final room = _mockRooms[index];
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => _handleJoinRoom(room),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.network(
                      room.coverImage ?? 'https://picsum.photos/800/600',
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8)
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.milapPlusPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.black, size: 14),
                          const SizedBox(width: 4),
                          Text('VIP FEATURED',
                              style: AppTextStyles.label.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                              )),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.name,
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            )),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildAvatarStack(room.participants),
                            const SizedBox(width: 8),
                            Text('${room.participantCount} in room',
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarStack(List<RoomParticipant> participants) {
    final count = participants.length > 3 ? 3 : participants.length;
    return SizedBox(
      height: 24,
      width: 24.0 + (count - 1) * 16.0,
      child: Stack(
        children: List.generate(count, (i) {
          return Positioned(
            left: i * 16.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage(participants[i].avatar),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveRoomsList() {
    final rooms = _filteredRooms;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildRoomListItem(rooms[index]),
          childCount: rooms.length,
        ),
      ),
    );
  }

  Widget _buildRoomListItem(Room room) {
    return GestureDetector(
      onTap: () => _handleJoinRoom(room),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.milapPlusSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    room.coverImage ?? 'https://picsum.photos/200/200',
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                if (room.requiresPin)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.lock_rounded,
                          color: AppColors.milapPlusPrimary, size: 20),
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
                        child: Text(room.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h4.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            )),
                      ),
                      _buildLiveIndicator(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(room.description,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person_pin_circle_rounded,
                          color: AppColors.milapPlusPrimary.withOpacity(0.7),
                          size: 14),
                      const SizedBox(width: 4),
                      Text(room.hostName,
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people_rounded,
                                color: Colors.white38, size: 12),
                            const SizedBox(width: 4),
                            Text(
                                '${room.participantCount}/${room.maxParticipants}',
                                style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
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
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1 + (_pulseController.value * 0.1)),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color: Colors.red
                    .withOpacity(0.3 + (_pulseController.value * 0.7)),
                width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              const Text('LIVE',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5)),
            ],
          ),
        );
      },
    );
  }

  void _handleJoinRoom(Room room) {
    if (room.requiresPin) {
      _showPinJoinDialog(room);
    } else {
      // Direct Join with confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joining ${room.name}...'),
          backgroundColor: AppColors.milapPlusPrimary,
          duration: const Duration(seconds: 1),
        ),
      );
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
        title: Column(
          children: [
            Text('Private Room',
                style: AppTextStyles.h3.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(room.name,
                style: AppTextStyles.label.copyWith(
                    color: AppColors.milapPlusPrimary,
                    fontSize: 10,
                    letterSpacing: 1.5)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'This room is private. Please enter the PIN code provided by the host.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 24),
            _buildDialogTextField(
                _pinController, 'PIN Code', Icons.lock_outline_rounded,
                isPin: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppTextStyles.label.copyWith(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_pinController.text == room.pinCode) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('PIN Verified. Entering ${room.name}...'),
                    backgroundColor: AppColors.milapPlusPrimary,
                  ),
                );
                widget.onJoinRoom(room.id, room);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid PIN Code.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.milapPlusPrimary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('JOIN ROOM',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showModeratedJoinDialog(Room room) {
    _idController.clear();
    _pinController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.milapPlusSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Column(
          children: [
            Text('Join ${room.name}',
                style: AppTextStyles.h3.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Moderation Required',
                style: AppTextStyles.label.copyWith(
                    color: AppColors.milapPlusPrimary,
                    fontSize: 10,
                    letterSpacing: 1.5)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Enter the unique Room ID and PIN to request access. Your request will be sent to moderators.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body
                    .copyWith(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 24),
            _buildDialogTextField(_idController, 'Room ID', Icons.tag_rounded),
            const SizedBox(height: 12),
            _buildDialogTextField(
                _pinController, 'PIN Code', Icons.lock_outline_rounded,
                isPin: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppTextStyles.label.copyWith(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_idController.text == room.id &&
                  (_pinController.text == room.pinCode ||
                      room.pinCode == null)) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Join request sent to Owner & Moderators.'),
                    backgroundColor: AppColors.milapPlusPrimary,
                  ),
                );
                widget.onJoinRoom(room.id, room);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Invalid Room ID or PIN Code.'),
                      backgroundColor: Colors.redAccent),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.milapPlusPrimary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('SEND REQUEST',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPin = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPin,
        keyboardType: isPin ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.milapPlusPrimary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(RoomCategory category) {
    switch (category) {
      case RoomCategory.Dating:
        return Icons.favorite_rounded;
      case RoomCategory.Friendship:
        return Icons.handshake_rounded;
      case RoomCategory.Events:
        return Icons.celebration_rounded;
      case RoomCategory.General:
        return Icons.forum_rounded;
    }
  }
}
