import 'package:flutter/material.dart';
import '../../models/social_event.dart';
import '../../models/enums.dart';
import '../../models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class EventDetailsScreen extends StatelessWidget {
  final SocialEvent event;
  final UserProfile user;
  final VoidCallback onBack;
  final VoidCallback onUpgrade;
  final VoidCallback onBook;

  const EventDetailsScreen({
    Key? key,
    required this.event,
    required this.user,
    required this.onBack,
    required this.onUpgrade,
    required this.onBook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAccessDenied =
        event.accessLevel == AccessLevel.Gold && !user.isMilapGold;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Header Section
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Hero(
                      tag: 'event_${event.id}',
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(event.media[0]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Gradient Overlay for Depth
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            const Color(0xFF0F0F0F).withOpacity(0.8),
                            const Color(0xFF0F0F0F),
                          ],
                        ),
                      ),
                    ),
                    // Access Denied Overlay
                    if (isAccessDenied)
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        color: Colors.black.withOpacity(0.6),
                        child: const Center(
                          child: Icon(Icons.lock_rounded,
                              color: Colors.amber, size: 64),
                        ),
                      ),

                    // Title and Basic Info Overlaid
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBadge(event.eventType.name.toUpperCase()),
                          const SizedBox(height: 12),
                          Text(
                            event.title,
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoChip(
                                  Icons.calendar_today_rounded, event.date),
                              const SizedBox(width: 12),
                              _buildInfoChip(
                                  Icons.access_time_rounded, event.time),
                              const Spacer(),
                              _buildRating(event.organizerRating),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Detailed Content
              if (!isAccessDenied) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      _buildSectionTitle('THE EXPERIENCE'),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildHostCard(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('WHERE TO GO'),
                      const SizedBox(height: 12),
                      _buildLocationCard(),
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ] else ...[
                _buildGoldWall(),
              ],
            ],
          ),

          // Action Bars
          _buildTopBar(context),
          if (!isAccessDenied) _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRating(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            '$rating',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.label.copyWith(
        fontSize: 10,
        color: Colors.white38,
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHostCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('CURATED BY'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(event.organizerAvatar,
                      width: 56, height: 56, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.organizerName,
                      style: AppTextStyles.h4
                          .copyWith(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${event.pastEventsCount} EXCLUSIVE EVENTS HOSTED',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 8,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified_rounded, color: Colors.blue, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                event.location,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoldWall() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.amber, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('GOLD EXCLUSIVE',
                  style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 12)),
              const SizedBox(height: 12),
              Text(
                'Unlock The Inner Circle',
                style: AppTextStyles.h2
                    .copyWith(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 12),
              Text(
                'This curated experience is reserved exclusively for Milap Gold members.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body
                    .copyWith(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: onUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('UPGRADE NOW',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 64,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleAction(Icons.arrow_back_ios_new_rounded, onBack),
          Row(
            children: [
              _buildCircleAction(Icons.share_rounded, () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link Copied!')));
              }),
              const SizedBox(width: 12),
              _buildCircleAction(Icons.favorite_border_rounded, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          border:
              Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('STARTING FROM',
                    style: AppTextStyles.label.copyWith(
                        fontSize: 8,
                        color: Colors.white38,
                        letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text('PKR ${event.packages[0].price}',
                    style: AppTextStyles.h2.copyWith(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                  child: const Text('RESERVE NOW',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
