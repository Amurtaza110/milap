import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat.dart';
import '../../models/status.dart';
import '../../models/app_screen.dart';
import '../../providers/user_provider.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/status_story_rail.dart';
import '../../widgets/status_viewer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_icons.dart';

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
  List<Chat> _chats = [];
  List<Status> _statuses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final freshStatuses = MockDataService.mockStatuses
          .where((s) => now - s.timestamp <= 24 * 60 * 60 * 1000)
          .toList();

      setState(() {
        _chats = MockDataService.mockChats.where((chat) {
          return !chat.participants
              .any((p) => (user.blockedUserIds ?? []).contains(p.id));
        }).toList();
        _statuses = freshStatuses;
      });
    }
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
                    // Status Rail
                    StatusStoryRail(
                      user: user,
                      statuses: _statuses,
                      onOpenStatus: (s) => setState(() => _selectedStatus = s),
                      showMyStatus: true,
                    ),
                    const SizedBox(height: 24),
                    // Search
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
                    const SizedBox(height: 16),
                    // Archived Chats Option
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Opening Archived Chats... (Mock)')));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            const Icon(Icons.archive_outlined,
                                color: AppColors.textLight, size: 20),
                            const SizedBox(width: 16),
                            Text('Archived',
                                style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMain)),
                            const Spacer(),
                            Text('2',
                                style: AppTextStyles.label
                                    .copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat List
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    final participant = chat.participants[0];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: Key(chat.id),
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(Icons.archive_rounded,
                              color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            _chats.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    direction == DismissDirection.startToEnd
                                        ? 'Chat archived'
                                        : 'Chat deleted')),
                          );
                        },
                        child: InkWell(
                          onTap: () => widget.onSelectChat(chat),
                          onLongPress: () => _showChatActions(chat),
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
                                                participant.photos[0]),
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
                                          Text('12:45 PM',
                                              style: AppTextStyles.label
                                                  .copyWith(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors
                                                          .textExtraLight)),
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Status View Overlay
          if (_selectedStatus != null)
            StatusViewOverlay(
              status: _selectedStatus!,
              onClose: () => setState(() => _selectedStatus = null),
              isOwner: _selectedStatus!.userId == user.id,
              onDelete: (id) {
                setState(() {
                  _statuses.removeWhere((s) => s.id == id);
                  _selectedStatus = null;
                });
              },
            ),
        ],
      ),
    );
  }

  void _showChatActions(Chat chat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive chat'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat archived (mock only).'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete chat'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _chats.removeWhere((c) => c.id == chat.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
