import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_button_styles.dart';
import '../../services/mock_data_service.dart';
import '../../services/image_upload_service.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(UserProfile) onComplete;
  final String phoneNumber;
  final String uid;

  const OnboardingScreen({
    Key? key,
    required this.onComplete,
    required this.phoneNumber,
    required this.uid,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 1;
  final PageController _pageController = PageController();
  final ImageUploadService _uploadService = ImageUploadService();
  bool _isSaving = false;

  // Form State
  String _name = '';
  String _partner2Name = '';
  Gender _gender = Gender.Female;
  Gender _partner2Gender = Gender.Male;
  DateTime? _dob;
  DateTime? _partner2Dob;
  String _city = MockDataService.pakistaniCities[0];
  String _bio = '';
  List<String> _interests = [];
  bool _isCouple = false;
  String _photo = 'https://picsum.photos/id/64/800/1200';
  final ImagePicker _picker = ImagePicker();

  Future<void> _handleNext() async {
    if (_step == 1) {
      if (_name.isEmpty || _dob == null) {
        _showError("Please enter Name and Date of Birth.");
        return;
      }
      if (_isCouple && (_partner2Name.isEmpty || _partner2Dob == null)) {
        _showError("Please enter Partner's Name and Date of Birth.");
        return;
      }
    }

    if (_step < 4) {
      setState(() => _step++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      setState(() => _isSaving = true);
      try {
        // Step 1: Upload Photo to Firebase Storage (Real user ready)
        String photoUrl = _photo;
        if (!_photo.startsWith('http')) {
           photoUrl = await _uploadService.uploadImage(_photo, 'profiles');
        }

        // Step 2: Create Profile Object
        final userProfile = UserProfile(
          id: widget.uid,
          name: _isCouple ? '$_name & $_partner2Name' : _name,
          partner2Name: _isCouple ? _partner2Name : null,
          age: _calculateAge(_dob!),
          partner2Age: _isCouple ? _calculateAge(_partner2Dob!) : null,
          gender: _gender,
          partner2Gender: _isCouple ? _partner2Gender : null,
          dob: _dob!.toIso8601String(),
          partner2Dob: _isCouple ? _partner2Dob!.toIso8601String() : null,
          location: _city,
          bio: _bio,
          interests: _interests,
          photos: [photoUrl],
          isOnline: true,
          rating: 5.0,
          reviewsCount: 0,
          isCouple: _isCouple,
          type: _isCouple ? UserType.Couple : UserType.Individual,
          isVerified: false,
          reviews: [],
          lookingForDates: true,
          isDeactivated: false,
          heartsBalance: 10,
          lastHeartRefill: DateTime.now().toIso8601String().split('T')[0],
        );

        widget.onComplete(userProfile);
      } catch (e) {
        _showError("Failed to save profile. Please try again.");
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) age--;
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // Progress Header
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 64, 32, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _step / 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '$_step/4',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.primary, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleNext,
                    style: AppButtonStyles.primary,
                    child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_step == 4 ? 'COMPLETE MILAP' : 'CONTINUE'),
                  ),
                ),
              ),
            ],
          ),
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Setting up your profile...", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identity Core',
              style: AppTextStyles.h1.copyWith(color: AppColors.textMain)),
          Text('Legally verify your account status',
              style: AppTextStyles.label.copyWith(color: AppColors.textLight)),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                  child: _IdentityCard(
                      title: 'Solo Soul',
                      icon: '👤',
                      selected: !_isCouple,
                      onTap: () => setState(() => _isCouple = false))),
              const SizedBox(width: 16),
              Expanded(
                  child: _IdentityCard(
                      title: 'Power Couple',
                      icon: '👫',
                      selected: _isCouple,
                      onTap: () => setState(() => _isCouple = true))),
            ],
          ),
          const SizedBox(height: 32),
          _buildProfileForm(1,
              title: _isCouple ? 'Primary Partner' : 'Main Profile'),
          if (_isCouple) ...[
            const SizedBox(height: 24),
            _buildProfileForm(2, title: 'Secondary Partner'),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileForm(int index, {required String title}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: index == 1 ? AppColors.primary : AppColors.textMain,
                    shape: BoxShape.circle),
                child: Center(
                    child: Text('$index',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.textMain)),
                  Text('DETAILS',
                      style: AppTextStyles.label.copyWith(
                          fontSize: 9, color: AppColors.textExtraLight)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _TextField(
            label: 'LEGAL NAME',
            hint: 'e.g. Ayesha Khan',
            onChanged: (v) =>
                setState(() => index == 1 ? _name = v : _partner2Name = v),
          ),
          const SizedBox(height: 24),
          _GenderPicker(
            label: 'GENDER IDENTITY',
            selected: index == 1 ? _gender : _partner2Gender,
            onSelect: (g) =>
                setState(() => index == 1 ? _gender = g : _partner2Gender = g),
          ),
          const SizedBox(height: 24),
          _DatePicker(
            label: 'DATE OF BIRTH',
            value: index == 1 ? _dob : _partner2Dob,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1960),
                lastDate:
                    DateTime.now().subtract(const Duration(days: 365 * 18)),
              );
              if (picked != null)
                setState(
                    () => index == 1 ? _dob = picked : _partner2Dob = picked);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vibe Check',
              style: AppTextStyles.h1.copyWith(color: AppColors.textMain)),
          const SizedBox(height: 32),
          Text('CURRENT CITY',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.textExtraLight, letterSpacing: 2.0)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _city,
                isExpanded: true,
                onChanged: (v) => setState(() => _city = v!),
                items: MockDataService.pakistaniCities
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c,
                            style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain))))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _BioField(
            value: _bio,
            onChanged: (v) => setState(() => _bio = v),
          ),
          const SizedBox(height: 100), // Extra space for keyboard
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final passions = [
      '📸 Art',
      '🥘 Food',
      '✈️ Travel',
      '🎵 Music',
      '☕ Chai',
      '🏏 Cricket',
      '🎮 Gaming',
      '🏃 Fitness',
      '🎬 Movies',
      '🎤 Karaoke'
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Passions',
              style: AppTextStyles.h1.copyWith(color: AppColors.textMain)),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: passions.map((p) {
              final active = _interests.contains(p);
              return GestureDetector(
                onTap: () => setState(
                    () => active ? _interests.remove(p) : _interests.add(p)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5))
                          ]
                        : null,
                  ),
                  child: Text(
                    p.toUpperCase(),
                    style: AppTextStyles.label.copyWith(
                        fontSize: 10,
                        color: active ? Colors.white : AppColors.textLight,
                        letterSpacing: 1.2),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 100), // Extra space at bottom
        ],
      ),
    );
  }

  Widget _buildStep4() {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = (screenWidth * 0.6).clamp(200.0, 280.0);
    final imageHeight = imageWidth * 1.33; // Maintain 3:4 aspect ratio

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text('Profile Visual',
              style: AppTextStyles.h1.copyWith(color: AppColors.textMain)),
          Text('Select your best first impression',
              style: AppTextStyles.label.copyWith(color: AppColors.textLight)),
          const SizedBox(height: 48),
          Center(
            child: GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                width: imageWidth,
                height: imageHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  image: DecorationImage(
                    image: _photo.startsWith('http')
                        ? NetworkImage(_photo)
                        : FileImage(File(_photo)) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.25)),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 100), // Extra space at bottom
        ],
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _photo = picked.path);
    }
  }
}

