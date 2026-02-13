import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/status.dart';
import '../theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StatusStoryRail extends StatelessWidget {
  final UserProfile user;
  final List<Status> statuses;
  final Function(Status)? onOpenStatus;
  final bool showMyStatus;
  final VoidCallback? onAddStatus;

  const StatusStoryRail({
    Key? key,
    required this.user,
    required this.statuses,
    this.onOpenStatus,
    this.showMyStatus = true,
    this.onAddStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find user's own status if any
    Status? userStatus;
    try {
      userStatus = statuses.firstWhere((s) => s.userId == user.id);
    } catch (_) {}

    final otherStatuses = statuses.where((s) => s.userId != user.id).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.background.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            if (showMyStatus) ...[
              const SizedBox(width: 20),
              _MyStoryItem(
                user: user,
                userStatus: userStatus,
                onTap: () {
                  if (userStatus != null && onOpenStatus != null) {
                    onOpenStatus!(userStatus);
                  } else if (onAddStatus != null) {
                    onAddStatus!();
                  }
                },
              ),
              const SizedBox(width: 24),
            ],
            ...otherStatuses.map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: 24),
                child: _StoryItem(
                  status: status,
                  onTap: () => onOpenStatus?.call(status),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _MyStoryItem extends StatelessWidget {
  final UserProfile user;
  final Status? userStatus;
  final VoidCallback onTap;

  const _MyStoryItem({
    required this.user,
    this.userStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border,
                    width: 2,
                    style: BorderStyle
                        .solid, // React code used border-dashed, but standard circle border is safer for now
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    imageUrl: userStatus?.mediaUrl ??
                        (user.photos.isNotEmpty ? user.photos[0] : ''),
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person),
                  ),
                ),
              ),
              if (userStatus == null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, size: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            userStatus != null ? 'My Story' : 'Add Story',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final Status status;
  final VoidCallback onTap;

  const _StoryItem({
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: status.isSeen ? AppColors.border : AppColors.primary,
                width: 2,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  imageUrl: status.userAvatar,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 64,
            child: Text(
              status.userName.split(' ')[0],
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
