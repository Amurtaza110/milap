import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_text_styles.dart';

class ChatScreen extends StatefulWidget {
  final UserProfile? peer;
  final String? roomId;

  const ChatScreen({Key? key, this.peer, this.roomId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  bool _isComposing = false;

  bool get isRoomChat => widget.roomId != null;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isComposing = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 20, // Mock message count
              itemBuilder: (context, index) {
                final isMe = index % 4 == 0;
                return _buildMessageBubble(isMe, 'Message content at $index');
              },
            ),
          ),
          _buildMessageComposer(),
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
      title: isRoomChat
          ? Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.people, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room Name', style: AppTextStyles.h4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('LIVE', style: AppTextStyles.label),
                      ],
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(widget.peer!.photos[0]),
                ),
                const SizedBox(width: 12),
                Text(widget.peer!.name, style: AppTextStyles.h4),
              ],
            ),
      actions: [
        IconButton(
          onPressed: () => _showCallFeedback('Video Call'),
          icon: const Icon(Icons.videocam_rounded, color: AppColors.primary),
          tooltip: 'Video Call',
        ),
        IconButton(
          onPressed: () => _showCallFeedback('Voice Call'),
          icon: const Icon(Icons.call_rounded, color: AppColors.primary),
          tooltip: 'Voice Call',
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
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(content, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: const Color(0xFF101010),
      child: Row(
        children: [
          IconButton(
            onPressed: _showMediaSelection,
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
            onTap: _isComposing ? _handleSendMessage : _handleVoiceChat,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primary,
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

  void _handleSendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    // Sending logic here
    _messageController.clear();
  }

  void _handleVoiceChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hold to record voice message...'),
        backgroundColor: Colors.blueGrey,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showMediaSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMediaOption(
                    Icons.image_rounded, 'Gallery', Colors.purple),
                _buildMediaOption(
                    Icons.camera_alt_rounded, 'Camera', Colors.red),
                _buildMediaOption(
                    Icons.description_rounded, 'Document', Colors.blue),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMediaOption(
                    Icons.headset_rounded, 'Audio', Colors.orange),
                _buildMediaOption(
                    Icons.location_on_rounded, 'Location', Colors.green),
                _buildMediaOption(Icons.person_rounded, 'Contact', Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _handleMediaUpload(label);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  void _handleMediaUpload(String type) {
    // Mocking a file size check
    // In real app, you'd get the file length first
    const mockFileSizeMB = 55; // Example exceeding limit
    const limitMB = 50;

    if (mockFileSizeMB > limitMB) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('File too large',
              style: TextStyle(color: Colors.white)),
          content: Text(
            'The selected $type is $mockFileSizeMB MB, which exceeds the $limitMB MB limit.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('OK', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    } else {
      // Proceed with upload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading $type...')),
      );
    }
  }
}
