import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/social_event.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_button_styles.dart';
import '../../services/event_service.dart';
import '../../providers/user_provider.dart';

class MyEventsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(SocialEvent) onEditEvent;
  final Function(SocialEvent) onManageTickets;

  const MyEventsScreen({
    Key? key,
    required this.onBack,
    required this.onEditEvent,
    required this.onManageTickets,
  }) : super(key: key);

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  String _activeTab = 'Upcoming';
  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          // Background Gradient Ambience
          Positioned(
              top: -100,
              left: -100,
              child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      shape: BoxShape.circle))),
          Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle))),

          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: widget.onBack,
                            icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16)),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18,
                                    color: Colors.white))),
                        const SizedBox(width: 16),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Event Command',
                                  style: AppTextStyles.h2.copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                      letterSpacing: -0.5)),
                              Text('MANAGEMENT CONSOLE',
                                  style: AppTextStyles.label.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 8,
                                      letterSpacing: 2.0))
                            ]),
                      ],
                    ),
                    Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.analytics_outlined,
                            color: Colors.white30, size: 20)),
                  ],
                ),
              ),

              // Tabs
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      _buildTab('Upcoming'),
                      _buildTab('Past'),
                    ],
                  ),
                ),
              ),

              // Event List
              Expanded(
                child: StreamBuilder<List<SocialEvent>>(
                  stream: _eventService.streamMyEvents(user.id),
                  builder: (context, snapshot) {
                    final myEvents = snapshot.data ?? const <SocialEvent>[];
                    final filteredEvents = _activeTab == 'Upcoming' ? myEvents : const <SocialEvent>[];

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (filteredEvents.isEmpty) {
                      return Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('📭', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('NO EVENTS FOUND',
                            style: AppTextStyles.label.copyWith(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 10,
                                letterSpacing: 2.0))
                      ]));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return _buildEventCard(event);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    final isActive = _activeTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10)
                    ]
                  : null),
          child: Center(
              child: Text(label.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                      color: isActive ? Colors.white : Colors.white38,
                      fontSize: 10,
                      letterSpacing: 1.0))),
        ),
      ),
    );
  }

  Widget _buildEventCard(SocialEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(35)),
                  child: Image.network(event.media[0],
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.6))),
              Container(
                  height: 160,
                  decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(35)),
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.transparent]))),
              Positioned(
                  bottom: 16,
                  left: 24,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title,
                            style: AppTextStyles.h3
                                .copyWith(color: Colors.white, fontSize: 18)),
                        Text('${event.date} • ${event.location.toUpperCase()}',
                            style: AppTextStyles.label.copyWith(
                                color: Colors.white54,
                                fontSize: 9,
                                letterSpacing: 1.0))
                      ])),
              if (event.isPromoted ?? false)
                Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('PROMOTED',
                            style: AppTextStyles.label
                                .copyWith(color: Colors.white, fontSize: 8)))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ATTENDANCE',
                              style: AppTextStyles.label.copyWith(
                                  color: Colors.white38,
                                  fontSize: 8,
                                  letterSpacing: 1.5)),
                          Text('${event.attendeesCount}',
                              style: AppTextStyles.h2
                                  .copyWith(color: Colors.white, fontSize: 18))
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('REVENUE',
                              style: AppTextStyles.label.copyWith(
                                  color: Colors.white38,
                                  fontSize: 8,
                                  letterSpacing: 1.5)),
                          Text(
                              'PKR ${IntFormatting((event.attendeesCount * event.packages[0].price).round()).toLocaleString()}',
                              style: AppTextStyles.h2
                                  .copyWith(color: Colors.white, fontSize: 18))
                        ]),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () => widget.onEditEvent(event),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18))),
                            child: const Text('EDIT',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0)))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () => widget.onManageTickets(event),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18))),
                            child: const Text('MANAGE',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0)))),
                    if (event.isPromoted == false ||
                        event.isPromoted == null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {},
                              style: AppButtonStyles.primary.copyWith(
                                padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 14)),
                                shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18))),
                              ),
                              child: const Text('PROMOTE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0)))),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension IntFormatting on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
