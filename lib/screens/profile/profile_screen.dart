import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../models/app_screen.dart';
import '../../providers/user_provider.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onEdit;
  final VoidCallback onUpgrade;
  final VoidCallback onOpenWallet;
  final VoidCallback onOpenSupport;
  final VoidCallback onViewSentRequests;
  final Function(AppScreen)? onNavigate;

  const ProfileScreen({
    Key? key,
    required this.onLogout,
    required this.onEdit,
    required this.onUpgrade,
    required this.onOpenWallet,
    required this.onOpenSupport,
    required this.onViewSentRequests,
    this.onNavigate,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _activeTab = 'grid'; // 'grid' | 'reviews'
  bool _isMenuOpen = false;
  bool _showPrivacyModal = false;
  String _privacyTab = 'hide'; // 'hide' | 'share'
  final UserService _userService = UserService();
  List<UserProfile> _connections = const [];

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    final result =
        await _userService.getSocialFeed(preferredCity: user.location, excludeUid: user.id);
    if (!mounted) return;
    setState(() => _connections = result);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) return const Center(child: CircularProgressIndicator());

    final connections = _connections.where((p) => p.id != user.id).toList();
    final allMedia = [
      ...user.photos.map((url) => {
            'url': url,
            'type': 'photo',
            'isHidden': (user.hiddenMediaIds ?? []).contains(url)
          }),
      ...(user.videos ?? []).map((url) => {
            'url': url,
            'type': 'video',
            'isHidden': (user.hiddenMediaIds ?? []).contains(url)
          }),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 64),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: user.isMilapGold
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.primary.withOpacity(0.1)),
                              ),
                              child: Text(
                                user.isMilapGold
                                    ? 'Premium Member'
                                    : 'Free Member',
                                style: AppTextStyles.label.copyWith(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    letterSpacing: 1.2),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _isMenuOpen = true),
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12, blurRadius: 5)
                                    ]),
                                child: const Icon(AppIcons.menu,
                                    size: 24, color: AppColors.textMain),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Profile Pic
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle),
                              child: Opacity(opacity: 0.3, child: Container())),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(45),
                                border:
                                    Border.all(color: Colors.white, width: 4),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 20,
                                      offset: Offset(0, 10))
                                ],
                                image: DecorationImage(
                                    image: NetworkImage(user.photos[0]),
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 15,
                            child: GestureDetector(
                              onTap: widget.onEdit,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.border),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12, blurRadius: 10)
                                    ]),
                                child: const Icon(AppIcons.edit,
                                    color: AppColors.primary, size: 20),
                              ),
                            ),
                          ),
                          if (user.isMilapGold)
                            const Positioned(
                                top: -10,
                                right: 10,
                                child:
                                    Text('👑', style: TextStyle(fontSize: 32))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(user.name,
                          style: AppTextStyles.h1.copyWith(
                              fontSize: 28,
                              color: AppColors.textMain,
                              letterSpacing: -1.0)),
                      Text(user.location.toUpperCase(),
                          style: AppTextStyles.label.copyWith(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              letterSpacing: 2.0)),
                      const SizedBox(height: 24),
                      // Stats
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.border)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('${allMedia.length}', 'Media'),
                            _buildStatItem('1.2k', 'Matches', isPrimary: true),
                            _buildStatItem('450', 'Visits'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text('"${user.bio}"',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: AppColors.textLight,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: 80,
                  maxHeight: 80,
                  child: Container(
                    color: AppColors.background.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          _buildTabButton('Media', _activeTab == 'grid',
                              () => setState(() => _activeTab = 'grid')),
                          _buildTabButton('Reviews', _activeTab == 'reviews',
                              () => setState(() => _activeTab = 'reviews')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Grid / Reviews
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: _activeTab == 'grid'
                    ? SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.8),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == allMedia.length) {
                              return GestureDetector(
                                onTap: widget.onEdit,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppColors.textExtraLight,
                                          width: 2,
                                          style: BorderStyle.none)),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(AppIcons.add,
                                            color: AppColors.textExtraLight,
                                            size: 32),
                                        Text('ADD',
                                            style: AppTextStyles.label.copyWith(
                                                fontSize: 8,
                                                color: AppColors.textExtraLight,
                                                letterSpacing: 1.5)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            final item = allMedia[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                    image: NetworkImage(item['url'] as String),
                                    fit: BoxFit.cover),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 5)
                                ],
                              ),
                              child: item['isHidden'] == true
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Center(
                                          child: Icon(AppIcons.lock,
                                              color: Colors.white, size: 20)))
                                  : null,
                            );
                          },
                          childCount: allMedia.length + 1,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final reviews = user.reviews ?? [];
                            if (reviews.isEmpty) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 48),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Column(
                                  children: [
                                    const Text('⭐',
                                        style: TextStyle(fontSize: 32)),
                                    const SizedBox(height: 12),
                                    Text('No Reviews Yet',
                                        style: AppTextStyles.h4.copyWith(
                                            color: AppColors.textMain)),
                                    Text('Feedback will appear here.',
                                        style: AppTextStyles.label.copyWith(
                                            fontSize: 10,
                                            color: AppColors.textMuted)),
                                  ],
                                ),
                              );
                            }
                            final r = reviews[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: AppColors.border)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(r.reviewerName,
                                          style: AppTextStyles.h4.copyWith(
                                              color: AppColors.textMain)),
                                      Row(
                                          children: List.generate(
                                              5,
                                              (i) => Icon(AppIcons.star,
                                                  size: 14,
                                                  color: i < r.rating
                                                      ? Colors.amber
                                                      : const Color(
                                                          0xFFF1F5F9)))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('"${r.comment}"',
                                      style: AppTextStyles.body.copyWith(
                                          fontSize: 12,
                                          color: AppColors.textLight,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            );
                          },
                          childCount: (user.reviews ?? []).isEmpty
                              ? 1
                              : (user.reviews?.length ?? 0),
                        ),
                      ),
              ),
            ],
          ),

          // Drawer / Modals would go here (Menu, Privacy)
          if (_isMenuOpen) _buildMenuDrawer(user, userProvider),
          if (_showPrivacyModal)
            _buildPrivacyModal(user, userProvider, connections),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label, {bool isPrimary = false}) {
    return Column(
      children: [
        Text(val,
            style: AppTextStyles.h2.copyWith(
                fontSize: 20,
                color: isPrimary ? AppColors.primary : AppColors.textMain)),
        Text(label.toUpperCase(),
            style: AppTextStyles.label.copyWith(
                fontSize: 8, color: AppColors.textMuted, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildTabButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: active ? AppColors.textMain : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: active
                  ? const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ]
                  : null),
          child: Text(label.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: active ? Colors.white : AppColors.textMuted,
                  letterSpacing: 1.5)),
        ),
      ),
    );
  }

  Widget _buildMenuDrawer(UserProfile user, UserProvider provider) {
    return Stack(
      children: [
        GestureDetector(
            onTap: () => setState(() => _isMenuOpen = false),
            child: Container(color: Colors.black45)),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
            child: Column(
              children: [
                _buildMenuItem(AppIcons.logout, 'Log Out',
                    color: Colors.red, onTap: widget.onLogout),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Menu',
                              style: AppTextStyles.h1
                                  .copyWith(fontSize: 32, letterSpacing: -1.0)),
                          Text('SETTINGS & PREFERENCES',
                              style: AppTextStyles.label.copyWith(
                                  fontSize: 9,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1.5)),
                        ]),
                    IconButton(
                        onPressed: () => setState(() => _isMenuOpen = false),
                        icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.border,
                                shape: BoxShape.circle),
                            child: const Icon(AppIcons.close, size: 20))),
                  ],
                ),
                const SizedBox(height: 48),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMenuSection('ACCOUNT ACTIONS', [
                          _buildMenuItem(AppIcons.lock, 'Secure Vault',
                              onTap: widget.onOpenWallet),
                          _buildMenuItem(AppIcons.premium, 'Upgrade to Gold',
                              isProminent: true, onTap: widget.onUpgrade),
                        ]),
                        _buildMenuSection('DISCOVERY', [
                          _buildSwitchItem(
                              AppIcons.visibility,
                              'Profile Visibility',
                              user.lookingForDates,
                              (v) => provider.updateUser(
                                  user.copyWith(lookingForDates: v))),
                        ]),
                        _buildMenuSection('SECURITY', [
                          _buildSwitchItem(
                              AppIcons.notifications,
                              'Mute Notifications',
                              user.notificationsMuted,
                              (v) => provider.updateUser(
                                  user.copyWith(notificationsMuted: v))),
                          _buildSwitchItem(
                              AppIcons.lock,
                              'Security Alerts',
                              user.notificationsEnabled,
                              (v) => provider.updateUser(
                                  user.copyWith(notificationsEnabled: v))),
                          _buildMenuItem(AppIcons.privacy, 'Status Privacy',
                              onTap: () {
                            setState(() {
                              _isMenuOpen = false;
                              _showPrivacyModal = true;
                            });
                          }),
                          _buildMenuItem(AppIcons.help, 'Help & Support',
                              onTap: widget.onOpenSupport),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String label, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.label.copyWith(
                fontSize: 9,
                color: AppColors.textExtraLight,
                letterSpacing: 2.0)),
        const SizedBox(height: 16),
        ...items,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label,
      {bool isProminent = false, Color? color, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isProminent ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            gradient: isProminent
                ? const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFBE123C)])
                : null,
          ),
          child: Row(
            children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: isProminent ? Colors.white24 : Colors.white,
                      shape: BoxShape.circle),
                  child: Icon(icon,
                      size: 16,
                      color: isProminent
                          ? Colors.white
                          : (color ?? AppColors.textMain))),
              const SizedBox(width: 16),
              Text(label,
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isProminent
                          ? Colors.white
                          : (color ?? AppColors.textMain))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
      IconData icon, String label, bool value, Function(bool) onChanged,
      {Color activeColor = AppColors.primary}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: AppColors.textMain)),
            const SizedBox(width: 16),
            Expanded(
                child: Text(label,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain))),
            Switch(
                value: value, onChanged: onChanged, activeColor: activeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyModal(
      UserProfile user, UserProvider provider, List<UserProfile> friends) {
    return Stack(
      children: [
        GestureDetector(
            onTap: () => setState(() => _showPrivacyModal = false),
            child: Container(color: Colors.black45)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50))),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status Privacy',
                        style: AppTextStyles.h1
                            .copyWith(fontSize: 24, letterSpacing: -1.0)),
                    IconButton(
                        onPressed: () =>
                            setState(() => _showPrivacyModal = false),
                        icon: const Icon(AppIcons.close)),
                  ],
                ),
                const SizedBox(height: 24),
                // Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      _buildPrivacyTab('Hide From', _privacyTab == 'hide',
                          () => setState(() => _privacyTab = 'hide')),
                      _buildPrivacyTab('Show Only To', _privacyTab == 'share',
                          () => setState(() => _privacyTab = 'share')),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Expanded(
                  child: ListView.separated(
                    itemCount: friends.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final isSelected = _privacyTab == 'hide'
                          ? (user.statusPrivacy?.hideFrom ?? [])
                              .contains(friend.id)
                          : (user.statusPrivacy?.showOnlyTo ?? [])
                              .contains(friend.id);

                      return GestureDetector(
                        onTap: () {
                          final current = user.statusPrivacy ??
                              StatusPrivacy(hideFrom: [], showOnlyTo: []);
                          List<String> hide = List.from(current.hideFrom);
                          List<String> showOnly = List.from(current.showOnlyTo);

                          if (_privacyTab == 'hide') {
                            if (hide.contains(friend.id))
                              hide.remove(friend.id);
                            else
                              hide.add(friend.id);
                            showOnly.remove(friend.id);
                          } else {
                            if (showOnly.contains(friend.id))
                              showOnly.remove(friend.id);
                            else
                              showOnly.add(friend.id);
                            hide.remove(friend.id);
                          }
                          provider.updateUser(user.copyWith(
                              statusPrivacy: StatusPrivacy(
                                  hideFrom: hide, showOnlyTo: showOnly)));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (_privacyTab == 'hide'
                                    ? Colors.red.withOpacity(0.05)
                                    : AppColors.success.withOpacity(0.05))
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected
                                    ? (_privacyTab == 'hide'
                                        ? Colors.red.withOpacity(0.1)
                                        : AppColors.success.withOpacity(0.1))
                                    : Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(friend.photos[0],
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(friend.name,
                                        style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.bold)),
                                    Text(friend.location,
                                        style: AppTextStyles.label.copyWith(
                                            fontSize: 10,
                                            color: AppColors.textMuted)),
                                  ])),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                    color: isSelected
                                        ? (_privacyTab == 'hide'
                                            ? Colors.red
                                            : Colors.teal)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : AppColors.textExtraLight)),
                                child: isSelected
                                    ? const Icon(AppIcons.check,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: active
                  ? const [BoxShadow(color: Colors.black12, blurRadius: 10)]
                  : null),
          child: Text(label.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                  fontSize: 9,
                  color: active
                      ? (_privacyTab == 'hide' ? Colors.red : AppColors.success)
                      : AppColors.textMuted,
                  letterSpacing: 1.5)),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(
      {required this.minHeight, required this.maxHeight, required this.child});
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
