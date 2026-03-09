import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/match_model.dart';
import '../../providers/user_provider.dart';
import '../../services/match_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class SentRequestsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SentRequestsScreen({
    Key? key,
    required this.onBack,
  }) : super(key: key);

  @override
  State<SentRequestsScreen> createState() => _SentRequestsScreenState();
}

class _SentRequestsScreenState extends State<SentRequestsScreen> {
  final MatchService _matchService = MatchService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 24),
            decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                    bottom: BorderSide(color: AppColors.background))),
            child: Row(
              children: [
                IconButton(
                    onPressed: widget.onBack,
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
            child: StreamBuilder<List<MatchRequest>>(
              stream: _matchService.streamSentRequests(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 48, color: AppColors.textExtraLight),
                        const SizedBox(height: 16),
                        Text('NO REQUESTS SENT YET',
                            style: AppTextStyles.label.copyWith(color: AppColors.textExtraLight)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
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
                              child: Image.network(
                                req.receiverPhoto.isNotEmpty ? req.receiverPhoto : 'https://i.pravatar.cc/150',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 56, height: 56, color: AppColors.background,
                                  child: const Icon(Icons.person),
                                ),
                              )),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                Text(req.receiverName,
                                    style: AppTextStyles.base.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14)),
                                Text(
                                    DateFormat('MMM dd, yyyy').format(req.createdAt).toUpperCase(),
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
                                req.status.name.toUpperCase(),
                                style: AppTextStyles.label.copyWith(
                                    fontSize: 9,
                                    color: _getStatusColor(req.status))),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.accepted:
        return AppColors.success;
      case MatchStatus.rejected:
        return AppColors.error;
      case MatchStatus.pending:
      default:
        return AppColors.warning;
    }
  }
}
