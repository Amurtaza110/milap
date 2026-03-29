import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:milap/models/notification.dart';
import 'package:milap/widgets/notification_tile.dart';
import 'package:milap/services/notification_service.dart';
import 'package:milap/providers/user_provider.dart';

class NotificationScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Function(dynamic) onViewProfile;

  const NotificationScreen({Key? key, required this.onBack, required this.onViewProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final NotificationService notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: notificationService.getNotifications(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationTile(notification: notification);
            },
          );
        },
      ),
    );
  }
}