class _IdentityCard extends StatelessWidget {
  final String title;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  const _IdentityCard(
      {required this.title,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.background,
              width: 2),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.background,
                  shape: BoxShape.circle),
              child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(height: 12),
            Text(title.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                    fontSize: 10,
                    color:
                        selected ? AppColors.primary : AppColors.textExtraLight,
                    letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final Function(String) onChanged;

  const _TextField(
      {required this.label, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.label
                .copyWith(color: AppColors.textExtraLight, letterSpacing: 2.0)),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none)),
        ),
      ],
    );
  }
}

class _GenderPicker extends StatelessWidget {
  final String label;
  final Gender selected;
  final Function(Gender) onSelect;

  const _GenderPicker(
      {required this.label, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.label
                .copyWith(color: AppColors.textExtraLight, letterSpacing: 2.0)),
        const SizedBox(height: 8),
        Row(
          children: [Gender.Male, Gender.Female, Gender.Other].map((g) {
            final active = selected == g;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              active ? AppColors.primary : AppColors.background,
                          width: 2),
                    ),
                    child: Center(
                        child: Text(g.name,
                            style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                color: active
                                    ? Colors.white
                                    : AppColors.textExtraLight))),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DatePicker(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.label
                .copyWith(color: AppColors.textExtraLight, letterSpacing: 2.0)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16)),
            child: Text(
              value == null
                  ? 'Select Date'
                  : '${value!.day}/${value!.month}/${value!.year}',
              style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: value == null
                      ? AppColors.textExtraLight
                      : AppColors.textMain),
            ),
          ),
        ),
      ],
    );
  }
}

class _BioField extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const _BioField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('YOUR STORY (BIO)',
                style: AppTextStyles.label.copyWith(
                    color: AppColors.textExtraLight, letterSpacing: 2.0)),
            Text('${value.length}/250',
                style: AppTextStyles.label
                    .copyWith(fontSize: 10, color: AppColors.textExtraLight)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: onChanged,
          maxLines: 5,
          maxLength: 250,
          decoration: InputDecoration(
            hintText: 'What makes you unique?',
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
