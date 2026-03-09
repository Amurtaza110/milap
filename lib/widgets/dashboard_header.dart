import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DashboardHeader extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onOpenStore;
  final VoidCallback onOpenNotifications;
  final VoidCallback? onOpenSentRequests;

  const DashboardHeader({
    Key? key,
    required this.user,
    required this.onOpenStore,
    required this.onOpenNotifications,
    this.onOpenSentRequests,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Premium Logo Design
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Milap',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textMain,
                      letterSpacing: -1.5,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    height: 3,
                    width: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  // Economy Widget
                  GestureDetector(
                    onTap: onOpenStore,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            user.isMilapGold ? '∞' : '${user.heartsBalance}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Notifications with Badge
                  _HeaderActionBtn(
                    icon: Icons.notifications_none_rounded,
                    onTap: onOpenNotifications,
                    hasBadge: true,
                  ),
                  const SizedBox(width: 12),

                  // Sent Requests
                  _HeaderActionBtn(
                    icon: Icons.send_rounded,
                    onTap: onOpenSentRequests,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool hasBadge;

  const _HeaderActionBtn({
    required this.icon,
    this.onTap,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textMain, size: 22),
          ),
          if (hasBadge)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
