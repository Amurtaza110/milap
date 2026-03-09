import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../models/status.dart';
import '../../models/app_screen.dart';
import '../../providers/user_provider.dart';
import '../../services/user_service.dart';
import '../../services/status_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/status_story_rail.dart';
import '../../widgets/status_viewer.dart';
import '../../widgets/swipe_card.dart';
import '../profile/public_profile_view.dart';
import 'dart:async';

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
  bool _isInitialLoading = true;
  StreamSubscription? _statusSubscription;

  final UserService _userService = UserService();
  final StatusService _statusService = StatusService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _subscribeToStatuses();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToStatuses() {
    _statusSubscription = _statusService.streamFreshStatuses().listen((freshStatuses) {
      if (mounted) {
        setState(() {
          _statuses = freshStatuses;
        });
      }
    });
  }

  Future<void> _loadInitialData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // If user is already loaded, fetch profiles immediately
    if (userProvider.user != null) {
      await _fetchProfiles(userProvider.user!);
    } else {
      // Otherwise, wait for the first valid user emission
      late VoidCallback listener;
      listener = () {
        if (userProvider.user != null) {
          _fetchProfiles(userProvider.user!);
          userProvider.removeListener(listener);
        }
      };
      userProvider.addListener(listener);
    }
  }

  Future<void> _fetchProfiles(UserProfile user) async {
    final profiles = await _userService.getSocialFeed(
      preferredCity: user.location,
      excludeUid: user.id,
    );

    if (mounted) {
      setState(() {
        _profiles = profiles
            .where((p) => !(user.blockedUserIds ?? []).contains(p.id))
            .toList();
        _isInitialLoading = false;
      });
    }
  }

  void _handleAction(String action) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null || _currentIndex >= _profiles.length) return;

    final targetProfile = _profiles[_currentIndex];

    if (action == 'match') {
      final success = await userProvider.sendMatchRequest(targetProfile);
      if (!success && !user.isMilapGold && user.heartsBalance <= 0) {
        _showOutofHeartsDialog();
        return;
      }
    }

    setState(() => _currentIndex++);
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PublicProfileView(
          profile: profile,
          onBack: () => Navigator.pop(context),
          onConnect: () {
            Navigator.pop(context);
            _handleAction('match');
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

    if (user == null || _isInitialLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                child: RefreshIndicator(
                  onRefresh: () => _fetchProfiles(user),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
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
                              _fetchProfiles(user);
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
              ),
            ],
          ),
          if (_viewingStatus != null)
            StatusViewOverlay(
              status: _viewingStatus!,
              onClose: () => setState(() => _viewingStatus = null),
              isOwner: _viewingStatus!.userId == user.id,
              onDelete: (id) {
                _statusService.deleteStatus(id);
                setState(() => _viewingStatus = null);
              },
            ),
        ],
      ),
    );
  }
}
