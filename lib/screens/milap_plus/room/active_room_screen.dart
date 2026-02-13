import 'package:flutter/material.dart';
import 'package:milap/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../models/room.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

enum ActiveRoomMode { CHAT, LIVE }

class ActiveRoomScreen extends StatefulWidget {
  final Room room;
  final VoidCallback onLeave;

  const ActiveRoomScreen({
    Key? key,
    required this.room,
    required this.onLeave,
  }) : super(key: key);

  @override
  State<ActiveRoomScreen> createState() => _ActiveRoomScreenState();
}

class _ActiveRoomScreenState extends State<ActiveRoomScreen> {
  ActiveRoomMode _currentMode = ActiveRoomMode.CHAT;
  final TextEditingController _messageController = TextEditingController();
  bool _isAccepted = false; // Add pending status

  @override
  void initState() {
    super.initState();
    // Simulate auto-acceptance for host for testing, or keep false for demo
  }

  final List<Map<String, dynamic>> _mockMessages = [
    {
      'sender': 'Admin',
      'text': 'Welcome to the room! 🚀',
      'isMe': false,
      'time': '12:00 PM',
      'avatar': 'https://i.pravatar.cc/150?img=10'
    },
    {
      'sender': 'Me',
      'text': 'Thanks! Happy to be here.',
      'isMe': true,
      'time': '12:01 PM',
      'avatar': 'https://i.pravatar.cc/150?img=11'
    },
    {
      'sender': 'Sarah',
      'text': 'Is the live session starting soon?',
      'isMe': false,
      'time': '12:05 PM',
      'avatar': 'https://i.pravatar.cc/150?img=12'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;
    final isHost = user.id == widget.room.hostId;

    final primaryColor = AppColors.milapPlusPrimary;
    final backgroundColor = AppColors.milapPlusSecondary;
    final surfaceColor = AppColors.milapPlusSurface;
    final textColor = Colors.white;

    return Theme(
      data: AppTheme.milapPlusTheme,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(isHost, true, primaryColor, textColor),
        body: Stack(
          children: [
            Column(
              children: [
                _buildModeSwitcher(true, primaryColor, surfaceColor, textColor),
                Expanded(
                  child: _currentMode == ActiveRoomMode.CHAT
                      ? _buildChatUI(
                          true, primaryColor, surfaceColor, textColor)
                      : _buildLiveUI(isHost, true, primaryColor, surfaceColor),
                ),
              ],
            ),
            if (!_isAccepted && !isHost) _buildPendingOverlay(primaryColor),
          ],
        ),
        bottomNavigationBar: (isHost || _isAccepted)
            ? (_currentMode == ActiveRoomMode.CHAT
                ? _buildChatInput(true, primaryColor, surfaceColor, textColor)
                : _buildLiveControls(isHost, true, primaryColor, surfaceColor))
            : _buildRestrictedFooter(primaryColor),
      ),
    );
  }

