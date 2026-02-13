import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_button_styles.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;
  final Function(UserProfile) onSave;
  final VoidCallback onBack;

  const EditProfileScreen({
    Key? key,
    required this.user,
    required this.onSave,
    required this.onBack,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late UserProfile _formData;
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formData = widget.user;
    _nameController.text = _formData.name;
    _bioController.text = _formData.bio;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name cannot be empty.')));
      return;
    }
    widget.onSave(_formData.copyWith(
      name: _nameController.text,
      bio: _bioController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            Text('My Profile',
                style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    fontSize: 18,
                    color: AppColors.textMain)),
            Text('UPDATE IDENTITY',
                style: AppTextStyles.label.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.5)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.textMain)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            child: ElevatedButton(
              onPressed: _handleSave,
              style: AppButtonStyles.primary.copyWith(
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16)),
                elevation: WidgetStateProperty.all(10),
                shadowColor:
                    WidgetStateProperty.all(AppColors.primary.withOpacity(0.4)),
              ),
              child: const Text('SAVE',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.0)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Gallery
            _buildSectionHeader('PHOTO GALLERY',
                '${_formData.photos.length}/${_formData.isMilapGold ? 10 : 5}'),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75),
                  itemCount: _formData.photos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _formData.photos.length) {
                      return _buildAddMediaButton('PHOTO');
                    }
                    final photo = _formData.photos[index];
                    final isHidden =
                        (_formData.hiddenMediaIds ?? []).contains(photo);
                    return _buildMediaItem(photo,
                        isMain: index == 0,
                        isHidden: isHidden, onToggleHide: () {
                      List<String> hidden =
                          List.from(_formData.hiddenMediaIds ?? []);
                      if (hidden.contains(photo))
                        hidden.remove(photo);
                      else
                        hidden.add(photo);
                      setState(() => _formData =
                          _formData.copyWith(hiddenMediaIds: hidden));
                    }, onDelete: () {
                      if (_formData.photos.length <= 1) return;
                      List<String> photos = List.from(_formData.photos);
                      photos.removeAt(index);
                      setState(
                          () => _formData = _formData.copyWith(photos: photos));
                    }, onSetMain: () {
                      if (index == 0) return;
                      List<String> photos = List.from(_formData.photos);
                      final temp = photos[0];
                      photos[0] = photos[index];
                      photos[index] = temp;
                      setState(
                          () => _formData = _formData.copyWith(photos: photos));
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('VIDEO REELS',
                '${(_formData.videos ?? []).length}/${_formData.isMilapGold ? 5 : 2}'),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5),
                  itemCount: (_formData.videos ?? []).length + 1,
                  itemBuilder: (context, index) {
                    if (index == (_formData.videos ?? []).length) {
                      return _buildAddMediaButton('VIDEO');
                    }
                    final video = _formData.videos![index];
                    return Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Center(
                            child: Icon(Icons.videocam_rounded,
                                color: Colors.white24, size: 32)));
                  },
                );
              },
            ),

            const SizedBox(height: 48),
            _buildInputField('LEGAL NAME', _nameController, hint: 'Full Name'),
            const SizedBox(height: 32),
            _buildSectionHeader('GENDER IDENTITY', ''),
            const SizedBox(height: 12),
            Row(
              children: [Gender.Male, Gender.Female, Gender.Other]
                  .map((g) => Expanded(
                      child: _buildChoiceButton(
                          g.name.toUpperCase(),
                          _formData.gender == g,
                          () => setState(() =>
                              _formData = _formData.copyWith(gender: g)))))
                  .toList(),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('HOME CITY', ''),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _formData.location,
                  isExpanded: true,
                  onChanged: (v) => setState(
                      () => _formData = _formData.copyWith(location: v)),
                  items: MockDataService.pakistaniCities
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c,
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textMain))))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildInputField('THE STORY (BIO)', _bioController,
                hint: 'Tell your soul\'s story...', maxLines: 5),
            const SizedBox(height: 48),
            _buildSectionHeader('PASSIONS & VIBES', ''),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: MockDataService.mockProfiles[0].interests.map((p) {
                final active = _formData.interests.contains(p);
                return GestureDetector(
                  onTap: () {
                    List<String> interests = List.from(_formData.interests);
                    if (active)
                      interests.remove(p);
                    else
                      interests.add(p);
                    setState(() =>
                        _formData = _formData.copyWith(interests: interests));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                        color:
                            active ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                    color: AppColors.primary.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ]
                            : null),
                    child: Text(p.toUpperCase(),
                        style: AppTextStyles.label.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: active
                                ? Colors.white
                                : AppColors.textExtraLight,
                            letterSpacing: 1.0)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.label.copyWith(
                fontSize: 10, color: AppColors.primary, letterSpacing: 2.0)),
        if (count.isNotEmpty)
          Text(count,
              style: AppTextStyles.label
                  .copyWith(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }

  Widget _buildMediaItem(String url,
      {required bool isMain,
      required bool isHidden,
      required VoidCallback onToggleHide,
      required VoidCallback onDelete,
      required VoidCallback onSetMain}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
            ],
          ),
        ),
        if (isHidden)
          Container(
              decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20)),
              child: const Center(
                  child:
                      Icon(Icons.lock_rounded, color: Colors.white, size: 24))),
        if (isMain)
          Positioned(
              top: 8,
              left: 8,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('MAIN',
                      style: AppTextStyles.label
                          .copyWith(color: Colors.white, fontSize: 8)))),
        // Simple controls overlay on long press or similar could be added, but for now we use an icon menu
        Positioned(
          top: 4,
          right: 4,
          child: PopupMenuButton(
            icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.more_vert_rounded,
                    size: 16, color: AppColors.textMain)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            itemBuilder: (context) => [
              PopupMenuItem(
                  onTap: onToggleHide,
                  child: Text(isHidden ? 'Unhide' : 'Hide')),
              if (!isMain)
                PopupMenuItem(
                    onTap: onSetMain, child: const Text('Set as Main')),
              PopupMenuItem(
                  onTap: onDelete,
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddMediaButton(String label) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.border, style: BorderStyle.none, width: 2)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: AppColors.textExtraLight, size: 32),
            Text('ADD $label',
                style: AppTextStyles.label.copyWith(
                    fontSize: 8,
                    color: AppColors.textExtraLight,
                    letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(label, ''),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textMain),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.body.copyWith(color: AppColors.textExtraLight),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceButton(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              boxShadow: active
                  ? [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]
                  : null),
          child: Text(label,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: active ? Colors.white : AppColors.textExtraLight,
                  letterSpacing: 1.5)),
        ),
      ),
    );
  }
}
