import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat.dart';
import '../../models/status.dart';
import '../../models/app_screen.dart';
import '../../providers/user_provider.dart';
import '../../services/chat_service.dart';
import '../../services/status_service.dart';
import '../../widgets/status_story_rail.dart';
import '../../widgets/status_viewer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_icons.dart';
import 'dart:async';

class MessagesScreen extends StatefulWidget {
  final Function(Chat) onSelectChat;
  final Function(AppScreen) onNavigate;

  const MessagesScreen({
    Key? key,
    required this.onSelectChat,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  Status? _selectedStatus;
  List<Status> _statuses = [];
  StreamSubscription? _statusSubscription;
  final ChatService _chatService = ChatService();
  final StatusService _statusService = StatusService();

  @override
  void initState() {
    super.initState();
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

  void _toggleGlobalPrivacy() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      final newState = !(user.privacyGuardEnabled ?? false);
      userProvider.updateUser(user.copyWith(privacyGuardEnabled: newState));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(newState
            ? "Privacy Guard Enabled Globally."
            : "Privacy Guard Disabled."),
        backgroundColor: newState ? Colors.teal : Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 64, 32, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Inboxes',
                          style: AppTextStyles.h1
                              .copyWith(color: AppColors.textMain),
                        ),
                        IconButton(
                          onPressed: _toggleGlobalPrivacy,
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (user.privacyGuardEnabled ?? false)
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.security_rounded,
                              size: 20,
                              color: (user.privacyGuardEnabled ?? false)
                                  ? AppColors.success
                                  : AppColors.textExtraLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    StatusStoryRail(
                      user: user,
                      statuses: _statuses,
                      onOpenStatus: (s) => setState(() => _selectedStatus = s),
                      showMyStatus: true,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20)),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search soul connections...',
                          hintStyle: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                          icon: Icon(AppIcons.search,
                              color: AppColors.textExtraLight, size: 20),
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Real-Time Chat List from Firestore
              Expanded(
                child: StreamBuilder<List<Chat>>(
                  stream: _chatService.streamUserChats(user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final chats = snapshot.data ?? [];

                    if (chats.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No active soul connections.',
                                style: AppTextStyles.body.copyWith(color: AppColors.textExtraLight)),
                            const SizedBox(height: 16),
                            Text('Match with someone to start chatting!',
                                style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final participant = chat.participants[0];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => widget.onSelectChat(chat),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                                border: Border.all(
                                    color: AppColors.border.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 65,
                                        height: 65,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(24),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  participant.photos.isNotEmpty
                                                    ? participant.photos[0]
                                                    : 'https://i.pravatar.cc/150'),
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      if (participant.isOnline)
                                        Positioned(
                                          bottom: 2,
                                          right: 2,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                                color: const Color(0xFF10B981),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2.5)),
                                          ),
                                        ),
                                    ],
                                  ),
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
                                            Text(participant.name,
                                                style: AppTextStyles.h4.copyWith(
                                                    fontSize: 16,
                                                    color: AppColors.textMain)),
                                            if (chat.timestamp != 0)
                                              Text(
                                                DateTime.fromMillisecondsSinceEpoch(chat.timestamp)
                                                    .toString()
                                                    .substring(11, 16),
                                                style: AppTextStyles.label.copyWith(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textExtraLight),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                chat.lastMessage ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: chat.unreadCount > 0
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: chat.unreadCount > 0
                                                      ? AppColors.textMain
                                                      : AppColors.textLight,
                                                ),
                                              ),
                                            ),
                                            if (chat.unreadCount > 0)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 8),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text('${chat.unreadCount}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w900)),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          if (_selectedStatus != null)
            StatusViewOverlay(
              status: _selectedStatus!,
              onClose: () => setState(() => _selectedStatus = null),
              isOwner: _selectedStatus!.userId == user.id,
              onDelete: (id) {
                _statusService.deleteStatus(id);
                setState(() => _selectedStatus = null);
              },
            ),
        ],
      ),
    );
  }
}
