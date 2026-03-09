import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart' hide MatchRequest; // Hide to resolve naming conflict
import '../../models/notification.dart';
import '../../models/match_model.dart';
import '../../providers/user_provider.dart';
import '../../services/notification_service.dart';
import '../../services/match_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_icons.dart';

class NotificationScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(UserProfile)? onViewProfile;

  const NotificationScreen({
    Key? key,
    required this.onBack,
    this.onViewProfile,
  }) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _activeTab = 'all'; // 'all' | 'requests'
  final NotificationService _notificationService = NotificationService();
  final MatchService _matchService = MatchService();

  void _handleMatchAction(NotificationModel notification, bool accept) async {
    if (notification.senderId == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    if (currentUser == null) return;

    try {
      if (accept) {
        // Create the match request object to pass to service
        final requestId = '${notification.senderId}_${currentUser.id}';
        final request = MatchRequest(
          id: requestId,
          senderId: notification.senderId!,
          receiverId: currentUser.id,
          senderName: notification.title.replaceAll('Soul Match Request', '').trim(),
          senderPhoto: notification.senderPhoto ?? '',
          receiverName: currentUser.name,
          receiverPhoto: currentUser.photos.isNotEmpty ? currentUser.photos[0] : '',
          createdAt: DateTime.now(),
          status: MatchStatus.pending,
        );

        await _matchService.acceptMatchRequest(request);
        await _notificationService.markAsRead(notification.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Match Accepted! You can now chat in Messages.'),
            backgroundColor: Colors.green,
          ));
        }
      } else {
        final requestId = '${notification.senderId}_${currentUser.id}';
        await _matchService.rejectMatchRequest(requestId, notification.senderId!, currentUser.id);
        await _notificationService.deleteNotification(notification.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: widget.onBack,
                        icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(16)),
                            child: Icon(AppIcons.back,
                                size: 18, color: AppColors.textMain))),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Notifications',
                    style: AppTextStyles.h1.copyWith(color: AppColors.textMain)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildTabButton('All', _activeTab == 'all',
                        () => setState(() => _activeTab = 'all')),
                    const SizedBox(width: 24),
                    _buildTabButton('Requests', _activeTab == 'requests',
                        () => setState(() => _activeTab = 'requests')),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _notificationService.streamNotifications(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications = snapshot.data ?? [];
                final filtered = _activeTab == 'all'
                    ? notifications
                    : notifications.where((n) => n.type == NotificationType.match).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text('No notifications yet.',
                        style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final n = filtered[index];
                    return _buildNotificationCard(n);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: n.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(n),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(n.title,
                    style: AppTextStyles.h4.copyWith(
                        color: AppColors.textMain, fontSize: 14)),
                const SizedBox(height: 4),
                Text(n.message,
                    style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textLight,
                        height: 1.4)),
                if (n.type == NotificationType.match) ...[
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () => _handleMatchAction(n, true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            child: Text('ACCEPT',
                                style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 10)))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () => _handleMatchAction(n, false),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.background,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            child: Text('REJECT',
                                style: AppTextStyles.label.copyWith(color: AppColors.textLight, fontSize: 10)))),
                  ]),
                ],
              ])),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: active ? AppColors.primary : Colors.transparent,
                    width: 4))),
        child: Text(label.toUpperCase(),
            style: AppTextStyles.label.copyWith(
                color: active ? AppColors.textMain : AppColors.textExtraLight)),
      ),
    );
  }

  Widget _buildAvatar(NotificationModel n) {
    if (n.senderPhoto != null && n.senderPhoto!.isNotEmpty) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(n.senderPhoto!,
              width: 56, height: 56, fit: BoxFit.cover));
    }
    return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Icon(Icons.notifications_none_rounded, size: 24)));
  }
}
