import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_profile.dart';
import '../../../models/chat.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'dart:async';
import '../../../services/screenshot_detection_service.dart';

class ChatRoom extends StatefulWidget {
  final Chat chat;
  final VoidCallback onBack;
  final Function(String) onOpenSharedVault;
  final Function(String) onBlockUser;
  final VoidCallback onViewProfile;

  const ChatRoom({
    Key? key,
    required this.chat,
    required this.onBack,
    required this.onOpenSharedVault,
    required this.onBlockUser,
    required this.onViewProfile,
  }) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _showSettings = false;
  bool _blackout = false;
  bool _screenshotAlert = false;
  StreamSubscription<ScreenshotEvent>? _screenshotSubscription;

  @override
  void initState() {
    super.initState();
    _messages = [
      Message(
          id: 'm1',
          senderId: widget.chat.participants[0].id,
          text: "Asalam-o-Alaikum! 🌟",
          timestamp: DateTime.now()
              .subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          isEncrypted: true,
          readStatus: MessageReadStatus.read),
      Message(
          id: 'm2',
          senderId: 'me',
          text: "Walikum Asalam! Looking forward to connecting.",
          timestamp: DateTime.now()
              .subtract(const Duration(minutes: 50))
              .millisecondsSinceEpoch,
          isEncrypted: true,
          readStatus: MessageReadStatus.read),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Start screenshot monitoring
    final screenshotService = ScreenshotDetectionService();
    screenshotService.startMonitoring();
    _screenshotSubscription =
        screenshotService.screenshotStream.listen(_handleScreenshotEvent);
  }

  @override
  void dispose() {
    ScreenshotDetectionService().stopMonitoring();
    _screenshotSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _handleSend() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      text: _messageController.text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isEncrypted: true,
      readStatus: MessageReadStatus.sent,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    // Mock response/status updates
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted)
        setState(() => _messages.last = Message(
            id: newMessage.id,
            senderId: 'me',
            text: newMessage.text,
            timestamp: newMessage.timestamp,
            isEncrypted: true,
            readStatus: MessageReadStatus.delivered));
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted)
        setState(() => _messages.last = Message(
            id: newMessage.id,
            senderId: 'me',
            text: newMessage.text,
            timestamp: newMessage.timestamp,
            isEncrypted: true,
            readStatus: MessageReadStatus.read));
    });
  }

  void _togglePrivacyGuard() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      userProvider.updateUser(user.copyWith(
          privacyGuardEnabled: !(user.privacyGuardEnabled ?? false)));
    }
  }

  void _handleScreenshotEvent(ScreenshotEvent event) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    final otherParticipant =
        widget.chat.participants.firstWhere((p) => p.id != user.id);
    final involvesThisChat = (event.userId == user.id &&
            event.otherUserId == otherParticipant.id) ||
        (event.otherUserId == user.id && event.userId == otherParticipant.id);

    if (!involvesThisChat) return;

    final isCurrentUserTaker = event.userId == user.id;
    if (!mounted) return;

    setState(() {
      _blackout = isCurrentUserTaker;
      _screenshotAlert = !isCurrentUserTaker;
    });

    // Notify backend/log event
    final screenshotService = ScreenshotDetectionService();
    screenshotService.notifyBothUsers(
      event.userId,
      event.otherUserId,
      'Screenshot detected in chat with ${otherParticipant.name}',
    );

    if (_screenshotAlert) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => _screenshotAlert = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user!;
    final otherParticipant =
        widget.chat.participants.firstWhere((p) => p.id != user.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(otherParticipant),
              if (_screenshotAlert) _buildScreenshotBanner(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg.senderId == 'me';
                    return _buildMessageBubble(msg, isMe, otherParticipant);
                  },
                ),
              ),
              _buildChatInput(),
            ],
          ),
          if (_showSettings)
            Positioned(
              top: 110,
              left: 24,
              right: 24,
              child: _buildSettingsPanel(
                  user.privacyGuardEnabled ?? false, otherParticipant),
            ),
          if (_blackout)
            Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: Text('PRIVACY GUARD ACTIVE\nSCREENSHOTS ARE PROTECTED',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProfile participant) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 56, 12, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textMain, size: 20),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: widget.onViewProfile,
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                            participant.photos.isNotEmpty
                                ? participant.photos[0]
                                : 'https://i.pravatar.cc/150'),
                      ),
                      if (participant.isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: AppColors.online,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2))),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(participant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h4.copyWith(
                                color: AppColors.textMain, fontSize: 16)),
                        Text(participant.isOnline ? 'Active Now' : 'Offline',
                            style: AppTextStyles.label.copyWith(
                                color: participant.isOnline
                                    ? AppColors.success
                                    : AppColors.textMuted,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showSettings = !_showSettings),
            icon: Icon(Icons.security_rounded,
                color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      Message msg, bool isMe, UserProfile otherParticipant) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(otherParticipant.photos.isNotEmpty
                  ? otherParticipant.photos[0]
                  : 'https://i.pravatar.cc/150'),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showMessageActions(msg, isMe),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: AppTextStyles.body.copyWith(
                        color: isMe ? Colors.white : AppColors.textMain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(msg.timestamp)
                          .toString()
                          .substring(11, 16),
                      style: TextStyle(
                          fontSize: 8, color: AppColors.textExtraLight),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        msg.readStatus == MessageReadStatus.read
                            ? Icons.done_all
                            : Icons.done,
                        size: 10,
                        color: msg.readStatus == MessageReadStatus.read
                            ? AppColors.success
                            : AppColors.textExtraLight,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageActions(Message msg, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
            _buildActionItem(Icons.reply_rounded, 'Reply'),
            _buildActionItem(Icons.content_copy_rounded, 'Copy Text'),
            _buildActionItem(Icons.forward_rounded, 'Forward'),
            _buildActionItem(Icons.star_outline_rounded, 'Save to Vault'),
            const Divider(),
            _buildActionItem(Icons.delete_outline_rounded, 'Delete',
                color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textMain),
      title: Text(label,
          style: TextStyle(color: color ?? AppColors.textMain, fontSize: 14)),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primary)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: AppColors.textExtraLight),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSend,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.red.withOpacity(0.1),
      child: Center(
        child: Text('SECURITY ALERT: Screenshot detected!',
            style:
                AppTextStyles.label.copyWith(color: Colors.red, fontSize: 10)),
      ),
    );
  }

  Widget _buildSettingsPanel(bool privacyGuard, UserProfile participant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30)
          ],
          border: Border.all(color: AppColors.border)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PRIVACY SHIELD',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 10)),
              Switch(
                  value: privacyGuard,
                  onChanged: (v) => _togglePrivacyGuard(),
                  activeColor: AppColors.success),
            ],
          ),
          const Divider(),
          ListTile(
            dense: true,
            leading: const Icon(Icons.storage_rounded, size: 20),
            title: const Text('Access Shared Vault',
                style: TextStyle(fontSize: 12)),
            onTap: () => widget.onOpenSharedVault(participant.id),
          ),
          ListTile(
            dense: true,
            leading:
                const Icon(Icons.block_rounded, color: Colors.red, size: 20),
            title: const Text('Block User',
                style: TextStyle(color: Colors.red, fontSize: 12)),
            onTap: () => widget.onBlockUser(participant.id),
          ),
        ],
      ),
    );
  }
}
