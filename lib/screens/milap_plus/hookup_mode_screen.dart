import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';

import '../../models/enums.dart';
import '../../models/app_screen.dart';
import '../../providers/user_provider.dart';
import '../../services/event_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../models/social_event.dart';
import '../../widgets/milap_plus_swipe_card.dart';

class HookupModeScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(bool, HookupIntent?) onToggleHookup;
  final VoidCallback onCreateEvent;
  final VoidCallback onManageEvents;
  final Function(AppScreen)? onNavigate;

  const HookupModeScreen({
    Key? key,
    required this.onBack,
    required this.onToggleHookup,
    required this.onCreateEvent,
    required this.onManageEvents,
    this.onNavigate,
  }) : super(key: key);

  @override
  State<HookupModeScreen> createState() => _HookupModeScreenState();
}

class _HookupModeScreenState extends State<HookupModeScreen> {
  HookupIntent _selectedIntent = HookupIntent.Casual;
  String _currentTab = 'vibe'; // 'vibe' | 'room'
  bool _showVisitors = false;
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user?.hookupIntent != null) _selectedIntent = user!.hookupIntent!;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) return const Center(child: CircularProgressIndicator());

    if (!user.isMilapGold) {
      return _buildGoldUpsell();
    }

    final profileVisitors = user.profileVisitors ??
        [
          ProfileVisitor(
              userId: '3',
              name: 'Hamza',
              photo: 'https://picsum.photos/seed/milap-visitor-1/200/200',
              timestamp: DateTime.now()
                  .subtract(const Duration(minutes: 30))
                  .millisecondsSinceEpoch),
          ProfileVisitor(
              userId: '2',
              name: 'Zain & Sarah',
              photo: 'https://picsum.photos/seed/milap-visitor-2/200/200',
              timestamp: DateTime.now()
                  .subtract(const Duration(minutes: 120))
                  .millisecondsSinceEpoch),
        ];

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 16),
            color: const Color(0xFF111111),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: Colors.white10, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: Colors.white54)),
                    ),
                    const Text('Milap+',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.0)),
                    Row(
                      children: [
                        IconButton(
                            onPressed: widget.onManageEvents,
                            icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                    color: Colors.white10,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.calendar_today_rounded,
                                    size: 18, color: Colors.white54))),
                        IconButton(
                          onPressed: () =>
                              setState(() => _showVisitors = !_showVisitors),
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: _showVisitors
                                    ? AppColors.primary
                                    : Colors.white10,
                                shape: BoxShape.circle,
                                boxShadow: _showVisitors
                                    ? [
                                        BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.5),
                                            blurRadius: 15)
                                      ]
                                    : null),
                            child: const Icon(Icons.visibility_rounded,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!_showVisitors) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20)),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tabWidth = constraints.maxWidth / 2;
                        return Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              left: _currentTab == 'vibe' ? 0 : tabWidth,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: tabWidth,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                _buildTabButton('VIBE', _currentTab == 'vibe',
                                    () {
                                  setState(() => _currentTab = 'vibe');
                                }),
                                _buildTabButton('Room', _currentTab == 'room',
                                    () {
                                  setState(() => _currentTab = 'room');
                                }),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: _showVisitors
                ? _buildVisitorsList(profileVisitors)
                : (_currentTab == 'vibe'
                    ? _buildVibeTab(user)
                    : _buildRoomTab(user)),
          ),
        ],
      ),
      floatingActionButton: !_showVisitors
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/country-discovery');
              },
              backgroundColor: AppColors.milapPlusPrimary,
              elevation: 8,
              splashColor: Colors.white24,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.public_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildGoldUpsell() {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
            AppColors.milapPlusSecondary,
            AppColors.milapPlusSurface,
            AppColors.milapPlusSecondary
          ], begin: Alignment.topLeft, end: Alignment.bottomRight))),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                          color: AppColors.milapPlusPrimary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    AppColors.milapPlusPrimary.withOpacity(0.3),
                                blurRadius: 30)
                          ]),
                      child: const Center(
                          child: Text('👑', style: TextStyle(fontSize: 48)))),
                  const SizedBox(height: 32),
                  const Text('Milap+',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: AppColors.milapPlusPrimary,
                          letterSpacing: -2.0)),
                  const SizedBox(height: 16),
                  const Text(
                      'Unlock exclusive features, see who visited you, and access live connections.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                          height: 1.5,
                          letterSpacing: 1.0)),
                  const SizedBox(height: 40),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.milapPlusSurface,
                                title: const Text('Upgrade to Gold',
                                    style: TextStyle(color: Colors.white)),
                                content: const Text(
                                    'This will open the payment gateway.',
                                    style: TextStyle(color: Colors.white70)),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Proceed (Mock)',
                                          style: TextStyle(
                                              color:
                                                  AppColors.milapPlusPrimary))),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.milapPlusPrimary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('UPGRADE TO GOLD',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5)))),
                  const SizedBox(height: 24),
                  TextButton(
                      onPressed: widget.onBack,
                      child: const Text('RETURN TO FEED',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white30,
                              letterSpacing: 2.0))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: active ? Colors.black : Colors.white.withOpacity(0.5),
                  letterSpacing: 1.5)),
        ),
      ),
    );
  }

  Widget _buildVisitorsList(List<ProfileVisitor> visitors) {
    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        final vis = visitors[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(vis.photo,
                      width: 56, height: 56, fit: BoxFit.cover)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vis.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      Text(
                          'Viewed at ${DateTime.fromMillisecondsSinceEpoch(vis.timestamp).toString().substring(11, 16)}',
                          style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0)),
                    ]),
              ),
              TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Viewing profile of ${vis.name}...'),
                    ));
                  },
                  child: const Text('VIEW',
                      style: TextStyle(
                          color: AppColors.milapPlusPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVibeTab(UserProfile user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildActionCard(
                  '🎉', 'Create\nEvent', 'Host a Party', Colors.indigo,
                  onTap: widget.onCreateEvent),
              const SizedBox(width: 16),
              _buildActionCard(
                  user.hookupActive == true ? '📡' : '🛰️',
                  user.hookupActive == true ? 'Live\nConnect' : 'Go\nConnect',
                  user.hookupActive == true
                      ? 'Broadcasting...'
                      : 'Tap to Active',
                  AppColors.milapPlusPrimary,
                  active: user.hookupActive == true,
                  onTap: () => widget.onToggleHookup(
                      !(user.hookupActive ?? false), _selectedIntent)),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 32),
          const Text('SET INTENT',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white30,
                  letterSpacing: 2.0)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: HookupIntent.values.map((intent) {
                final active = _selectedIntent == intent;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIntent = intent),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                          color: active
                              ? AppColors.milapPlusPrimary
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: active
                                  ? AppColors.milapPlusPrimary
                                  : Colors.white.withOpacity(0.1)),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                      color: AppColors.milapPlusPrimary
                                          .withOpacity(0.3),
                                      blurRadius: 10)
                                ]
                              : null),
                      child: Text(intent.name.toUpperCase(),
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: active ? Colors.black : Colors.white38,
                              letterSpacing: 1.0)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (user.hookupActive == true) ...[
            const SizedBox(height: 48),
            const Text('ELITE CONNECTIONS',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white30,
                    letterSpacing: 2.0)),
            const SizedBox(height: 16),
            StreamBuilder<List<UserProfile>>(
              stream: UserService().streamMilapPlusFeed(
                preferredCity: user.location,
                excludeUid: user.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.milapPlusPrimary),
                  );
                }
                
                final users = snapshot.data ?? [];
                
                if (users.isEmpty) {
                  return MilapPlusSwipeCard(
                    profile: null,
                    onAction: (_) {},
                    onViewProfile: (_) {},
                    onBlockUser: (_) {},
                  );
                }
                
                // Show the first top rated elite user matching criteria
                final topUser = users.first;
                return MilapPlusSwipeCard(
                  profile: topUser,
                  hasStatus: false,
                  onAction: (action) {
                    if (action == 'match') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sent match request to ${topUser.name}!')),
                      );
                    }
                  },
                  onViewProfile: (p) {
                    widget.onNavigate?.call(AppScreen.PUBLIC_PROFILE_VIEW);
                  },
                  onBlockUser: (id) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User blocked.')),
                    );
                  },
                );
              },
            ),
          ],
          const SizedBox(height: 24),
          const Text('GOLD EXCLUSIVE GATHERINGS',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppColors.milapPlusPrimary,
                  letterSpacing: 2.0)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: StreamBuilder(
              stream: _eventService.streamEvents(accessLevel: AccessLevel.Gold),
              builder: (context, snapshot) {
                final events = (snapshot.data as List<SocialEvent>?) ?? const <SocialEvent>[];
                return Row(
                  children: events.map((event) {
                    final cover = (event.media.isNotEmpty)
                        ? event.media[0]
                        : 'https://picsum.photos/seed/milap-gold-event/600/800';
                    return Container(
                      width: 240,
                      height: 300,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        image: DecorationImage(
                          image: NetworkImage(cover),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.4),
                            BlendMode.darken,
                          ),
                        ),
                        border: Border.all(
                          color: AppColors.milapPlusPrimary.withOpacity(0.3),
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            top: 16,
                            right: 16,
                            child: Text('👑', style: TextStyle(fontSize: 24)),
                          ),
                          Positioned(
                            bottom: 24,
                            left: 24,
                            right: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '${event.date} • ${event.location.split(',')[0]}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String emoji, String title, String subtitle, Color color,
      {bool active = false, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: active ? color : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: active
                      ? color.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1)),
              boxShadow: active
                  ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 20)]
                  : null),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                if (active)
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle))
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: active ? Colors.black : Colors.white,
                        height: 1.1)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: active ? Colors.black54 : color.withOpacity(0.5),
                        letterSpacing: 1.0))
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbySoul(String name, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16)),
              child: const Center(
                  child: Icon(Icons.person_outline_rounded,
                      color: Colors.white24))),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, color: Colors.white)),
                Text(status,
                    style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.milapPlusPrimary,
                        fontWeight: FontWeight.bold))
              ])),
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.milapPlusPrimary,
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.chat_bubble_rounded,
                  size: 16, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildRoomTab(UserProfile user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.milapPlusPrimary,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                    color: AppColors.milapPlusPrimary.withOpacity(0.3),
                    blurRadius: 30)
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Join a Room',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                      Text('VIRTUAL EVENTS & LIVE VIBES',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0)),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forum_rounded,
                      color: Colors.black, size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.onNavigate?.call(AppScreen.ROOMS),
              icon: const Icon(Icons.meeting_room_rounded, color: Colors.black),
              label: const Text('BROWSE LIVE ROOMS',
                  style: TextStyle(
                      fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.milapPlusPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('FEATURED LIVE ROOMS',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white30,
                  letterSpacing: 2.0)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://picsum.photos/id/${220 + index}/300/400',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    Colors.black45,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.milapPlusPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ROOM',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vibe Room #${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${20 * (index + 1)} souls connected',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
