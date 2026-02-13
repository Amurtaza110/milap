import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SwipeCard extends StatefulWidget {
  final UserProfile? profile;
  final Function(String action) onAction;
  final Function(UserProfile) onViewProfile;
  final Function(String) onBlockUser;
  final bool hasStatus;
  final VoidCallback? onShowStatus;

  const SwipeCard({
    Key? key,
    this.profile,
    required this.onAction,
    required this.onViewProfile,
    required this.onBlockUser,
    this.hasStatus = false,
    this.onShowStatus,
  }) : super(key: key);

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  String? _exitDirection;

  void _handleAction(String action) {
    if (widget.profile == null) return;

    setState(() {
      _exitDirection = action == 'pass' ? 'left' : 'right';
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      widget.onAction(action);
      if (mounted) {
        setState(() {
          _exitDirection = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profile == null) {
      return Container(
        height: 500,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(45),
                border: Border.all(color: AppColors.background),
              ),
              child: const Center(
                child: Text('🔍', style: TextStyle(fontSize: 48)),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                    duration: 2.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    curve: Curves.easeInOut)
                .then()
                .scale(
                    duration: 2.seconds,
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(1, 1),
                    curve: Curves.easeInOut),
            const SizedBox(height: 40),
            Text(
              'Scanning Perimeters...',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textMain,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'NO NEW MATCHES IN YOUR RANGE. TRY EXPANDING YOUR SEARCH AREA.',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    double dx = 0;
    double rotation = 0;
    double opacity = 1;

    if (_exitDirection == 'left') {
      dx = -500;
      rotation = -0.3;
      opacity = 0;
    } else if (_exitDirection == 'right') {
      dx = 500;
      rotation = 0.3;
      opacity = 0;
    }

    return GestureDetector(
      onTap: () {
        if (widget.profile == null) return;
        if (widget.hasStatus && widget.onShowStatus != null) {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (ctx) => Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.play_circle_outline_rounded),
                    title: const Text('View Status'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      widget.onShowStatus!();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: const Text('View Profile'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      widget.onViewProfile(widget.profile!);
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          widget.onViewProfile(widget.profile!);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(dx, 0, 0)..rotateZ(rotation),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: double.infinity,
            height: 550,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              border: Border.all(color: Colors.pink[50]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo
                  CachedNetworkImage(
                    imageUrl: widget.profile!.photos[0],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                  ),

                  // Status Ring
                  if (widget.hasStatus)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primary, width: 3),
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),

                  // Overlay Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0, 0.4, 0.7, 1],
                      ),
                    ),
                  ),

                  // Info Overlay
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${widget.profile!.name}, ${widget.profile!.age}',
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            if (widget.profile!.isOnline) ...[
                              const SizedBox(width: 12),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.online,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.5)),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  const Text('★',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.profile!.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.profile!.location.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.profile!.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            _ActionButton(
                              onTap: () => _handleAction('pass'),
                              icon: AppIcons.close,
                              isPrimary: false,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MatchButton(
                                onTap: () => _handleAction('match'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Block Button
                  Positioned(
                    top: 24,
                    right: 24,
                    child: _CircleIconBtn(
                      icon: AppIcons.block,
                      onTap: () {
                        // In a real app we'd show a dialog here
                        widget.onBlockUser(widget.profile!.id);
                      },
                    ),
                  ),

                  // View Profile Button
                  Positioned(
                    top: 24,
                    left: 24,
                    child: _CircleIconBtn(
                      icon: AppIcons.info,
                      onTap: () => widget.onViewProfile(widget.profile!),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final bool isPrimary;

  const _ActionButton(
      {required this.onTap, required this.icon, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: AppColors.textMain, size: 20),
        ),
      ),
    );
  }
}

class _MatchButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MatchButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'MATCH SOUL',
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        ),
      ),
    );
  }
}
