import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_icons.dart';
import '../../services/screenshot_detection_service.dart';
import 'dart:async';

class PublicProfileView extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onBack;
  final VoidCallback onConnect;
  final VoidCallback? onUpgrade;

  const PublicProfileView({
    Key? key,
    required this.profile,
    required this.onBack,
    required this.onConnect,
    this.onUpgrade,
  }) : super(key: key);

  @override
  State<PublicProfileView> createState() => _PublicProfileViewState();
}

class _PublicProfileViewState extends State<PublicProfileView> {
  bool _screenshotDetected = false;
  StreamSubscription<ScreenshotEvent>? _subscription;

  void _triggerWarning() {
    setState(() => _screenshotDetected = true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _screenshotDetected = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _subscription = ScreenshotDetectionService()
        .screenshotStream
        .listen(_handleScreenshotEvent);
  }

  void _handleScreenshotEvent(ScreenshotEvent event) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) return;

    final involvesThisProfile = event.otherUserId == widget.profile.id ||
        event.userId == widget.profile.id;
    final involvesViewer =
        event.userId == currentUser.id || event.otherUserId == currentUser.id;

    if (!involvesThisProfile || !involvesViewer) return;

    _triggerWarning();
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded),
              title: const Text('Direct Message'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onConnect();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_gmailerrorred_outlined),
              title: const Text('Report Profile'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted. Our team will review.'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'You will no longer receive messages from ${widget.profile.name}.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    final canDirectMessage = currentUser?.isMilapGold ?? false;

    final allMedia = [
      ...widget.profile.photos.map((url) => {
            'url': url,
            'type': 'photo',
            'isHidden': (widget.profile.hiddenMediaIds ?? []).contains(url)
          }),
      ...(widget.profile.videos ?? []).map((url) => {
            'url': url,
            'type': 'video',
            'isHidden': (widget.profile.hiddenMediaIds ?? []).contains(url)
          }),
    ];

    final headerPhoto = widget.profile.photos[0];
    final isHeaderHidden =
        (widget.profile.hiddenMediaIds ?? []).contains(headerPhoto);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Image
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(headerPhoto),
                          fit: BoxFit.cover,
                          colorFilter: isHeaderHidden
                              ? ColorFilter.mode(Colors.black.withOpacity(0.5),
                                  BlendMode.darken)
                              : null,
                        ),
                      ),
                      child: isHeaderHidden
                          ? Center(
                              child: Icon(AppIcons.lock,
                                  size: 48, color: Colors.white))
                          : null,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.95),
                            Colors.transparent,
                            Colors.black.withOpacity(0.4)
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 32,
                      right: 32,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  '${widget.profile.name}, ${widget.profile.age}',
                                  style: AppTextStyles.h1.copyWith(
                                    color: Colors.white,
                                    fontSize: 32,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.profile.isVerified == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    AppIcons.accepted,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildBadge(widget.profile.location),
                              _buildBadge(
                                  widget.profile.type.name.toUpperCase()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Details
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Bio
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5))
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('THE STORY',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.primary)),
                          const SizedBox(height: 12),
                          Text(widget.profile.bio,
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.textLight, height: 1.6)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Relationship
                    if (widget.profile.relationship?.isVisible == true &&
                        widget.profile.relationship?.status !=
                            RelationshipStatus.Single)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFFFE4E6))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RELATIONSHIP STATUS',
                                    style: AppTextStyles.label
                                        .copyWith(color: AppColors.primary)),
                                Text(widget.profile.relationship!.status.name,
                                    style: AppTextStyles.h3
                                        .copyWith(color: AppColors.textMain)),
                                if (widget.profile.relationship?.partnerName !=
                                    null)
                                  Text(
                                      'With ${widget.profile.relationship!.partnerName}',
                                      style: AppTextStyles.body.copyWith(
                                          fontSize: 12,
                                          color: AppColors.textLight)),
                              ],
                            ),
                            const Text('❤️', style: TextStyle(fontSize: 32)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Interests
                    Text('VIBES & PASSIONS',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.profile.interests
                          .map((i) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: AppColors.border)),
                                child: Text(i.toUpperCase(),
                                    style: AppTextStyles.label.copyWith(
                                        fontSize: 9,
                                        color: AppColors.textLight)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 32),

                    // Gallery
                    if (allMedia.length > 1) ...[
                      Text('VISUAL GALLERY',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.75),
                        itemCount: allMedia.length - 1,
                        itemBuilder: (context, index) {
                          final media = allMedia[index + 1];
                          final isHidden = media['isHidden'] as bool;
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(24),
                              image: DecorationImage(
                                  image: NetworkImage(media['url'] as String),
                                  fit: BoxFit.cover,
                                  colorFilter: isHidden
                                      ? ColorFilter.mode(
                                          Colors.black.withOpacity(0.5),
                                          BlendMode.darken)
                                      : null),
                            ),
                            child: isHidden
                                ? Center(
                                    child: Icon(AppIcons.lock,
                                        size: 24, color: Colors.white))
                                : null,
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Reviews
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PUBLIC IMPRESSIONS',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.textMuted)),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                                '★ ${widget.profile.rating.toStringAsFixed(1)} (${widget.profile.reviewsCount})',
                                style: AppTextStyles.label
                                    .copyWith(color: AppColors.textMain))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...(widget.profile.reviews ?? [])
                        .map((r) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(24)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(r.reviewerName,
                                          style: AppTextStyles.h4.copyWith(
                                              fontSize: 13,
                                              color: AppColors.textMain)),
                                      Row(
                                          children: List.generate(
                                              5,
                                              (i) => Icon(AppIcons.priority,
                                                  size: 12,
                                                  color: i < r.rating
                                                      ? AppColors.primary
                                                      : AppColors
                                                          .textExtraLight))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('"${r.comment}"',
                                      style: AppTextStyles.body.copyWith(
                                          fontSize: 12,
                                          color: AppColors.textLight,
                                          height: 1.4)),
                                ],
                              ),
                            ))
                        .toList(),
                    if ((widget.profile.reviews ?? []).isEmpty)
                      Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                  style: BorderStyle.none)),
                          child: Center(
                              child: Text('NO REVIEWS YET',
                                  style: AppTextStyles.label.copyWith(
                                      color: AppColors.textExtraLight)))),
                  ]),
                ),
              ),
            ],
          ),

          // Top Bars
          Positioned(
            top: 64,
            left: 16,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(AppIcons.back, size: 20, color: Colors.white),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    _showProfileMenu(context);
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action
          Positioned(
            bottom: 40,
            left: 32,
            right: 32,
            child: canDirectMessage
                ? ElevatedButton(
                    onPressed: widget.onConnect,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24))),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('DIRECT MESSAGE',
                              style: AppTextStyles.label.copyWith(
                                  color: Colors.white, letterSpacing: 2.0)),
                          const SizedBox(width: 8),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text('GOLD',
                                  style: AppTextStyles.label.copyWith(
                                      fontSize: 8, color: Colors.white)))
                        ]),
                  )
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                  content: Text(
                                      'Match Request sent to ${widget.profile.name}!'))),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF222222),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24))),
                          child: Text('MATCH TO CONNECT',
                              style: AppTextStyles.label.copyWith(
                                  color: Colors.white, letterSpacing: 2.0)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                          onPressed: widget.onUpgrade,
                          child: Text('Skip matching? Upgrade to Gold',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.textMuted))),
                    ],
                  ),
          ),

          // Alert
          if (_screenshotDetected)
            Positioned(
              top: 100,
              left: 32,
              right: 32,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.red.withOpacity(0.3), blurRadius: 20)
                    ]),
                child: Row(
                  children: [
                    Icon(AppIcons.warning, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('SECURITY ALERT',
                              style: AppTextStyles.label
                                  .copyWith(color: Colors.white)),
                          Text('Screenshot detected. User notified.',
                              style: AppTextStyles.body
                                  .copyWith(color: Colors.white, fontSize: 10))
                        ])),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2))),
      child: Text(text.toUpperCase(),
          style:
              AppTextStyles.label.copyWith(fontSize: 9, color: Colors.white)),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
