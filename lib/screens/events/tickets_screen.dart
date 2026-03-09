import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket.dart';
import '../../providers/user_provider.dart';
import '../../services/event_service.dart';
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
  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                          Text('My Tickets',
                              style: AppTextStyles.h2.copyWith(
                                  color: AppColors.textMain)),
                          Text('EVENTS & PASSES',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.primary))
                        ]),
                  ],
                ),
              ),

              Expanded(
                child: StreamBuilder<List<Ticket>>(
                  stream: _eventService.streamUserTickets(user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final tickets = snapshot.data ?? [];

                    if (tickets.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.confirmation_num_outlined, size: 64, color: AppColors.textExtraLight),
                            const SizedBox(height: 16),
                            Text('NO TICKETS BOUGHT YET',
                                style: AppTextStyles.label.copyWith(color: AppColors.textExtraLight)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return _buildTicketItem(ticket);
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

  Widget _buildTicketItem(Ticket ticket) {
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
              // Left side: Visual ID
              Container(
                width: 100,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
                ),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Center(
                    child: Text(ticket.qrCode,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
              ),

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
                              child: Text(ticket.eventTitle,
                                  style: AppTextStyles.h4
                                      .copyWith(color: AppColors.textMain),
                                  overflow: TextOverflow.ellipsis)),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(ticket.status.name.toUpperCase(),
                                  style: AppTextStyles.label.copyWith(
                                      color: AppColors.success,
                                      fontSize: 8))),
                        ],
                      ),
                      Row(children: [
                        Icon(AppIcons.location,
                            size: 12, color: AppColors.textExtraLight),
                        const SizedBox(width: 4),
                        Text(ticket.eventLocation.toUpperCase(),
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
                                Text(ticket.packageName,
                                    style: AppTextStyles.body.copyWith(
                                        color: AppColors.textMain,
                                        fontSize: 12))
                              ]),
                          Text(ticket.eventDate, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }
}
