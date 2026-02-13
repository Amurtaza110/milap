import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../models/status.dart';
import '../../models/app_screen.dart';
import '../../providers/user_provider.dart';
import '../../services/user_service.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/status_story_rail.dart';
import '../../widgets/status_viewer.dart';
import '../../widgets/swipe_card.dart';
import '../profile/public_profile_view.dart';

class Dashboard extends StatefulWidget {
  final Function(AppScreen) onNavigate;

  const Dashboard({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Status? _viewingStatus;
  int _currentIndex = 0;
  List<UserProfile> _profiles = [];
  List<Status> _statuses = [];

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user != null) {
      // Fetch statuses (still using mock for now until StatusService is built,
      // but filtering by fresh timestamps)
      final now = DateTime.now().millisecondsSinceEpoch;
      final freshStatuses = MockDataService.mockStatuses
          .where((s) => now - s.timestamp <= 24 * 60 * 60 * 1000)
          .toList();

      // Fetch real profiles from Firestore
      final profiles = await _userService.getSocialFeed();

      if (mounted) {
        setState(() {
          _profiles = profiles
              .where((p) =>
                  p.id != user.id &&
                  !p.isDeactivated &&
                  !(user.blockedUserIds ?? []).contains(p.id))
              .toList();
          _statuses = freshStatuses;
        });
      }
    }
  }

  void _handleAction(String action) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) return;

    if (user.isMilapGold) {
      setState(() => _currentIndex++);
    } else {
      if (user.heartsBalance > 0) {
        userProvider
            .updateUser(user.copyWith(heartsBalance: user.heartsBalance - 1));
        setState(() => _currentIndex++);
      } else {
        _showOutofHeartsDialog();
      }
    }
  }

  void _showOutofHeartsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Out of Hearts!'),
        content: const Text(
            'You need hearts to connect with more souls. Visit Heart Store?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onNavigate(AppScreen.HEART_STORE);
            },
            child: const Text('Visit Store'),
          ),
        ],
      ),
    );
  }

  void _navigateToPublicProfile(UserProfile profile) {
    // Pass the profile through widget callback which will set _viewingProfile in root_screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PublicProfileView(
          profile: profile,
          onBack: () => Navigator.pop(context),
          onConnect: () {
            Navigator.pop(context);
          },
          onUpgrade: () {
            Navigator.pop(context);
            widget.onNavigate(AppScreen.UPGRADE_GOLD);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) return const Center(child: CircularProgressIndicator());

    final currentProfile =
        _currentIndex < _profiles.length ? _profiles[_currentIndex] : null;
    Status? currentProfileStatus;
    bool hasVisibleStatus = false;
    if (currentProfile != null) {
      try {
        currentProfileStatus =
            _statuses.firstWhere((s) => s.userId == currentProfile.id);
      } catch (_) {}

      if (currentProfileStatus != null) {
        final privacy = currentProfile.statusPrivacy;
        final viewerId = user.id;
        final hideFrom = privacy?.hideFrom ?? [];
        final showOnlyTo = privacy?.showOnlyTo ?? [];

        final hiddenForViewer = hideFrom.contains(viewerId);
        final restrictedToSome =
            showOnlyTo.isNotEmpty && !showOnlyTo.contains(viewerId);

        hasVisibleStatus = !hiddenForViewer && !restrictedToSome;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              if (user.isDeactivated)
                Container(
                  width: double.infinity,
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'ACCOUNT IS CURRENTLY DEACTIVATED. TURN IT ON IN "ME" TO START CONNECTING.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(
                        color: Colors.white, fontSize: 8, letterSpacing: 2.0),
                  ),
                ),
              DashboardHeader(
                user: user,
                onOpenStore: () => widget.onNavigate(AppScreen.HEART_STORE),
                onOpenNotifications: () =>
                    widget.onNavigate(AppScreen.NOTIFICATIONS),
                onOpenSentRequests: () =>
                    widget.onNavigate(AppScreen.SENT_REQUESTS),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      // Status Rail
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: StatusStoryRail(
                          user: user,
                          statuses: _statuses,
                          onOpenStatus: (s) =>
                              setState(() => _viewingStatus = s),
                          onAddStatus: () =>
                              widget.onNavigate(AppScreen.STATUS_UPLOAD),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card Stack
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SwipeCard(
                          profile: currentProfile,
                          onAction: _handleAction,
                          onViewProfile: (p) {
                            _navigateToPublicProfile(p);
                          },
                          onBlockUser: (id) {
                            userProvider.updateUser(user.copyWith(
                                blockedUserIds: [
                                  ...(user.blockedUserIds ?? []),
                                  id
                                ]));
                            _loadData();
                          },
                          hasStatus:
                              currentProfileStatus != null && hasVisibleStatus,
                          onShowStatus: () => setState(
                              () => _viewingStatus = currentProfileStatus),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_viewingStatus != null)
            StatusViewOverlay(
              status: _viewingStatus!,
              onClose: () => setState(() => _viewingStatus = null),
              isOwner: _viewingStatus!.userId == user.id,
              onDelete: (id) {
                setState(() {
                  _statuses.removeWhere((s) => s.id == id);
                  _viewingStatus = null;
                });
              },
            ),
        ],
      ),
    );
  }
}
