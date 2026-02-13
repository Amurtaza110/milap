import 'package:flutter/material.dart';
import '../models/status.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StatusViewOverlay extends StatelessWidget {
  final Status status;
  final VoidCallback onClose;
  final bool isOwner;
  final Function(String)? onDelete;

  const StatusViewOverlay({
    Key? key,
    required this.status,
    required this.onClose,
    required this.isOwner,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Media
          if (status.type == 'image')
            CachedNetworkImage(
              imageUrl: status.mediaUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
            )
          else
            const Center(
                child: Text('Video Status Not Implemented',
                    style: TextStyle(color: Colors.white))),

          // Top Info
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(status.userAvatar),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.userName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Just now',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Caption
          if (status.caption != null && status.caption!.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 40,
              right: 40,
              child: Text(
                status.caption!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),

          // Delete for owner
          if (isOwner)
            Positioned(
              bottom: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => onDelete?.call(status.id),
              ),
            ),
        ],
      ),
    );
  }
}
