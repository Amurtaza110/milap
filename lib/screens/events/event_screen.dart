import 'package:flutter/material.dart';
import '../../models/social_event.dart';
import '../../models/enums.dart';
import '../../models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/mock_data_service.dart';

class EventScreen extends StatefulWidget {
  final UserProfile user;
  final Function(SocialEvent) onEventClick;
  final VoidCallback onCreateEvent;
  final VoidCallback onBack;
  final VoidCallback? onViewTickets;

  const EventScreen({
    Key? key,
    required this.user,
    required this.onEventClick,
    required this.onCreateEvent,
    required this.onBack,
    this.onViewTickets,
  }) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  String _filter = 'All';
  final List<String> _filters = ['All', 'Dance', 'Food', 'Chill', 'Party'];

  Widget _buildPromotionCarousel(List<SocialEvent> events) {
    // Get events with promotional pricing or special offers
    final promotionEvents =
        events.where((e) => (e.isPromoted ?? false)).take(5).toList();

    if (promotionEvents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PROMOTIONS & OFFERS 🎉',
                  style: AppTextStyles.label.copyWith(
                      fontSize: 9,
                      color: AppColors.textExtraLight,
                      letterSpacing: 2.0)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('LIMITED TIME',
                    style: AppTextStyles.label.copyWith(
                        fontSize: 7,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: promotionEvents.length,
            itemBuilder: (context, index) {
              final event = promotionEvents[index];
              return GestureDetector(
                onTap: () => widget.onEventClick(event),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: NetworkImage(event.media[0]),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Special Offer Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            'SALE',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 7,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      // Event Info
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              event.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PKR ${event.packages[0].price}',
                              style: AppTextStyles.label.copyWith(
                                color: Colors.orange.shade200,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mockEvents = MockDataService().getMockEvents();
    final filteredEvents = _filter == 'All'
        ? mockEvents
        : mockEvents.where((e) => e.eventType.name == _filter).toList();
    final featuredEvents = mockEvents
        .where(
            (e) => e.accessLevel == AccessLevel.Gold || (e.isPromoted ?? false))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 24),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Events',
                        style: AppTextStyles.h1.copyWith(
                            fontSize: 32,
                            color: AppColors.textMain,
                            letterSpacing: -1.0)),
                    Text('COMMUNITY & PARTIES',
                        style: AppTextStyles.label.copyWith(
                            fontSize: 8,
                            color: AppColors.textExtraLight,
                            letterSpacing: 1.5)),
                  ],
                ),
                GestureDetector(
                  onTap: widget.onViewTickets,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.confirmation_num_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('MY TICKETS',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Section
                  if (featuredEvents.isNotEmpty) ...[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                        child: Text('✨ FEATURED EVENTS',
                            style: AppTextStyles.label.copyWith(
                                fontSize: 9,
                                color: AppColors.textExtraLight,
                                letterSpacing: 2.0))),
                    SizedBox(
                      height: 350,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: featuredEvents.length,
                        itemBuilder: (context, index) {
                          final event = featuredEvents[index];
                          return GestureDetector(
                            onTap: () => widget.onEventClick(event),
                            child: Container(
                              width: 280,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(35),
                                  image: DecorationImage(
                                      image: NetworkImage(event.media[0]),
                                      fit: BoxFit.cover)),
                              child: Stack(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(35),
                                          gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.8),
                                                Colors.transparent
                                              ]))),
                                  Positioned(
                                      top: 20,
                                      left: 20,
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Text(
                                              event.accessLevel ==
                                                      AccessLevel.Gold
                                                  ? 'GOLD ONLY'
                                                  : 'FEATURED',
                                              style: AppTextStyles.label
                                                  .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w900)))),
                                  Positioned(
                                      bottom: 24,
                                      left: 24,
                                      right: 24,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(event.title,
                                                style: AppTextStyles.h2
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        height: 1.2)),
                                            const SizedBox(height: 8),
                                            Text(
                                                '${event.date} • ${event.location.toUpperCase()}',
                                                style: AppTextStyles.label
                                                    .copyWith(
                                                        color: Colors.white70,
                                                        fontSize: 9,
                                                        letterSpacing: 1.0))
                                          ])),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Promotion Carousel
                  _buildPromotionCarousel(mockEvents),

                  // Filters
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _filters
                            .map((f) => GestureDetector(
                                  onTap: () => setState(() => _filter = f),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: _filter == f
                                            ? AppColors.primary
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: _filter == f
                                                ? AppColors.primary
                                                : AppColors.border,
                                            width: 1.5),
                                        boxShadow: _filter == f
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withOpacity(0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                )
                                              ]
                                            : []),
                                    child: Text(f.toUpperCase(),
                                        style: AppTextStyles.label.copyWith(
                                            fontSize: 9,
                                            color: _filter == f
                                                ? Colors.white
                                                : AppColors.textExtraLight,
                                            letterSpacing: 1.0)),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),

                  // Event List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return GestureDetector(
                        onTap: () => widget.onEventClick(event),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]),
                          child: Row(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(event.media[0],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event.eventType.name.toUpperCase(),
                                        style: AppTextStyles.label.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 8,
                                            letterSpacing: 1.0)),
                                    Text(event.title,
                                        style: AppTextStyles.h4.copyWith(
                                            fontSize: 14,
                                            color: AppColors.textMain)),
                                    const SizedBox(height: 4),
                                    Text(event.location,
                                        style: AppTextStyles.label.copyWith(
                                            fontSize: 9,
                                            color: AppColors.textExtraLight,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Text('PKR ${event.packages[0].price}',
                                  style: AppTextStyles.h4.copyWith(
                                      fontSize: 12, color: AppColors.textMain)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: widget.onCreateEvent,
          backgroundColor: AppColors.primary,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}
