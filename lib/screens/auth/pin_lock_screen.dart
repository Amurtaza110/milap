import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PinLockScreen extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onVerify;
  final Function(UserProfile) onUpdateUser;
  final String? mode; // 'setup' | 'verify' | 'change'
  final VoidCallback? onCancelChange;

  const PinLockScreen({
    Key? key,
    required this.user,
    required this.onVerify,
    required this.onUpdateUser,
    this.mode,
    this.onCancelChange,
  }) : super(key: key);

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _pin = '';
  bool _error = false;
  String _confirmPin = '';
  String _oldPin = '';
  late String _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode =
        widget.mode ?? (widget.user.appPin != null ? 'verify' : 'setup');
  }

  void _handleDigitPress(String digit) {
    if (_pin.length < 4) {
      setState(() => _pin += digit);
      if (_pin.length == 4) {
        Future.delayed(
            const Duration(milliseconds: 200), () => _processPin(_pin));
      }
    }
  }

  void _processPin(String inputPin) {
    if (_currentMode == 'verify') {
      if (inputPin == widget.user.appPin) {
        widget.onVerify();
      } else {
        _triggerError();
      }
    } else if (_currentMode == 'setup') {
      if (_confirmPin.isEmpty) {
        setState(() {
          _confirmPin = inputPin;
          _pin = '';
        });
      } else {
        if (inputPin == _confirmPin) {
          widget.onUpdateUser(widget.user.copyWith(appPin: inputPin));
          widget.onVerify();
        } else {
          _triggerError();
          setState(() {
            _pin = '';
            _confirmPin = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PINs did not match.')));
        }
      }
    } else if (_currentMode == 'change') {
      if (_oldPin.isEmpty) {
        if (inputPin == widget.user.appPin) {
          setState(() {
            _oldPin = inputPin;
            _pin = '';
          });
        } else {
          _triggerError();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Incorrect Old PIN.')));
        }
      } else if (_confirmPin.isEmpty) {
        setState(() {
          _confirmPin = inputPin;
          _pin = '';
        });
      } else {
        if (inputPin == _confirmPin) {
          widget.onUpdateUser(widget.user.copyWith(appPin: inputPin));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN Changed Successfully!')));
          if (widget.onCancelChange != null) {
            widget.onCancelChange!();
          } else {
            widget.onVerify();
          }
        } else {
          _triggerError();
          setState(() {
            _pin = '';
            _confirmPin = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PINs did not match.')));
        }
      }
    }
  }

  void _triggerError() {
    setState(() => _error = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted)
        setState(() {
          _error = false;
          _pin = '';
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_currentMode == 'change' && widget.onCancelChange != null)
            Positioned(
                top: 64,
                left: 32,
                child: TextButton(
                    onPressed: widget.onCancelChange,
                    child: Text('Cancel',
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.textExtraLight,
                            fontWeight: FontWeight.bold)))),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20)
                          ]),
                      child: const Icon(Icons.lock_rounded,
                          color: Colors.white, size: 36)),
                  const SizedBox(height: 32),
                  Text(_getHeaderText(),
                      style: AppTextStyles.h2.copyWith(
                          fontSize: 24,
                          color: AppColors.textMain,
                          letterSpacing: -1.0)),
                  Text('MILAP SECURITY',
                      style: AppTextStyles.label.copyWith(
                          fontSize: 9,
                          color: AppColors.textExtraLight,
                          letterSpacing: 2.0)),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        4,
                        (index) => Container(
                            margin: const EdgeInsets.all(12),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                                color: _pin.length > index
                                    ? (_error ? Colors.red : AppColors.primary)
                                    : Colors.transparent,
                                border: Border.all(
                                    color: _pin.length > index
                                        ? (_error
                                            ? Colors.red
                                            : AppColors.primary)
                                        : AppColors.border,
                                    width: 2),
                                shape: BoxShape.circle))),
                  ),
                  const SizedBox(height: 64),
                  _buildNumpad(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHeaderText() {
    if (_currentMode == 'change') {
      if (_oldPin.isEmpty) return 'Enter Old PIN';
      if (_confirmPin.isNotEmpty) return 'Confirm New PIN';
      return 'Enter New PIN';
    }
    if (_currentMode == 'setup') {
      if (_confirmPin.isNotEmpty) return 'Confirm PIN';
      return 'Create PIN';
    }
    return 'Enter PIN';
  }

  Widget _buildNumpad() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 24, mainAxisSpacing: 24),
      itemCount: 12,
      itemBuilder: (context, index) {
        if (index == 9) return const SizedBox.shrink();
        if (index == 10) return _buildNumButton('0');
        if (index == 11)
          return IconButton(
              onPressed: () => setState(() => _pin =
                  _pin.isNotEmpty ? _pin.substring(0, _pin.length - 1) : ''),
              icon: Icon(Icons.backspace_rounded,
                  color: AppColors.textExtraLight));
        return _buildNumButton((index + 1).toString());
      },
    );
  }

  Widget _buildNumButton(String n) {
    return GestureDetector(
      onTap: () => _handleDigitPress(n),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24)),
        child: Center(
            child: Text(n,
                style: AppTextStyles.h2
                    .copyWith(fontSize: 24, color: AppColors.textMain))),
      ),
    );
  }
}
