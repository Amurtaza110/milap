import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/social_event.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class EventTicketManagementScreen extends StatefulWidget {
  final SocialEvent event;
  final VoidCallback onBack;

  const EventTicketManagementScreen({
    Key? key,
    required this.event,
    required this.onBack,
  }) : super(key: key);

  @override
  State<EventTicketManagementScreen> createState() =>
      _EventTicketManagementScreenState();
}

class _EventTicketManagementScreenState
    extends State<EventTicketManagementScreen> {
  final List<Map<String, dynamic>> _mockAttendees = [
    {
      'name': 'Zayan Malik',
      'whatsapp': '+92 300 1234567',
      'package': 'VIP Pass',
      'date': 'Oct 12, 2023',
      'isGift': false,
      'status': 'Verified',
      'avatar': 'https://i.pravatar.cc/150?img=60'
    },
    {
      'name': 'Ibrahim Shah',
      'whatsapp': '+92 321 7654321',
      'package': 'Early Bird',
      'date': 'Oct 13, 2023',
      'isGift': true,
      'giftFrom': 'Sara Ahmed',
      'status': 'Pending',
      'avatar': 'https://i.pravatar.cc/150?img=61'
    },
    {
      'name': 'Fatima Zehra',
      'whatsapp': '+92 333 9988776',
      'package': 'Standard',
      'date': 'Oct 14, 2023',
      'isGift': false,
      'status': 'Verified',
      'avatar': 'https://i.pravatar.cc/150?img=62'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Column(
        children: [
          _buildHeader(),
          _buildStats(),
          Expanded(child: _buildAttendeesList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.event.title,
                    style: AppTextStyles.h3
                        .copyWith(color: Colors.white, fontSize: 18)),
                Text('TICKET MANAGEMENT',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontSize: 9,
                        letterSpacing: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStatCard('SOLD', '128', Colors.blue),
          const SizedBox(width: 12),
          _buildStatCard('PENDING', '12', Colors.orange),
          const SizedBox(width: 12),
          _buildStatCard('GIFTS', '08', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.h2.copyWith(color: color, fontSize: 24)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _mockAttendees.length,
      itemBuilder: (context, index) {
        final attendee = _mockAttendees[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.milapPlusSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(attendee['avatar']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(attendee['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.whatsapp,
                            color: Colors.green, size: 12),
                        const SizedBox(width: 4),
                        Text(attendee['whatsapp'],
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                    if (attendee['isGift'])
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Gift from: ${attendee['giftFrom']}',
                            style: const TextStyle(
                                color: Colors.purpleAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: attendee['status'] == 'Verified'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(attendee['status'],
                        style: TextStyle(
                            color: attendee['status'] == 'Verified'
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(attendee['package'],
                      style:
                          const TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
