import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Logo and Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Text(
                'Milap',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  letterSpacing: -1.0,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              // Action Buttons
              Row(
                children: [
                  // Sent Requests Button
                  _IconButton(
                    onPressed: onOpenSentRequests,
                    icon: AppIcons.send,
                    title: 'Sent Requests',
                  ),
                  const SizedBox(width: 8),

                  // Heart Counter
                  GestureDetector(
                    onTap: onOpenStore,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryLight, Color(0xFFFFE8F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.isMilapGold ? '∞' : '${user.heartsBalance}',
                            style: AppTextStyles.base.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Notifications
                  Stack(
                    children: [
                      _IconButton(
                        onPressed: onOpenNotifications,
                        icon: AppIcons.notifications,
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Divider
          Container(
            margin: const EdgeInsets.only(top: 16),
            height: 1,
            color: AppColors.background.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? title;

  const _IconButton({
    Key? key,
    this.onPressed,
    required this.icon,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: AppColors.textMain,
          ),
        ),
      ),
    );
  }
}
