import 'package:flutter/material.dart';
import '../models/app_screen.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';

class Navigation extends StatelessWidget {
  final AppScreen activeScreen;
  final Function(AppScreen) onNavigate;

  const Navigation({
    Key? key,
    required this.activeScreen,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMilapPlus = [
      AppScreen.HOOKUP_MODE,
      AppScreen.ROOMS,
      AppScreen.ACTIVE_ROOM,
      AppScreen.CREATE_ROOM
    ].contains(activeScreen);

    final backgroundColor =
        isMilapPlus ? AppColors.milapPlusSecondary : AppColors.primary;
    final activeColor = isMilapPlus ? AppColors.milapPlusPrimary : Colors.white;
    final inactiveColor =
        isMilapPlus ? Colors.white24 : Colors.white.withOpacity(0.6);

    final tabs = [
      _NavTab(id: AppScreen.DASHBOARD, label: 'Feed', icon: AppIcons.dashboard),
      _NavTab(id: AppScreen.EVENTS, label: 'Events', icon: AppIcons.events),
      _NavTab(
          id: AppScreen.HOOKUP_MODE, label: 'Milap+', icon: AppIcons.hookup),
      _NavTab(id: AppScreen.MESSAGES, label: 'Inbox', icon: AppIcons.messages),
      _NavTab(id: AppScreen.PROFILE, label: 'Me', icon: AppIcons.profile),
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = activeScreen == tab.id;
          return Expanded(
            child: InkWell(
              onTap: () => onNavigate(tab.id),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        color: isActive ? activeColor : inactiveColor,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tab.label,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 8,
                          color: isActive ? activeColor : inactiveColor,
                          fontWeight:
                              isActive ? FontWeight.w900 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (isActive)
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavTab {
  final AppScreen id;
  final String label;
  final IconData icon;

  _NavTab({required this.id, required this.label, required this.icon});
}
