import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_screen.dart';
import '../../providers/user_provider.dart';
import '../../widgets/navigation.dart' as Nav;
import 'dashboard.dart';
import '../messages/messages_screen.dart';
import '../milap_plus/room/chat_room.dart';
import '../profile/profile_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../milap_plus/hookup_mode_screen.dart';
import '../wallet/heart_store_screen.dart';
import 'notification_screen.dart';
import '../onboarding/splash_screen.dart';
import '../auth/login_screen.dart';
import '../auth/otp_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../profile/public_profile_view.dart';
import '../wallet/wallet_screen.dart';
import 'support_screen.dart';
import '../milap_plus/upgrade_gold_screen.dart';
import 'status_upload_screen.dart';
import '../profile/sent_requests_screen.dart';
import '../auth/pin_lock_screen.dart';
import '../milap_plus/room/rooms_screen.dart';
import '../milap_plus/room/create_room_screen.dart';
import '../milap_plus/room/active_room_screen.dart';
import '../events/event_screen.dart';
import '../events/event_details_screen.dart';
import '../events/create_event_screen.dart';
import '../events/event_booking_screen.dart';
import '../events/my_events_screen.dart';
import '../events/tickets_screen.dart';
import '../events/event_ticket_management_screen.dart';
import '../../services/screenshot_detection_service.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  AppScreen _currentScreen = AppScreen.SPLASH;
  String _phoneNumber = '';
  dynamic _activeChat; // Replace with Chat model when ready
  dynamic _viewingProfile;
  dynamic _activeEvent;
  dynamic _activeRoom;
  StreamSubscription<ScreenshotEvent>? _screenshotSubscription;

  @override
  void initState() {
    super.initState();
    _startSplashScreenTimer();
    _initScreenshotMonitoring();
  }

  void _startSplashScreenTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        _handleAuthState(userProvider);
      }
    });
  }

  void _handleAuthState(UserProvider userProvider) {
    if (userProvider.isAuthenticated) {
      if (userProvider.user?.name.isEmpty ?? true) {
        setState(() => _currentScreen = AppScreen.ONBOARDING);
      } else if (userProvider.user?.appPin != null &&
          _currentScreen != AppScreen.PIN_LOCK) {
        setState(() => _currentScreen = AppScreen.PIN_LOCK);
      } else {
        setState(() => _currentScreen = AppScreen.DASHBOARD);
      }
    } else {
      // If we are already in LOGIN or OTP, don't force reset unless we were just DASHBOARD
      if (_currentScreen != AppScreen.LOGIN &&
          _currentScreen != AppScreen.OTP &&
          _currentScreen != AppScreen.SPLASH) {
        setState(() => _currentScreen = AppScreen.LOGIN);
      }
    }
  }

  void _initScreenshotMonitoring() {
    final detectionService = ScreenshotDetectionService();
    detectionService.startMonitoring();
    _screenshotSubscription =
        detectionService.screenshotStream.listen(_handleScreenshotEvent);
  }

  Future<void> _handleScreenshotEvent(ScreenshotEvent event) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    final detectionService = ScreenshotDetectionService();

    // Only track warnings for the screenshot taker
    if (event.userId == user.id) {
      final warnings = detectionService.getWarningCount(user.id);
      final exceeded = detectionService.hasExceededScreenshotLimit(user.id);

      int? suspendedUntil = user.suspendedUntil;
      if (exceeded && suspendedUntil == null) {
        suspendedUntil =
            DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch;
      }

      userProvider.updateUser(user.copyWith(
        screenshotWarnings: warnings,
        suspendedUntil: suspendedUntil,
      ));

      await detectionService.notifyBothUsers(
        event.userId,
        event.otherUserId,
        'Screenshot detected in a secure area. Repeated breaches may suspend your account.',
      );
    }
  }

  @override
  void dispose() {
    _screenshotSubscription?.cancel();
    super.dispose();
  }

  void _navigateTo(AppScreen screen) {
    setState(() => _currentScreen = screen);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    Widget screenWidget;
    bool showBottomNav = [
      AppScreen.DASHBOARD,
      AppScreen.MESSAGES,
      AppScreen.PROFILE,
      AppScreen.HOOKUP_MODE,
      AppScreen.EVENTS
    ].contains(_currentScreen);

    switch (_currentScreen) {
      case AppScreen.SPLASH:
        screenWidget = const SplashScreen();
        break;
      case AppScreen.LOGIN:
        screenWidget = LoginScreen(onLogin: (phone) {
          setState(() {
            _phoneNumber = phone;
            _currentScreen = AppScreen.OTP;
          });
        });
        break;
      case AppScreen.OTP:
        screenWidget = OTPScreen(
          phoneNumber: _phoneNumber,
          onVerify: (success) {
            if (success) {
              // Auth listener in UserProvider will trigger state change,
              // but we can proactively move to DASHBOARD/ONBOARDING
              _navigateTo(AppScreen.ONBOARDING);
            }
          },
          onBack: () => _navigateTo(AppScreen.LOGIN),
        );
        break;
      case AppScreen.ONBOARDING:
        screenWidget = OnboardingScreen(
          phoneNumber: _phoneNumber,
          onComplete: (u) {
            userProvider.setCurrentUser(u);
            _navigateTo(AppScreen.DASHBOARD);
          },
        );
        break;
      case AppScreen.DASHBOARD:
        screenWidget = Dashboard(
          onNavigate: _navigateTo,
        );
        break;
      case AppScreen.MESSAGES:
        screenWidget = MessagesScreen(
          onNavigate: _navigateTo,
          onSelectChat: (chat) {
            setState(() {
              _activeChat = chat;
              _currentScreen = AppScreen.CHAT_ROOM;
            });
          },
        );
        break;
      case AppScreen.CHAT_ROOM:
        screenWidget = ChatRoom(
          chat: _activeChat,
          onBack: () => _navigateTo(AppScreen.MESSAGES),
          onOpenSharedVault: (id) => _navigateTo(AppScreen.PRIVATE_WALLET),
          onBlockUser: (id) {
            if (user != null) {
              userProvider.updateUser(user.copyWith(
                  blockedUserIds: [...(user.blockedUserIds ?? []), id]));
              _navigateTo(AppScreen.MESSAGES);
            }
          },
          onViewProfile: () {
            setState(() {
              _viewingProfile = _activeChat?.participants[0];
              _currentScreen = AppScreen.PUBLIC_PROFILE_VIEW;
            });
          },
        );
        break;
      case AppScreen.PROFILE:
        screenWidget = ProfileScreen(
          onLogout: () {
            userProvider.setCurrentUser(null);
            _navigateTo(AppScreen.LOGIN);
          },
          onEdit: () => _navigateTo(AppScreen.EDIT_PROFILE),
          onUpgrade: () => _navigateTo(AppScreen.UPGRADE_GOLD),
          onOpenWallet: () => _navigateTo(AppScreen.PRIVATE_WALLET),
          onOpenSupport: () => _navigateTo(AppScreen.SUPPORT),
          onViewSentRequests: () => _navigateTo(AppScreen.SENT_REQUESTS),
          onNavigate: (s) => _navigateTo(s),
        );
        break;
      case AppScreen.EDIT_PROFILE:
        screenWidget = EditProfileScreen(
          user: user!,
          onSave: (u) {
            userProvider.updateUser(u);
            _navigateTo(AppScreen.PROFILE);
          },
          onBack: () => _navigateTo(AppScreen.PROFILE),
        );
        break;
      case AppScreen.HOOKUP_MODE:
        screenWidget = HookupModeScreen(
          onBack: () => _navigateTo(AppScreen.DASHBOARD),
          onToggleHookup: (active, intent) {
            userProvider.updateUser(
                user!.copyWith(hookupActive: active, hookupIntent: intent));
          },
          onCreateEvent: () => _navigateTo(AppScreen.CREATE_EVENT),
          onManageEvents: () => _navigateTo(AppScreen.MY_EVENTS),
          onNavigate: (s) => _navigateTo(s),
        );
        break;
      case AppScreen.HEART_STORE:
        screenWidget = HeartStoreScreen(
          onBack: () => _navigateTo(AppScreen.DASHBOARD),
          onUpgradeToGold: () => _navigateTo(AppScreen.UPGRADE_GOLD),
        );
        break;
      case AppScreen.NOTIFICATIONS:
        screenWidget = NotificationScreen(
          onBack: () => _navigateTo(AppScreen.DASHBOARD),
          onViewProfile: (p) {
            setState(() {
              _viewingProfile = p;
              _currentScreen = AppScreen.PUBLIC_PROFILE_VIEW;
            });
          },
        );
        break;
      case AppScreen.EVENTS:
        screenWidget = EventScreen(
          user: user!,
          onEventClick: (e) {
            setState(() {
              _activeEvent = e;
              _currentScreen = AppScreen.EVENT_DETAILS;
            });
          },
          onCreateEvent: () => _navigateTo(AppScreen.CREATE_EVENT),
          onBack: () => _navigateTo(AppScreen.DASHBOARD),
          onViewTickets: () => _navigateTo(AppScreen.MY_TICKETS),
        );
        break;
      case AppScreen.EVENT_DETAILS:
        screenWidget = EventDetailsScreen(
          event: _activeEvent,
          user: user!,
          onBack: () => _navigateTo(AppScreen.EVENTS),
          onUpgrade: () => _navigateTo(AppScreen.UPGRADE_GOLD),
          onBook: () => _navigateTo(AppScreen.EVENT_BOOKING),
        );
        break;
      case AppScreen.EVENT_BOOKING:
        screenWidget = EventBookingScreen(
          event: _activeEvent,
          user: user!,
          onBack: () => _navigateTo(AppScreen.EVENT_DETAILS),
          onSuccess: () => _navigateTo(AppScreen.MY_TICKETS),
        );
        break;
      case AppScreen.CREATE_EVENT:
        screenWidget = CreateEventScreen(
          onBack: () => _navigateTo(AppScreen.HOOKUP_MODE),
          onSave: (data) => _navigateTo(AppScreen.MY_EVENTS),
        );
        break;
      case AppScreen.MY_EVENTS:
        screenWidget = MyEventsScreen(
          onBack: () => _navigateTo(AppScreen.HOOKUP_MODE),
          onEditEvent: (e) {
            setState(() {
              _activeEvent = e;
              _currentScreen = AppScreen.CREATE_EVENT;
            });
          },
          onManageTickets: (e) {
            setState(() {
              _activeEvent = e;
              _currentScreen = AppScreen.EVENT_TICKET_MANAGEMENT;
            });
          },
        );
        break;
      case AppScreen.EVENT_TICKET_MANAGEMENT:
        screenWidget = EventTicketManagementScreen(
          event: _activeEvent,
          onBack: () => _navigateTo(AppScreen.MY_EVENTS),
        );
        break;
      case AppScreen.MY_TICKETS:
        screenWidget = TicketsScreen(
          onBack: () => _navigateTo(AppScreen.PROFILE),
        );
        break;
      case AppScreen.PRIVATE_WALLET:
        screenWidget = WalletScreen(
          user: user!,
          onUpdateUser: (u) => userProvider.updateUser(u),
          onBack: () => _navigateTo(AppScreen.PROFILE),
        );
        break;
      case AppScreen.SUPPORT:
        screenWidget = SupportScreen(
          user: user!,
          onBack: () => _navigateTo(AppScreen.PROFILE),
        );
        break;
      case AppScreen.UPGRADE_GOLD:
        screenWidget = UpgradeGoldScreen(
          onBack: () => _navigateTo(AppScreen.DASHBOARD),
          onUpgrade: () {
            userProvider.updateUser(user!.copyWith(isMilapGold: true));
            _navigateTo(AppScreen.PROFILE);
          },
        );
        break;
      case AppScreen.PUBLIC_PROFILE_VIEW:
        screenWidget = PublicProfileView(
          profile: _viewingProfile,
          onBack: () => _navigateTo(AppScreen.DASHBOARD),
          onUpgrade: () => _navigateTo(AppScreen.UPGRADE_GOLD),
          onConnect: () {
            // Logic for connecting
          },
        );
        break;
      case AppScreen.SENT_REQUESTS:
        screenWidget = SentRequestsScreen(
          onBack: () => _navigateTo(AppScreen.PROFILE),
        );
        break;
      case AppScreen.STATUS_UPLOAD:
        screenWidget = StatusUploadScreen(
          onBack: () => _navigateTo(AppScreen.DASHBOARD),
          onUpload: (f, c, t) => _navigateTo(AppScreen.DASHBOARD),
        );
        break;
      case AppScreen.ROOMS:
        screenWidget = RoomsScreen(
          onJoinRoom: (roomId, room) {
            setState(() {
              _activeRoom = room;
              _currentScreen = AppScreen.ACTIVE_ROOM;
            });
          },
          onCreateRoom: () => _navigateTo(AppScreen.CREATE_ROOM),
          onBack: () => _navigateTo(AppScreen.DASHBOARD),
        );
        break;
      case AppScreen.CREATE_ROOM:
        screenWidget = CreateRoomScreen(
          onBack: () => _navigateTo(AppScreen.ROOMS),
          onCreate: (room) {
            setState(() {
              _activeRoom = room;
              _currentScreen = AppScreen.ACTIVE_ROOM;
            });
          },
        );
        break;
      case AppScreen.ACTIVE_ROOM:
        screenWidget = ActiveRoomScreen(
          room: _activeRoom,
          onLeave: () => _navigateTo(AppScreen.ROOMS),
        );
        break;
      case AppScreen.PIN_LOCK:
        screenWidget = PinLockScreen(
          user: user!,
          onVerify: () => _navigateTo(AppScreen.DASHBOARD),
          onUpdateUser: (u) => userProvider.updateUser(u),
        );
        break;
      case AppScreen.CHANGE_PIN:
        screenWidget = PinLockScreen(
          user: user!,
          mode: 'change',
          onVerify: () => _navigateTo(AppScreen.PROFILE),
          onUpdateUser: (u) => userProvider.updateUser(u),
          onCancelChange: () => _navigateTo(AppScreen.PROFILE),
        );
        break;
      default:
        screenWidget = const SplashScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: screenWidget),
          if (showBottomNav)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Nav.Navigation(
                activeScreen: _currentScreen,
                onNavigate: _navigateTo,
              ),
            ),
        ],
      ),
    );
  }
}
