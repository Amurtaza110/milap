import 'package:flutter/material.dart';
import 'package:milap/models/message.dart';
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(String currentUserId, String userName) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _roomService.sendMessage(widget.room.id, currentUserId, userName, text);
    _messageController.clear();
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
    final isHost = user.id == widget.room.creatorId;

    final primaryColor = AppColors.milapPlusPrimary;
    final backgroundColor = AppColors.milapPlusSecondary;
    final surfaceColor = AppColors.milapPlusSurface;
    final textColor = Colors.white;

    return Theme(
      data: AppTheme.milapPlusTheme,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(isHost, primaryColor, textColor),
        body: Column(
          children: [
            Expanded(child: _buildChatUI(user.id, primaryColor, surfaceColor, textColor)),
          ],
        ),
        bottomNavigationBar: _buildChatInput(user, primaryColor, surfaceColor, textColor),
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
    );
  }

  Widget _buildChatUI(String currentUserId, Color primary, Color surface, Color text) {
    return StreamBuilder<List<Message>>(
      stream: _roomService.getMessages(widget.room.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet.',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }
        final messages = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) => _buildBubble(messages[index], currentUserId, primary, surface),
        );
      },
    );
  }

  Widget _buildBubble(Message msg, String currentUserId, Color primary, Color surface) {
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
              Text(msg.text, style: TextStyle(color: isMe ? Colors.black : Colors.white)),
              const SizedBox(height: 4),
              Text(DateFormat('hh:mm a').format(msg.timestamp.toDate()), style: TextStyle(fontSize: 8, color: isMe ? Colors.black54 : Colors.white38)),
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
            onTap: () => _sendMessage(user.id, user.name),
            child: CircleAvatar(
              backgroundColor: primary,
              child: const Icon(Icons.send_rounded, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
