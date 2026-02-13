import 'package:flutter/material.dart';
import '../../models/social_event.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_icons.dart';

class TicketsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const TicketsScreen({
    Key? key,
    required this.onBack,
  }) : super(key: key);

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final List<Map<String, dynamic>> _mockTickets = [
    {
      'id': 't1',
      'eventId': 'e1',
      'packageName': 'General Admission',
      'price': 1500,
      'isGift': false,
      'ticketId': 'MIL-8392',
      'status': 'Active'
    },
    {
      'id': 't2',
      'eventId': 'e2',
      'packageName': 'Gold Pass',
      'price': 5000,
      'isGift': true,
      'senderName': 'Zain & Sarah',
      'ticketId': 'MIL-2210',
      'status': 'Active'
    }
  ];

  @override
  Widget build(BuildContext context) {
    final mockEvents = MockDataService().getMockEvents();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Background Ambience
          Positioned(
              top: -100,
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
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.background.withOpacity(0.1)))),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: widget.onBack,
                        icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: AppColors.background.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16)),
                            child: Icon(AppIcons.back,
                                size: 18, color: AppColors.textMain))),
                    const SizedBox(width: 16),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Wallet',
                              style: AppTextStyles.h2.copyWith(
                                  color: AppColors.textMain)), // ← Line 88-89
                          Text('EVENTS & PASSES',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.primary))
                        ]),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _mockTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _mockTickets[index];
                    final event =
                        mockEvents.firstWhere((e) => e.id == ticket['eventId']);
                    return _buildTicketItem(ticket, event);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketItem(Map<String, dynamic> ticket, SocialEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 140,
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surface.withOpacity(0.1))),
      child: Stack(
        children: [
          Row(
            children: [
              // Left side: Image
              ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(24)),
                  child: Image.network(event.media[0],
                      width: 100,
                      height: 140,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.7))),

              // Right side: Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(event.title,
                                  style: AppTextStyles.h4
                                      .copyWith(color: AppColors.textMain),
                                  overflow: TextOverflow.ellipsis)),
                          if (ticket['isGift'])
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text('🎁 GIFT',
                                    style: AppTextStyles.label.copyWith(
                                        color: AppColors.success,
                                        fontSize: 8))),
                        ],
                      ),
                      Row(children: [
                        Icon(AppIcons.location,
                            size: 12, color: AppColors.textExtraLight),
                        const SizedBox(width: 4),
                        Text(event.location.split(',')[0].toUpperCase(),
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.textExtraLight, fontSize: 9))
                      ]),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PASS TYPE',
                                    style: AppTextStyles.label
                                        .copyWith(color: AppColors.primary)),
                                Text(ticket['packageName'],
                                    style: AppTextStyles.body.copyWith(
                                        color: AppColors.textMain,
                                        fontSize: 12))
                              ]),
                          Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle),
                              child: const Icon(AppIcons.next,
                                  color: Colors.white, size: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Ticket Notches
          Positioned(
              left: 92,
              top: -10,
              child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: AppColors.surface, shape: BoxShape.circle))),
          Positioned(
              left: 92,
              bottom: -10,
              child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: AppColors.surface, shape: BoxShape.circle))),
          // Dash Line
          Positioned(
              left: 101,
              top: 20,
              bottom: 20,
              child: Container(
                  width: 1,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.surface.withOpacity(0.1),
                          width: 0.5)))),
        ],
      ),
    );
  }
}
