import 'package:flutter/material.dart';
import 'package:milap/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../models/room.dart';
import '../../../providers/user_provider.dart';
import '../../../services/room_service.dart';
import '../../../services/live_stream_service.dart';
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
  final RoomService _roomService = RoomService();
  final LiveStreamService _liveStreamService = LiveStreamService();
  bool _isAccepted = false;
  bool _isLiveJoined = false;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    final currentUser = Provider.of<UserProvider>(context, listen: false).user!;
    final participant = widget.room.participants.firstWhere(
      (p) => p.userId == currentUser.id,
      orElse: () => RoomParticipant(userId: '', name: '', avatar: '', joinedAt: DateTime.now()),
    );

    if (participant.userId.isNotEmpty || currentUser.id == widget.room.hostId) {
      _isAccepted = true;
    }
  }

  @override
  void dispose() {
    _liveStreamService.leaveChannel();
    super.dispose();
  }

  void _sendMessage(String currentUserId, String userName, String userAvatar) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = RoomMessage(
      id: '',
      roomId: widget.room.id,
      senderId: currentUserId,
      senderName: userName,
      senderAvatar: userAvatar,
      message: text,
      timestamp: DateTime.now(),
    );

    await _roomService.sendMessage(widget.room.id, message);
    _messageController.clear();
  }

  Future<void> _toggleLiveMode(bool isHost) async {
    if (_currentMode == ActiveRoomMode.LIVE) {
      setState(() => _currentMode = ActiveRoomMode.CHAT);
      await _liveStreamService.leaveChannel();
      setState(() => _isLiveJoined = false);
    } else {
      setState(() => _currentMode = ActiveRoomMode.LIVE);
      await _liveStreamService.initialize();
      await _liveStreamService.joinChannel(widget.room.id, isHost);
      setState(() => _isLiveJoined = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user!;
    final isHost = user.id == widget.room.hostId;

    final primaryColor = AppColors.milapPlusPrimary;
    final backgroundColor = AppColors.milapPlusSecondary;
    final surfaceColor = AppColors.milapPlusSurface;
    final textColor = Colors.white;

    return Theme(
      data: AppTheme.milapPlusTheme,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(isHost, primaryColor, textColor),
        body: Stack(
          children: [
            Column(
              children: [
                _buildModeSwitcher(isHost, primaryColor, surfaceColor, textColor),
                Expanded(
                  child: _currentMode == ActiveRoomMode.CHAT
                      ? _buildChatUI(user.id, primaryColor, surfaceColor, textColor)
                      : _buildLiveUI(isHost, primaryColor, surfaceColor),
                ),
              ],
            ),
            if (!_isAccepted && !isHost) _buildPendingOverlay(primaryColor),
          ],
        ),
        bottomNavigationBar: (isHost || _isAccepted)
            ? (_currentMode == ActiveRoomMode.CHAT
                ? _buildChatInput(user, primaryColor, surfaceColor, textColor)
                : _buildLiveControls(isHost, primaryColor, surfaceColor))
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
            Text('WAITING FOR APPROVAL', style: AppTextStyles.h3.copyWith(color: Colors.white)),
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
            child: Text('Chat and interaction restricted until accepted.', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isHost, Color primary, Color text) {
    return AppBar(
      backgroundColor: AppColors.milapPlusSecondary,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        onPressed: () {
          final user = Provider.of<UserProvider>(context, listen: false).user!;
          _roomService.leaveRoom(widget.room.id, user.id);
          widget.onLeave();
        },
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(widget.room.hostAvatar.isNotEmpty ? widget.room.hostAvatar : 'https://i.pravatar.cc/150'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.room.name, style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.online, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('${widget.room.participants.length} SOULS ONLINE', style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (isHost) IconButton(onPressed: () {}, icon: Icon(Icons.admin_panel_settings_rounded, color: primary)),
        const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.stars_rounded, color: AppColors.milapPlusPrimary, size: 24)),
      ],
    );
  }

  Widget _buildModeSwitcher(bool isHost, Color primary, Color surface, Color text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: AppColors.milapPlusSecondary,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.milapPlusSurface, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            _buildModeButton('GROUP CHAT', ActiveRoomMode.CHAT, isHost, primary, text),
            _buildModeButton('LIVE STREAM', ActiveRoomMode.LIVE, isHost, primary, text),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, ActiveRoomMode mode, bool isHost, Color primary, Color text) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleLiveMode(isHost),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? primary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(label, style: AppTextStyles.label.copyWith(color: isSelected ? Colors.black : Colors.white38, fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal, fontSize: 10)),
          ),
        ),
      ),
    );
  }

  Widget _buildChatUI(String currentUserId, Color primary, Color surface, Color text) {
    return StreamBuilder<List<RoomMessage>>(
      stream: _roomService.streamRoomMessages(widget.room.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) return Center(child: Text('Welcome to ${widget.room.name}! 👋', style: const TextStyle(color: Colors.white24)));
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          physics: const BouncingScrollPhysics(),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) => _buildModernChatBubble(messages[index], currentUserId, primary, surface, text),
        );
      },
    );
  }

  Widget _buildModernChatBubble(RoomMessage msg, String currentUserId, Color primary, Color surface, Color textMain) {
    final bool isMe = msg.senderId == currentUserId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) CircleAvatar(radius: 16, backgroundImage: NetworkImage(msg.senderAvatar.isNotEmpty ? msg.senderAvatar : 'https://i.pravatar.cc/150')),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe) Padding(padding: const EdgeInsets.only(left: 4, bottom: 4), child: Text(msg.senderName, style: const TextStyle(fontSize: 10, color: Colors.white54))),
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isMe ? primary : surface, borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(isMe ? 20 : 4), bottomRight: Radius.circular(isMe ? 4 : 20))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(msg.message, style: TextStyle(color: isMe ? Colors.black : Colors.white, height: 1.4)),
                    const SizedBox(height: 4),
                    Text(DateFormat('hh:mm a').format(msg.timestamp), style: TextStyle(fontSize: 8, color: isMe ? Colors.black54 : Colors.white38)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput(dynamic user, Color primary, Color surface, Color text) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: const BoxDecoration(color: AppColors.milapPlusSecondary),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: Icon(Icons.add_circle_outline_rounded, color: primary)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.milapPlusSurface, borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white10)),
              child: TextField(controller: _messageController, style: TextStyle(color: text), decoration: const InputDecoration(hintText: 'Share your thoughts...', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none)),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(onTap: () => _sendMessage(user.id, user.name, user.photos.isNotEmpty ? user.photos[0] : ''), child: CircleAvatar(radius: 24, backgroundColor: primary, child: const Icon(Icons.send_rounded, color: Colors.black, size: 20))),
        ],
      ),
    );
  }

  Widget _buildLiveUI(bool isHost, Color primary, Color surface) {
    if (!_isLiveJoined) return const Center(child: CircularProgressIndicator());

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // REAL AGORA VIDEO VIEW
            if (isHost)
              AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _liveStreamService.engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            else if (_remoteUid != null)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _liveStreamService.engine!,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(channelId: widget.room.id),
                ),
              )
            else
              const Center(child: Text('Waiting for host to go live...', style: TextStyle(color: Colors.white54))),

            Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.6)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
            Positioned(top: 20, left: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)), child: const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)))),
            Positioned(bottom: 24, left: 24, child: Row(children: [CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.room.hostAvatar)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.room.hostName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('Broadcasting...', style: TextStyle(color: primary, fontSize: 10))])])),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveControls(bool isHost, Color primary, Color surface) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: AppColors.milapPlusSecondary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.mic_rounded, 'Mute', primary),
          _buildActionButton(Icons.videocam_rounded, 'Camera', primary),
          _buildActionButton(Icons.favorite_rounded, 'Gift', primary),
          _buildActionButton(Icons.logout_rounded, 'Leave', Colors.red),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54))]);
  }
}
