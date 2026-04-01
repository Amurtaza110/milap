import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_icons.dart';
import '../../models/user_profile.dart';
import '../../services/vault_sharing_service.dart';

class WalletScreen extends StatefulWidget {
  final UserProfile user;
  final Function(UserProfile) onUpdateUser;
  final VoidCallback onBack;

  const WalletScreen({
    super.key,
    required this.user,
    required this.onUpdateUser,
    required this.onBack,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isAuthenticated = false;
  String _pinEntry = '';
  String _view = 'folders'; // 'folders' | 'assets'
  PrivateFolder? _activeFolder;
  String _setupStep = 'initial'; // 'initial' | 'confirm'
  String _tempPin = '';
  bool _error = false;
  final TextEditingController _shareController = TextEditingController();

  void _handlePinSubmit(String currentPin) {
    if (widget.user.vaultPin == null) {
      if (_setupStep == 'initial') {
        setState(() {
          _tempPin = currentPin;
          _pinEntry = '';
          _setupStep = 'confirm';
        });
      } else {
        if (currentPin == _tempPin) {
          widget.onUpdateUser(widget.user.copyWith(vaultPin: currentPin));
          setState(() => _isAuthenticated = true);
        } else {
          setState(() {
            _error = true;
            _pinEntry = '';
            _setupStep = 'initial';
          });
          Future.delayed(const Duration(milliseconds: 500),
              () => setState(() => _error = false));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PINs do not match.')));
        }
      }
    } else if (currentPin == widget.user.vaultPin) {
      setState(() => _isAuthenticated = true);
    } else {
      setState(() {
        _error = true;
        _pinEntry = '';
      });
      Future.delayed(const Duration(milliseconds: 500),
          () => setState(() => _error = false));
    }
  }

  void _addDigit(String digit) {
    if (_pinEntry.length < 4) {
      setState(() => _pinEntry += digit);
      if (_pinEntry.length == 4) {
        Future.delayed(const Duration(milliseconds: 200),
            () => _handlePinSubmit(_pinEntry));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) return _buildPinLock();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 24),
            decoration: const BoxDecoration(
                color: AppColors.surface,
                border:
                    Border(bottom: BorderSide(color: AppColors.background))),
            child: Row(
              children: [
                IconButton(
                    onPressed: _view == 'assets'
                        ? () => setState(() => _view = 'folders')
                        : widget.onBack,
                    icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(AppIcons.back,
                            size: 18, color: AppColors.textMain))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          _view == 'folders'
                              ? 'Media Vault'
                              : _activeFolder?.name ?? '',
                          style: AppTextStyles.h2
                              .copyWith(color: AppColors.textMain)),
                      Text('ENCRYPTED STORAGE',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                if (_view == 'folders')
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: Text('New Vault Folder',
                                style: AppTextStyles.h3
                                    .copyWith(color: AppColors.textMain)),
                            content: const TextField(
                              decoration: InputDecoration(
                                  hintText: 'Folder Name',
                                  filled: true,
                                  fillColor: Colors.white),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Create')),
                            ],
                          ),
                        );
                      },
                      icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(AppIcons.add,
                              color: Colors.white, size: 20))),
              ],
            ),
          ),

          Expanded(
            child:
                _view == 'folders' ? _buildFoldersGrid() : _buildAssetsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildPinLock() {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned(
              top: 64,
              left: 32,
              child: IconButton(
                  onPressed: widget.onBack,
                  icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16)),
                      child: const Icon(AppIcons.back,
                          size: 18, color: AppColors.textMain)))),
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
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20)
                          ]),
                      child:
                          const Icon(AppIcons.lock, color: Colors.white, size: 32)),
                  const SizedBox(height: 32),
                  Text(
                      widget.user.vaultPin == null
                          ? (_setupStep == 'initial'
                              ? 'Set Vault PIN'
                              : 'Confirm PIN')
                          : 'Protocol Restricted',
                      style:
                          AppTextStyles.h2.copyWith(color: AppColors.textMain)),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        4,
                        (index) => Container(
                            margin: const EdgeInsets.all(8),
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                                color: _pinEntry.length > index
                                    ? (_error
                                        ? AppColors.error
                                        : AppColors.primary)
                                    : Colors.transparent,
                                border: Border.all(
                                    color: _pinEntry.length > index
                                        ? (_error
                                            ? AppColors.error
                                            : AppColors.primary)
                                        : AppColors.textExtraLight
                                            .withOpacity(0.3),
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

  Widget _buildNumpad() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 24, mainAxisSpacing: 24),
      itemCount: 12,
      itemBuilder: (context, index) {
        if (index == 9) {
          return IconButton(
              onPressed: () => setState(() => _pinEntry = ''),
              icon: const Icon(AppIcons.close, color: AppColors.error));
        }
        if (index == 10) return _buildNumButton('0');
        if (index == 11) {
          return IconButton(
              onPressed: widget.onBack,
              icon: const Icon(AppIcons.back, color: AppColors.textExtraLight));
        }
        return _buildNumButton((index + 1).toString());
      },
    );
  }

  Widget _buildNumButton(String n) {
    return GestureDetector(
      onTap: () => _addDigit(n),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20)),
        child: Center(
            child: Text(n,
                style: AppTextStyles.h2.copyWith(color: AppColors.textMain))),
      ),
    );
  }

  Widget _buildFoldersGrid() {
    final folders = widget.user.vaultFolders ?? [];
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        return GestureDetector(
          onTap: () => setState(() {
            _activeFolder = folder;
            _view = 'assets';
          }),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: AppColors.background)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.folder_rounded, color: AppColors.primary, size: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(folder.name,
                        style: AppTextStyles.h4
                            .copyWith(color: AppColors.textMain)),
                    Text('${folder.assetIds.length} FILES',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textExtraLight)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssetsGrid() {
    final assetIds = _activeFolder?.assetIds ?? [];
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: assetIds.length + 1,
      itemBuilder: (context, index) {
        if (index == assetIds.length) {
          return Container(
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.background, style: BorderStyle.none)),
              child: Icon(Icons.add_a_photo_rounded,
                  color: AppColors.textExtraLight));
        }
        final asset = (widget.user.vaultAssets ?? [])
            .firstWhere((a) => a.id == assetIds[index]);
        return GestureDetector(
          onLongPress: () => _showAssetMenu(asset),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                      image: NetworkImage(asset.url), fit: BoxFit.cover)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0),
                ),
              )),
        );
      },
    );
  }

  void _showAssetMenu(PrivateAsset asset) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share with Friend'),
              onTap: () {
                Navigator.pop(context);
                _showShareDialog(asset);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Screenshot Protection'),
              onTap: () {
                Navigator.pop(context);
                _showScreenshotProtectionDialog(asset);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(PrivateAsset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Asset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _shareController,
              decoration: InputDecoration(
                hintText: 'Enter friend ID or search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Screenshot Protection will be enabled automatically',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final recipientId = _shareController.text.trim();
              if (recipientId.isEmpty) return;

              if (!mounted) return;
              Navigator.pop(context);
              _shareController.clear();

              final sharingService = VaultSharingService();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing asset...')),
              );

              try {
                final success = await sharingService.shareVaultAsset(
                  assetId: asset.id,
                  recipientId: recipientId,
                  senderId: widget.user.id,
                  senderName: widget.user.name,
                );

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Asset shared with screenshot protection'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to share asset: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showScreenshotProtectionDialog(PrivateAsset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screenshot Protection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Protect this image from screenshots:'),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Block Screenshots'),
              subtitle: const Text('Prevent users from taking screenshots'),
              value: true,
              onChanged: (val) {},
            ),
            CheckboxListTile(
              title: const Text('Notify on Screenshot'),
              subtitle:
                  const Text('Send notification if screenshot is attempted'),
              value: true,
              onChanged: (val) {},
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⚠️ Black screenshots will be captured if screenshot is attempted',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Protection enabled')),
              );
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}
