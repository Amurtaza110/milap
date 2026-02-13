import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/mock_data_service.dart';
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
  bool _isSelectionMode = false;
  List<String> _selectedIds = [];

  List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'match',
      'title': 'Soul Match Request',
      'message': 'Ayesha Khan wants to connect with you.',
      'timestamp': DateTime.now()
          .subtract(const Duration(minutes: 30))
          .millisecondsSinceEpoch,
      'isRead': false,
      'senderPhoto': 'https://picsum.photos/id/64/100/100',
      'senderId': '1'
    },
    {
      'id': '2',
      'type': 'system',
      'title': 'Milap Protocol',
      'message': 'Your profile is now verified. Trust level increased.',
      'timestamp': DateTime.now()
          .subtract(const Duration(hours: 2))
          .millisecondsSinceEpoch,
      'isRead': true
    },
    {
      'id': '3',
      'type': 'review',
      'title': 'New Review',
      'message': 'Zain Ahmed left a 5-star review on your profile.',
      'timestamp': DateTime.now()
          .subtract(const Duration(days: 1))
          .millisecondsSinceEpoch,
      'isRead': true,
      'senderPhoto': 'https://picsum.photos/id/177/100/100',
      'senderId': '2'
    },
    {
      'id': '4',
      'type': 'match',
      'title': 'Soul Match Request',
      'message': 'Hamza Malik sent you a connection offer.',
      'timestamp': DateTime.now()
          .subtract(const Duration(hours: 36))
          .millisecondsSinceEpoch,
      'isRead': false,
      'senderPhoto': 'https://picsum.photos/id/91/100/100',
      'senderId': '3'
    },
    {
      'id': '5',
      'type': 'like',
      'title': 'Someone Liked You',
      'message':
          'A mysterious soul has liked your profile. Upgrade to Gold to see!',
      'timestamp': DateTime.now()
          .subtract(const Duration(days: 2))
          .millisecondsSinceEpoch,
      'isRead': true
    }
  ];

  void _handleMatchAction(String id, bool accept, String senderName) {
    setState(() => _notifications.removeWhere((n) => n['id'] == id));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(accept
            ? 'You accepted $senderName\'s request.'
            : 'Request rejected.')));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _activeTab == 'all'
        ? _notifications
        : _notifications.where((n) => n['type'] == 'match').toList();
    final newCount = _notifications.where((n) => n['isRead'] == false).length;

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
                    Row(
                      children: [
                        if (_isSelectionMode)
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _notifications.removeWhere(
                                      (n) => _selectedIds.contains(n['id']));
                                  _selectedIds.clear();
                                  _isSelectionMode = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: Text('DELETE (${_selectedIds.length})',
                                  style: AppTextStyles.label
                                      .copyWith(color: Colors.white))),
                        if (!_isSelectionMode) ...[
                          IconButton(
                              onPressed: () =>
                                  setState(() => _isSelectionMode = true),
                              icon: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: AppColors.background,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.check_box_rounded,
                                      size: 18,
                                      color: AppColors.textExtraLight))),
                          IconButton(
                              onPressed: () =>
                                  setState(() => _notifications.clear()),
                              icon: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: AppColors.background,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.delete_sweep_rounded,
                                      size: 18, color: AppColors.error))),
                        ],
                        if (_isSelectionMode)
                          IconButton(
                              onPressed: () => setState(() {
                                    _isSelectionMode = false;
                                    _selectedIds.clear();
                                  }),
                              icon: const Icon(Icons.close)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('Notifications',
                        style: AppTextStyles.h1
                            .copyWith(color: AppColors.textMain)),
                    const SizedBox(width: 8),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('$newCount NEW',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.primary, letterSpacing: 1.0))),
                  ],
                ),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final n = filtered[index];
                final isSelected = _selectedIds.contains(n['id']);
                return GestureDetector(
                  onTap: () {
                    if (_isSelectionMode) {
                      setState(() {
                        if (isSelected)
                          _selectedIds.remove(n['id']);
                        else
                          _selectedIds.add(n['id']);
                      });
                    } else if (n['senderId'] != null &&
                        widget.onViewProfile != null) {
                      final profile = MockDataService.mockProfiles
                          .firstWhere((p) => p.id == n['senderId']);
                      widget.onViewProfile!(profile);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.info.withOpacity(0.3)
                                : (n['isRead']
                                    ? Colors.transparent
                                    : AppColors.primary.withOpacity(0.2))),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]),
                    child: Stack(
                      children: [
                        if (!n['isRead'] && !_isSelectionMode)
                          Positioned(
                              left: -20,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                  width: 4, color: AppColors.primary)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAvatar(n),
                            const SizedBox(width: 16),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(n['title'],
                                            style: AppTextStyles.h4.copyWith(
                                                color: AppColors.textMain,
                                                fontSize: 14)),
                                        Text(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    n['timestamp'])
                                                .toString()
                                                .substring(11, 16),
                                            style: AppTextStyles.label.copyWith(
                                                fontSize: 9,
                                                color:
                                                    AppColors.textExtraLight))
                                      ]),
                                  const SizedBox(height: 4),
                                  Text(n['message'],
                                      style: AppTextStyles.body.copyWith(
                                          fontSize: 12,
                                          color: AppColors.textLight,
                                          height: 1.4)),
                                  if (n['type'] == 'match' &&
                                      !_isSelectionMode) ...[
                                    const SizedBox(height: 16),
                                    Row(children: [
                                      Expanded(
                                          child: ElevatedButton(
                                              onPressed: () =>
                                                  _handleMatchAction(
                                                      n['id'],
                                                      true,
                                                      n['title'].split(' ')[0]),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 8)),
                                              child: Text('ACCEPT',
                                                  style: AppTextStyles.label
                                                      .copyWith(
                                                          color: Colors.white)))),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: ElevatedButton(
                                              onPressed: () =>
                                                  _handleMatchAction(
                                                      n['id'],
                                                      false,
                                                      n['title'].split(' ')[0]),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.background,
                                                  foregroundColor:
                                                      AppColors.textLight,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 8)),
                                              child: Text('REJECT',
                                                  style: AppTextStyles.label
                                                      .copyWith(
                                                          color: AppColors.textLight)))),
                                    ]),
                                  ],
                                ])),
                          ],
                        ),
                        if (_isSelectionMode)
                          Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.info
                                          : AppColors.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : AppColors.textExtraLight)),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          size: 12, color: Colors.white)
                                      : null)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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

  Widget _buildAvatar(Map<String, dynamic> n) {
    if (n['senderPhoto'] != null) {
      return Stack(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(n['senderPhoto'],
                  width: 56, height: 56, fit: BoxFit.cover)),
          if (n['type'] == 'match')
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                    child:
                        Icon(AppIcons.priority, size: 8, color: Colors.white))),
        ],
      );
    }
    return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16)),
        child: Center(
            child: Text(n['type'] == 'system' ? '🛡️' : '🔔',
                style: const TextStyle(fontSize: 24))));
  }
}
