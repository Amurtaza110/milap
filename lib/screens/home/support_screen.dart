import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_icons.dart';
import '../../services/support_service.dart';

class SupportScreen extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onBack;

  const SupportScreen({
    Key? key,
    required this.user,
    required this.onBack,
  }) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String _category = 'Feedback';
  final _messageController = TextEditingController();
  final SupportService _supportService = SupportService();
  bool _isSubmitting = false;
  bool _submitted = false;

  void _handleSubmit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await _supportService.submitTicket(
        userId: widget.user.id,
        userName: widget.user.name,
        category: _category,
        message: message,
        isGold: widget.user.isMilapGold,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit ticket: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildSuccessView();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 24),
            decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                IconButton(
                    onPressed: widget.onBack,
                    icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16)),
                        child: Icon(AppIcons.back,
                            size: 18, color: AppColors.textMain))),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Help & Support',
                        style: AppTextStyles.h2
                            .copyWith(color: AppColors.textMain)),
                    Text('WE ARE HERE FOR YOU',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textLight)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELECT TOPIC',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textExtraLight)),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children:
                        ['Feedback', 'Report Bug', 'Billing', 'Account Safety']
                            .map((cat) => GestureDetector(
                                  onTap: () => setState(() => _category = cat),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: _category == cat
                                            ? AppColors.primary
                                            : AppColors.background,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: _category == cat
                                                ? AppColors.primary
                                                : Colors.transparent)),
                                    child: Center(
                                        child: Text(cat.toUpperCase(),
                                            style: AppTextStyles.label.copyWith(
                                                fontSize: 9,
                                                color: _category == cat
                                                    ? Colors.white
                                                    : AppColors.textLight))),
                                  ),
                                ))
                            .toList(),
                  ),
                  const SizedBox(height: 32),
                  Text('YOUR MESSAGE',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textExtraLight)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 6,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textMain, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tell us more...',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(24),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Icon(AppIcons.info, color: AppColors.info),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Text(
                                'Priority support for ${widget.user.isMilapGold ? 'Milap Gold' : 'Premium'} members. Typically replies within ${widget.user.isMilapGold ? '2 hours' : '24 hours'}.',
                                style: AppTextStyles.body.copyWith(
                                    fontSize: 11,
                                    color: AppColors.info,
                                    height: 1.4))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          child: Text(
                              _isSubmitting ? 'SENDING...' : 'SUBMIT REQUEST',
                              style: AppTextStyles.label
                                  .copyWith(color: Colors.white)))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(AppIcons.accepted,
                      color: AppColors.success, size: 40)),
              const SizedBox(height: 24),
              Text('Ticket Received!',
                  style: AppTextStyles.h2.copyWith(color: AppColors.textMain)),
              const SizedBox(height: 16),
              Text(
                  'Thank you for helping us improve Milap. Our team will review your feedback and respond shortly.',
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textLight)),
              const SizedBox(height: 40),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: widget.onBack,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: Text('BACK TO PROFILE',
                          style: AppTextStyles.label
                              .copyWith(color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }
}
