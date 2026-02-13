import 'package:flutter/material.dart';
import '../../services/mock_data_service.dart';
import '../../models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SentRequestsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SentRequestsScreen({
    Key? key,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final requests = MockDataService().getSentRequests();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 24),
            decoration: const BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                    bottom: BorderSide(color: AppColors.background))),
            child: Row(
              children: [
                IconButton(
                    onPressed: onBack,
                    icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18))),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sent Requests',
                        style: AppTextStyles.h3.copyWith(letterSpacing: -0.5)),
                    Text('TRACK YOUR CONNECTIONS',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: requests.isEmpty
                ? Center(
                    child: Text('NO REQUESTS SENT YET',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textExtraLight)))
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.background),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2))
                            ]),
                        child: Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(req.targetPhoto,
                                    width: 56, height: 56, fit: BoxFit.cover)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(req.targetName,
                                      style: AppTextStyles.base.copyWith(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14)),
                                  Text(
                                      DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(
                                                  req.timestamp.toString()))
                                          .toIso8601String()
                                          .split('T')[0]
                                          .toUpperCase(),
                                      style: AppTextStyles.label.copyWith(
                                          color: AppColors.textMuted)),
                                ])),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                  color: _getStatusColor(req.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: _getStatusColor(req.status)
                                          .withOpacity(0.2))),
                              child: Text(
                                  req.status
                                      .toString()
                                      .split('.')
                                      .last
                                      .toUpperCase(),
                                  style: AppTextStyles.label.copyWith(
                                      fontSize: 9,
                                      color: _getStatusColor(req.status))),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.Accepted:
        return AppColors.success;
      case RequestStatus.Rejected:
        return AppColors.error;
      case RequestStatus.Pending:
      default:
        return AppColors.warning;
    }
  }
}
