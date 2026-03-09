import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:milap/models/chat.dart';
import 'package:milap/models/user_profile.dart';
import 'package:milap/providers/user_provider.dart';
import 'package:milap/services/chat_service.dart';
import 'package:milap/theme/app_colors.dart';
import 'package:milap/theme/app_icons.dart';
import 'package:milap/theme/app_text_styles.dart';

class ChatScreen extends StatefulWidget {
  final UserProfile? peer;
  final String? roomId;
  final Chat? chat;

  const ChatScreen({Key? key, this.peer, this.roomId, this.chat}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  bool _isComposing = false;

  String get roomId => widget.roomId ?? widget.chat?.id ?? '';
  UserProfile? get peer => widget.peer ?? (widget.chat?.participants.isNotEmpty == true ? widget.chat!.participants[0] : null);

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isComposing = _messageController.text.trim().isNotEmpty;
      });
    });

    // Mark messages as read when entering the chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user != null) {
        _chatService.markMessagesAsRead(roomId, userProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;

    if (currentUser == null || peer == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.streamMessages(roomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text('Start a conversation with ${peer!.name}',
                        style: const TextStyle(color: Colors.white54)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser.id;
                    return _buildMessageBubble(isMe, msg.text);
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(currentUser.id),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF101010),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(AppIcons.back, color: Colors.white),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(peer!.photos.isNotEmpty ? peer!.photos[0] : 'https://i.pravatar.cc/150'),
          ),
          const SizedBox(width: 12),
          Text(peer!.name, style: AppTextStyles.h4),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showCallFeedback('Video Call'),
          icon: const Icon(Icons.videocam_rounded, color: AppColors.primary),
        ),
        IconButton(
          onPressed: () => _showCallFeedback('Voice Call'),
          icon: const Icon(Icons.call_rounded, color: AppColors.primary),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert, color: Colors.white70),
        ),
      ],
    );
  }

  void _showCallFeedback(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting $type...'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildMessageBubble(bool isMe, String content) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(content, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMessageComposer(String currentUserId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: const Color(0xFF101010),
      child: Row(
        children: [
          IconButton(
            onPressed: () {}, // Media upload logic
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isComposing ? () => _handleSendMessage(currentUserId) : null,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isComposing ? AppColors.primary : AppColors.textExtraLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isComposing ? Icons.send : Icons.mic_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _handleSendMessage(String currentUserId) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = Message(
      id: '', // Will be set by service
      senderId: currentUserId,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isEncrypted: true,
      readStatus: MessageReadStatus.sent,
    );

    _chatService.sendMessage(roomId, message);
    _messageController.clear();
  }
}
