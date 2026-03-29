import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';


class FloatingNotificationBar extends StatefulWidget {
  final String title;
  final String message;
  final String? type; // e.g. 'proposal', 'system'
  final VoidCallback onDismiss;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const FloatingNotificationBar({
    Key? key,
    required this.title,
    required this.message,
    required this.onDismiss,
    this.type,
    this.onAccept,
    this.onReject,
    this.onTap,
  }) : super(key: key);

  @override
  State<FloatingNotificationBar> createState() => _FloatingNotificationBarState();
}

class _FloatingNotificationBarState extends State<FloatingNotificationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, -1.0), end: const Offset(0.0, 0.0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto-dismiss system notifications after 5 seconds.
    // Proposals require interaction.
    if (widget.type != 'proposal') {
      _timer = Timer(const Duration(seconds: 5), _dismiss);
    }
  }

  void _dismiss() {
    _timer?.cancel();
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isProposal = widget.type == 'proposal';

    return SlideTransition(
      position: _offsetAnimation,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
            border: Border.all(
                color: isProposal
                    ? AppColors.milapPlusPrimary
                    : AppColors.primary.withOpacity(0.5),
                width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.onTap ?? _dismiss,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isProposal
                            ? AppColors.milapPlusPrimary.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isProposal ? Icons.favorite_rounded : Icons.notifications_active_rounded,
                        color: isProposal
                            ? AppColors.milapPlusPrimary
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                          if (isProposal) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      widget.onReject?.call();
                                      _dismiss();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white10,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      widget.onAccept?.call();
                                      _dismiss();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.milapPlusPrimary,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text(
                                      'Accept',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                    if (!isProposal)
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white54, size: 20),
                        onPressed: _dismiss,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
