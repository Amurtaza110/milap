import 'dart:io';
import 'package:flutter/material.dart';
import 'package:milap/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/social_event.dart';
import '../../models/enums.dart';
import '../../providers/user_provider.dart';
import '../../services/event_service.dart';
import '../../services/image_upload_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_icons.dart';

class CreateEventScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(SocialEvent) onSave;
  final SocialEvent? initialEvent;

  const CreateEventScreen({
    Key? key,
    required this.onBack,
    required this.onSave,
    this.initialEvent,
  }) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _promoCodeController = TextEditingController();

  String _category = 'Party';
  String _environment = 'Indoor';
  String _city = 'Karachi';

  List<Map<String, dynamic>> _packageData = [
    {'name': '', 'price': '', 'quantity': ''}
  ];

  bool _goldOnly = false;
  bool _allowGifting = false;
  String? _coverImagePath;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();
  final EventService _eventService = EventService();
  final ImageUploadService _uploadService = ImageUploadService();

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      _titleController.text = widget.initialEvent!.title;
      _descriptionController.text = widget.initialEvent!.description;
      _category = widget.initialEvent!.eventType.name;
      _environment = widget.initialEvent!.environment.name;
      _city = widget.initialEvent!.location;
      _goldOnly = widget.initialEvent!.accessLevel == AccessLevel.Gold;
      _allowGifting = widget.initialEvent!.allowGifting ?? false;
      _promoCodeController.text = widget.initialEvent!.promoCode ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() => _coverImagePath = image.path);
    }
  }

  Future<void> _handlePublish() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Description are required')));
      return;
    }

    final user = Provider.of<UserProvider>(context, listen: false).user!;
    setState(() => _isSaving = true);

    try {
      String coverUrl = 'https://picsum.photos/800/600'; // Default
      if (_coverImagePath != null) {
        coverUrl = await _uploadService.uploadImage(_coverImagePath!, 'events');
      }

      final event = SocialEvent(
        id: widget.initialEvent?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        organizerId: user.id,
        organizerName: user.name,
        organizerAvatar: user.photos.isNotEmpty ? user.photos[0] : '',
        organizerRating: user.rating,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        eventType: EventType.values.firstWhere((e) => e.name == _category, orElse: () => EventType.Party),
        environment: EventEnvironment.values.firstWhere((e) => e.name == _environment, orElse: () => EventEnvironment.Indoor),
        location: _city,
        date: DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0], // Default 1 week from now
        time: '08:00 PM',
        rules: ['No outside food', 'Respect others'],
        media: [coverUrl],
        accessLevel: _goldOnly ? AccessLevel.Gold : AccessLevel.Public,
        allowGifting: _allowGifting,
        promoCode: _promoCodeController.text.isNotEmpty ? _promoCodeController.text : null,
        packages: _packageData.map((p) => EventPackage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: p['name'].toString().isEmpty ? 'General' : p['name'],
          price: double.tryParse(p['price'].toString()) ?? 0.0,
          quantity: int.tryParse(p['quantity'].toString()) ?? 100,
          perks: ['Standard Entry'],
        )).toList(),
        attendeesCount: 0,
        distance: '0 km',
        reviews: [],
      );

      await _eventService.createEvent(event);
      widget.onSave(event);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addTier() {
    if (_packageData.length < 3) {
      setState(() {
        _packageData.add({'name': '', 'price': '', 'quantity': ''});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.milapPlusTheme,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildCoverUpload(),
                        const SizedBox(height: 40),
                        _buildMainInfo(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('BASIC INFO'),
                        const SizedBox(height: 16),
                        _buildBasicInfoSelectors(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('TICKETING'),
                        const SizedBox(height: 16),
                        ..._packageData.asMap().entries.map((entry) => _buildPackageField(entry.key)).toList(),
                        if (_packageData.length < 3)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(onPressed: _addTier, child: const Text('+ Add Tier')),
                          ),
                        _buildPromoAndGifting(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('ACCESS'),
                        const SizedBox(height: 16),
                        _buildAccessToggle(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isSaving)
              Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: widget.onBack,
              icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                  child: Icon(AppIcons.back, size: 18, color: Colors.white))),
          Column(children: [
            Text('MILAP+ STUDIO', style: AppTextStyles.label.copyWith(color: AppColors.milapPlusPrimary, letterSpacing: 2.0)),
            Text('NEW EVENT', style: AppTextStyles.h4),
          ]),
          ElevatedButton(
              onPressed: _isSaving ? null : _handlePublish,
              child: const Text('PUBLISH', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCoverUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.25,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
            image: _coverImagePath != null ? DecorationImage(image: FileImage(File(_coverImagePath!)), fit: BoxFit.cover) : null,
            border: Border.all(color: Colors.white10)),
        child: _coverImagePath == null ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(AppIcons.add, color: Colors.white24, size: 48),
              const SizedBox(height: 16),
              Text('UPLOAD COVER', style: AppTextStyles.label.copyWith(color: Colors.white24, letterSpacing: 2.0))
            ]) : null,
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          textAlign: TextAlign.center,
          style: AppTextStyles.h1.copyWith(fontSize: 28),
          decoration: const InputDecoration(hintText: 'Event Title', border: InputBorder.none),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          style: AppTextStyles.body.copyWith(fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Short description of your event...',
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSelectors() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStudioSelect('Category', _category, ['Party', 'Dance', 'Food', 'Chill'])),
            const SizedBox(width: 12),
            Expanded(child: _buildStudioSelect('Environment', _environment, ['Indoor', 'Outdoor', 'Virtual'])),
          ],
        ),
        const SizedBox(height: 12),
        _buildStudioSelect('City', _city, ['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi']),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(children: [
      Container(width: 4, height: 16, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: AppColors.milapPlusPrimary, borderRadius: BorderRadius.circular(2))),
      Text(title, style: AppTextStyles.label.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold))
    ]);
  }

  Widget _buildStudioSelect(String label, String value, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.label.copyWith(color: AppColors.milapPlusPrimary, fontSize: 9, letterSpacing: 0.5)),
          DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF222222),
            underline: const SizedBox.shrink(),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 20),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            onChanged: (v) => setState(() {
              if (v != null) {
                if (label == 'Category') _category = v;
                else if (label == 'Environment') _environment = v;
                else _city = v;
              }
            }),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageField(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('TIER ${index + 1}', style: AppTextStyles.label.copyWith(color: Colors.white30, fontSize: 10)),
            if (_packageData.length > 1)
              IconButton(onPressed: () => setState(() => _packageData.removeAt(index)), icon: const Icon(Icons.close, size: 18, color: Colors.redAccent))
          ]),
          TextField(
            onChanged: (v) => _packageData[index]['name'] = v,
            decoration: const InputDecoration(hintText: 'Pass Name (e.g. VIP)', border: InputBorder.none)
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildInnerInput('Price (PKR)', (v) => _packageData[index]['price'] = v)),
              const SizedBox(width: 16),
              Expanded(child: _buildInnerInput('Quantity', (v) => _packageData[index]['quantity'] = v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInnerInput(String label, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.label.copyWith(color: Colors.white30, fontSize: 9)),
          TextField(
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true)
          ),
        ],
      ),
    );
  }

  Widget _buildPromoAndGifting() {
    return Column(
      children: [
        TextField(controller: _promoCodeController, decoration: const InputDecoration(labelText: 'DISCOUNT CODE (Optional)')),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          value: _allowGifting,
          onChanged: (v) => setState(() => _allowGifting = v),
          activeColor: AppColors.milapPlusPrimary,
          title: const Text('Allow Gifting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildAccessToggle() {
    return Row(
      children: [
        Expanded(child: _buildToggleBtn('PUBLIC', Icons.public_rounded, !_goldOnly, () => setState(() => _goldOnly = false))),
        const SizedBox(width: 12),
        Expanded(child: _buildToggleBtn('MILAP+', Icons.stars_rounded, _goldOnly, () => setState(() => _goldOnly = true))),
      ],
    );
  }

  Widget _buildToggleBtn(String label, IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.milapPlusPrimary : Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? AppColors.milapPlusPrimary : Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? Colors.black : Colors.white24),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.label.copyWith(fontSize: 10, color: active ? Colors.black : Colors.white24)),
          ],
        ),
      ),
    );
  }
}
