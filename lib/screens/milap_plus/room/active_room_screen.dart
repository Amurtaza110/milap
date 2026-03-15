import 'package:flutter/material.dart';
import 'package:milap/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/room.dart';
import '../../../providers/user_provider.dart';
import '../../../services/room_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

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
  final TextEditingController _messageController = TextEditingController();
  final RoomService _roomService = RoomService();
  bool _isAccepted = false;

  @override
  void initState() {
    super.initState();
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser != null) {
      if (widget.room.participants.any((p) => p.userId == currentUser.id) ||
          currentUser.id == widget.room.hostId) {
        _isAccepted = true;
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
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

  void _handleDeleteRoom() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.milapPlusSurface,
        title: const Text('Delete Room?', style: TextStyle(color: Colors.white)),
        content: const Text('This will permanently close the room and delete all messages.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _roomService.deleteRoom(widget.room.id);
      widget.onLeave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
                Expanded(child: _buildChatUI(user.id, primaryColor, surfaceColor, textColor)),
              ],
            ),
            if (!_isAccepted && !isHost) _buildPendingOverlay(primaryColor),
          ],
        ),
        bottomNavigationBar: (isHost || _isAccepted)
            ? _buildChatInput(user, primaryColor, surfaceColor, textColor)
            : _buildRestrictedFooter(primaryColor),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isHost, Color primary, Color text) {
    return AppBar(
      backgroundColor: AppColors.milapPlusSecondary,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          final user = Provider.of<UserProvider>(context, listen: false).user!;
          _roomService.leaveRoom(widget.room.id, user.id);
          widget.onLeave();
        },
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
      ),
      title: Text(widget.room.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
      actions: [
        if (isHost) 
          PopupMenuButton<String>(
            icon: Icon(Icons.admin_panel_settings_rounded, color: primary),
            onSelected: (val) {
              if (val == 'delete') _handleDeleteRoom();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete Room', style: TextStyle(color: Colors.red))),
            ],
          ),
      ],
    );
  }

  Widget _buildChatUI(String currentUserId, Color primary, Color surface, Color text) {
    return StreamBuilder<List<RoomMessage>>(
      stream: _roomService.streamRoomMessages(widget.room.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final messages = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) => _buildBubble(messages[index], currentUserId, primary, surface),
        );
      },
    );
  }

  Widget _buildBubble(RoomMessage msg, String currentUserId, Color primary, Color surface) {
    final bool isMe = msg.senderId == currentUserId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isMe ? primary : surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe) Text(msg.senderName, style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
              Text(msg.message, style: TextStyle(color: isMe ? Colors.black : Colors.white)),
              const SizedBox(height: 4),
              Text(DateFormat('hh:mm a').format(msg.timestamp), style: TextStyle(fontSize: 8, color: isMe ? Colors.black54 : Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput(dynamic user, Color primary, Color surface, Color text) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      color: AppColors.milapPlusSecondary,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.milapPlusSurface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: text),
                decoration: const InputDecoration(hintText: 'Share your thoughts...', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(user.id, user.name, user.photos.isNotEmpty ? user.photos[0] : ''),
            child: CircleAvatar(
              backgroundColor: primary,
              child: const Icon(Icons.send_rounded, color: Colors.black),
            ),
          ),
        ],
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
        border: const Border(top: BorderSide(color: Colors.white10)),
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
}
