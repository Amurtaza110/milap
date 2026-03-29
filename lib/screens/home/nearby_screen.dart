import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/user_service.dart';

class NearbyScreen extends StatefulWidget {
  final UserProfile user;

  const NearbyScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  String _viewMode = 'map'; // 'map' | 'list'
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Content
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(32, 64, 32, 24),
                decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.8),
                    border:
                        Border(bottom: BorderSide(color: AppColors.border))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RADAR',
                            style: AppTextStyles.h1
                                .copyWith(color: AppColors.textMain)),
                        Row(
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('REAL-TIME PROXIMITY',
                                style: AppTextStyles.label.copyWith(
                                    color: AppColors.textMuted,
                                    letterSpacing: 1.5)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color:
                                  AppColors.textExtraLight.withOpacity(0.5))),
                      child: Row(
                        children: [
                          _buildToggleOption('map', 'Map'),
                          _buildToggleOption('list', 'List'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _viewMode == 'map'
                    ? _buildIncognitoView()
                    : StreamBuilder<List<UserProfile>>(
                        stream: _userService.streamSocialFeed(
                          preferredCity: widget.user.location,
                          excludeUid: widget.user.id,
                        ),
                        builder: (context, snapshot) {
                          final blocked = widget.user.blockedUserIds ?? const <String>[];
                          final filteredProfiles = (snapshot.data ?? const <UserProfile>[])
                              .where((p) => !blocked.contains(p.id))
                              .toList();

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          return _buildListView(filteredProfiles);
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String mode, String label) {
    final isActive = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ]
                : null),
        child: Text(label.toUpperCase(),
            style: AppTextStyles.label.copyWith(
                fontSize: 9,
                color: isActive ? AppColors.primary : AppColors.textMuted,
                letterSpacing: 1.0)),
      ),
    );
  }

  Widget _buildIncognitoView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🕵️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text('Incognito Active',
                style: AppTextStyles.h2.copyWith(color: AppColors.textMain)),
            const SizedBox(height: 12),
            Text(
                'You have hidden your radar location in profile settings. Switch it on to see who is nearby on the map.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textLight, fontSize: 12, height: 1.6)),
            const SizedBox(height: 32),
            ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    elevation: 0),
                child: Text('ENABLE RADAR',
                    style: AppTextStyles.label.copyWith(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Map Placeholder (In a real app, use google_maps_flutter)
        Container(
            color: AppColors.background,
            child: Center(
                child: Text('MAP AREA',
                    style: AppTextStyles.h1.copyWith(
                        color: AppColors.textExtraLight,
                        fontSize: 40,
                        letterSpacing: 5)))),
        // Pulsing "Me" icon
        Center(
            child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 10)
                    ]),
                child: Center(
                    child: Text('ME',
                        style: AppTextStyles.label
                            .copyWith(color: Colors.white, fontSize: 10))))),
      ],
    );
  }

  Widget _buildListView(List<UserProfile> profiles) {
    if (profiles.isEmpty)
      return Center(
          child: Text('No souls detected nearby',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textMuted, fontSize: 12)));

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final p = profiles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(p.photos[0],
                          width: 96, height: 96, fit: BoxFit.cover)),
                  if (p.isOnline)
                    Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                                color: AppColors.online,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2)))),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${p.name.split(' ')[0]}, ${p.age}',
                            style: AppTextStyles.h3.copyWith(
                                color: AppColors.textMain,
                                fontSize: 18,
                                letterSpacing: -0.5)),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text('${0.4 + index * 0.3} km',
                                style: AppTextStyles.label.copyWith(
                                    color: AppColors.primary, fontSize: 8))),
                      ],
                    ),
                    Text(p.location.toUpperCase(),
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.textExtraLight, fontSize: 9)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0),
                        child: Center(
                            child: Text('CONNECT SOUL',
                                style: AppTextStyles.label.copyWith(
                                    color: Colors.white,
                                    fontSize: 9,
                                    letterSpacing: 1.0)))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