  Widget _buildPendingOverlay(Color primary) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty_rounded, color: primary, size: 64),
            const SizedBox(height: 24),
            Text('WAITING FOR APPROVAL',
                style: AppTextStyles.h3.copyWith(color: Colors.white)),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'The room owner or moderator needs to accept your request before you can interact.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestrictedFooter(Color primary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.milapPlusSurface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Chat and interaction restricted until accepted.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      bool isHost, bool isPremium, Color primary, Color text) {
    return AppBar(
      backgroundColor: AppColors.milapPlusSecondary,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        onPressed: widget.onLeave,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70, size: 16),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primary.withOpacity(0.5), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.room.hostAvatar),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.room.name,
                    style: TextStyle(
                        color: text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5)),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: AppColors.online, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.room.participants.length} SOULS ONLINE',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (isHost)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isAccepted = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Accepted new join request!')),
                );
              });
            },
            icon: Icon(Icons.check_circle_rounded, color: primary, size: 20),
            label: Text('ACCEPT',
                style:
                    AppTextStyles.label.copyWith(color: primary, fontSize: 10)),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(Icons.stars_rounded, color: primary, size: 24),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildModeSwitcher(
      bool isPremium, Color primary, Color surface, Color text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: isPremium ? AppColors.milapPlusSecondary : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isPremium ? AppColors.milapPlusSurface : AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildModeButton(
                'GROUP CHAT', ActiveRoomMode.CHAT, isPremium, primary, text),
            _buildModeButton(
                'LIVE STREAM', ActiveRoomMode.LIVE, isPremium, primary, text),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, ActiveRoomMode mode, bool isPremium,
      Color primary, Color text) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isSelected
                    ? (isPremium ? Colors.black : Colors.white)
                    : (isPremium ? Colors.white38 : AppColors.textMuted),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatUI(
      bool isPremium, Color primary, Color surface, Color text) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _mockMessages.length,
      itemBuilder: (context, index) {
        final msg = _mockMessages[index];
        return _buildModernChatBubble(msg, isPremium, primary, surface, text);
      },
    );
  }

  Widget _buildModernChatBubble(Map<String, dynamic> msg, bool isPremium,
      Color primary, Color surface, Color textMain) {
    final bool isMe = msg['isMe'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(msg['avatar']),
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(msg['sender'],
                      style: AppTextStyles.label.copyWith(
                          fontSize: 10,
                          color: isPremium
                              ? Colors.white54
                              : AppColors.textMuted)),
                ),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isMe ? primary : surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg['text'],
                      style: AppTextStyles.body.copyWith(
                        color: isMe
                            ? (isPremium ? Colors.black : Colors.white)
                            : textMain,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg['time'],
                      style: TextStyle(
                        fontSize: 8,
                        color: isMe
                            ? (isPremium ? Colors.black54 : Colors.white60)
                            : (isPremium
                                ? Colors.white38
                                : AppColors.textExtraLight),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(msg['avatar']),
            ),
        ],
      ),
    );
  }

  Widget _buildChatInput(
      bool isPremium, Color primary, Color surface, Color text) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: isPremium ? AppColors.milapPlusSecondary : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.add_circle_outline_rounded, color: primary)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isPremium
                    ? AppColors.milapPlusSurface
                    : AppColors.background,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: isPremium ? Colors.white10 : AppColors.border),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
                  hintStyle: TextStyle(
                      color: isPremium
                          ? Colors.white24
                          : AppColors.textExtraLight),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_messageController.text.isNotEmpty) {
                setState(() {
                  _mockMessages.add({
                    'sender': 'Me',
                    'text': _messageController.text,
                    'isMe': true,
                    'time': 'Just now',
                    'avatar': 'https://i.pravatar.cc/150?img=11'
                  });
                  _messageController.clear();
                });
              }
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: primary,
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveUI(
      bool isHost, bool isPremium, Color primary, Color surface) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Main Feed
            Image.network(
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            // Glass Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Indicators
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.white, size: 8),
                    const SizedBox(width: 6),
                    Text('LIVE',
                        style: AppTextStyles.label.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text('${widget.room.participants.length}',
                        style:
                            AppTextStyles.label.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ),
            // Host Info
            Positioned(
              bottom: 24,
              left: 24,
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.room.hostAvatar)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.room.hostName,
                          style:
                              AppTextStyles.h4.copyWith(color: Colors.white)),
                      Text('Broadcasting...',
                          style: AppTextStyles.label.copyWith(
                              color: isPremium ? primary : Colors.white70,
                              fontSize: 10)),
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

  Widget _buildLiveControls(
      bool isHost, bool isPremium, Color primary, Color surface) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: isPremium ? AppColors.milapPlusSecondary : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.mic_rounded, 'Mute', primary, isPremium),
          _buildActionButton(
              Icons.videocam_rounded, 'Camera', primary, isPremium),
          _buildActionButton(
              Icons.favorite_rounded, 'Gift', primary, isPremium),
          _buildActionButton(
              Icons.logout_rounded, 'Leave', Colors.red, isPremium),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, bool isPremium) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: AppTextStyles.label.copyWith(
                fontSize: 10,
                color: isPremium ? Colors.white54 : AppColors.textMuted)),
      ],
    );
  }
}
