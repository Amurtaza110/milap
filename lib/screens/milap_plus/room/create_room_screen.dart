import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/room.dart';
import '../../../providers/user_provider.dart';
import '../../../services/room_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class CreateRoomScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(Room room) onCreate;

  const CreateRoomScreen({
    Key? key,
    required this.onBack,
    required this.onCreate,
  }) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pinController = TextEditingController();
  final RoomService _roomService = RoomService();

  RoomCategory _selectedCategory = RoomCategory.General;
  bool _isPublic = true;
  int _maxParticipants = 50;
  bool _requirePin = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<UserProvider>(context, listen: false).user!;

      setState(() => _isSaving = true);

      final room = Room(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        hostId: user.id,
        hostName: user.name,
        hostAvatar: user.photos.isNotEmpty ? user.photos[0] : '',
        participants: [
          RoomParticipant(
            userId: user.id,
            name: user.name,
            avatar: user.photos.isNotEmpty ? user.photos[0] : '',
            joinedAt: DateTime.now(),
            isModerator: true,
          ),
        ],
        maxParticipants: _maxParticipants,
        isPublic: _isPublic,
        pinCode: _requirePin ? _pinController.text : null,
        createdAt: DateTime.now(),
      );

      try {
        await _roomService.createRoom(room);
        widget.onCreate(room);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to launch room: $e')));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.milapPlusSecondary,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputSection('ROOM NAME', _nameController,
                            hint: "What's the vibe?",
                            icon: Icons.edit_note_rounded),
                        const SizedBox(height: 24),
                        _buildInputSection('DESCRIPTION', _descriptionController,
                            hint: 'Tell people what makes this room special...',
                            icon: Icons.description_rounded,
                            maxLines: 3),
                        const SizedBox(height: 32),
                        _buildCategoryGrid(),
                        const SizedBox(height: 32),
                        _buildPrivacySection(),
                        const SizedBox(height: 32),
                        _buildCapacitySection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isSaving)
            Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 64, 12, 24),
      decoration: BoxDecoration(
        color: AppColors.milapPlusSecondary,
        border:
            Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Room',
                    style: AppTextStyles.h2.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text('HOST YOUR OWN VIBE',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.milapPlusPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.milapPlusPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.milapPlusPrimary.withOpacity(0.2)),
            ),
            child: const Icon(Icons.stars_rounded,
                color: AppColors.milapPlusPrimary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(String label, TextEditingController controller,
      {required String hint, required IconData icon, int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.milapPlusSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.label.copyWith(
                  color: AppColors.milapPlusPrimary.withOpacity(0.7),
                  fontSize: 10,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
              border: InputBorder.none,
              prefixIcon:
                  Icon(icon, color: AppColors.milapPlusPrimary, size: 22),
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16),
          child: Text('SELECT VIBE CATEGORY',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.milapPlusPrimary.withOpacity(0.7),
                  fontSize: 10,
                  letterSpacing: 2)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: RoomCategory.values.length,
          itemBuilder: (context, index) {
            final cat = RoomCategory.values[index];
            final isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.milapPlusPrimary
                      : AppColors.milapPlusSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: isSelected
                          ? AppColors.milapPlusPrimary
                          : Colors.white.withOpacity(0.05)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color:
                                  AppColors.milapPlusPrimary.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8))
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getCategoryIcon(cat),
                        color: isSelected ? Colors.black : Colors.white38,
                        size: 24),
                    const SizedBox(height: 8),
                    Text(cat.name.toUpperCase(),
                        style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white38,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getCategoryIcon(RoomCategory category) {
    switch (category) {
      case RoomCategory.Dating:
        return Icons.favorite_rounded;
      case RoomCategory.Friendship:
        return Icons.handshake_rounded;
      case RoomCategory.Events:
        return Icons.celebration_rounded;
      case RoomCategory.General:
        return Icons.forum_rounded;
    }
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16),
          child: Text('ACCESS SETTINGS',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.milapPlusPrimary.withOpacity(0.7),
                  fontSize: 10,
                  letterSpacing: 2)),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.milapPlusSurface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(
            children: [
              _buildPrivacyButton(
                  'PUBLIC',
                  Icons.public_rounded,
                  _isPublic,
                  () => setState(() {
                        _isPublic = true;
                        _requirePin = false;
                      })),
              _buildPrivacyButton('PRIVATE', Icons.lock_rounded, !_isPublic,
                  () => setState(() => _isPublic = false)),
            ],
          ),
        ),
        if (!_isPublic) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.milapPlusSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Row(
              children: [
                Icon(Icons.shield_rounded,
                    color: AppColors.milapPlusPrimary, size: 22),
                const SizedBox(width: 12),
                const Expanded(
                    child: Text('Require Join PIN',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                Switch(
                  value: _requirePin,
                  onChanged: (v) => setState(() => _requirePin = v),
                  activeColor: AppColors.milapPlusPrimary,
                ),
              ],
            ),
          ),
          if (_requirePin) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: AppColors.milapPlusSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: AppColors.milapPlusPrimary.withOpacity(0.3))),
              child: TextFormField(
                controller: _pinController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: AppColors.milapPlusPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '••••',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.1))),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildPrivacyButton(
      String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: active ? AppColors.milapPlusPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: active ? Colors.black : Colors.white24, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: active ? Colors.black : Colors.white24,
                      fontWeight: FontWeight.w900,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapacitySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: AppColors.milapPlusSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Room Capacity',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.milapPlusPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('$_maxParticipants',
                    style: const TextStyle(
                        color: AppColors.milapPlusPrimary,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Slider(
            value: _maxParticipants.toDouble(),
            min: 5,
            max: 100,
            activeColor: AppColors.milapPlusPrimary,
            inactiveColor: Colors.white10,
            onChanged: (v) => setState(() => _maxParticipants = v.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.milapPlusSecondary,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _createRoom,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.milapPlusPrimary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 64),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 12,
          shadowColor: AppColors.milapPlusPrimary.withOpacity(0.3),
        ),
        child: _isSaving
          ? const CircularProgressIndicator(color: Colors.black)
          : const Text('LAUNCH ROOM',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
    );
  }
}
