import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:milap/models/room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milap/providers/user_provider.dart';
import 'package:milap/services/room_service.dart';
import 'package:milap/theme/app_colors.dart';
import 'package:milap/theme/app_text_styles.dart';

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
  final RoomService _roomService = RoomService();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      setState(() => _isSaving = true);

      try {
        final docRef = await _roomService.createRoom(
          _nameController.text.trim(),
          _descriptionController.text.trim(),
          user.id,
          user.photos.isNotEmpty ? user.photos[0] : null,
        );
        final newRoom = Room(
          id: docRef.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          creatorId: user.id,
          members: [user.id],
          createdAt: Timestamp.now(),
        );
        widget.onCreate(newRoom);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to launch room: $e')),
        );
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
                        _buildInputSection(
                          'ROOM NAME',
                          _nameController,
                          hint: "What's the vibe?",
                          icon: Icons.edit_note_rounded,
                        ),
                        const SizedBox(height: 24),
                        _buildInputSection(
                          'DESCRIPTION',
                          _descriptionController,
                          hint: 'Tell people what makes this room special...',
                          icon: Icons.description_rounded,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
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
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Room',
                  style: AppTextStyles.h2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'HOST YOUR OWN VIBE',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.milapPlusPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.milapPlusPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.milapPlusPrimary.withOpacity(0.2)),
            ),
            child: const Icon(Icons.stars_rounded, color: AppColors.milapPlusPrimary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(
    String label,
    TextEditingController controller, {
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
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
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.milapPlusPrimary.withOpacity(0.7),
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: AppColors.milapPlusPrimary, size: 22),
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 12,
          shadowColor: AppColors.milapPlusPrimary.withOpacity(0.3),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
                'LAUNCH ROOM',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
      ),
    );
  }
}
