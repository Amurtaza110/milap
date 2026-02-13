import 'package:flutter/material.dart';
import 'package:milap/theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_icons.dart';

class CreateEventScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onSave;
  final dynamic initialEvent;

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
  String _category = 'Party';
  String _environment = 'Indoor';
  String _city = 'Karachi';
  List<Map<String, dynamic>> _packages = [
    {'name': '', 'price': '', 'quantity': ''}
  ];
  bool _isVirtual = false;
  bool _goldOnly = false;
  bool _allowGifting = false;
  final _promoCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      _titleController.text = widget.initialEvent.title;
      _descriptionController.text = widget.initialEvent.description;
      // ... populate other fields if needed
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  void _addTier() {
    if (_packages.length < 3) {
      setState(() {
        _packages.add({'name': '', 'price': '', 'quantity': ''});
      });
    }
  }

  void _removeTier(int index) {
    if (_packages.length > 1) {
      setState(() {
        _packages.removeAt(index);
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
            // Background Gradient Ambience
            Positioned(
                top: -100,
                right: -100,
                child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        color: AppColors.milapPlusPrimary.withOpacity(0.1),
                        shape: BoxShape.circle))),

            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: widget.onBack,
                          icon: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Icon(AppIcons.back,
                                  size: 18, color: Colors.white))),
                      Column(children: [
                        Text(
                          'MILAP+ STUDIO',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.milapPlusPrimary,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          'NEW EVENT',
                          style: AppTextStyles.h4,
                        ),
                      ]),
                      ElevatedButton(
                          onPressed: () =>
                              widget.onSave({'title': _titleController.text}),
                          child: Text('PUBLISH',
                              style: AppTextStyles.label
                                  .copyWith(letterSpacing: 1.5))),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Cover Upload Area
                        Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: Colors.white10)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(AppIcons.add,
                                    color: Colors.white24, size: 48),
                                const SizedBox(height: 16),
                                Text('UPLOAD COVER',
                                    style: AppTextStyles.label.copyWith(
                                        color: Colors.white24,
                                        letterSpacing: 2.0))
                              ]),
                        ),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _titleController,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1.copyWith(fontSize: 28),
                          decoration: const InputDecoration(
                            hintText: 'Event Title',
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: AppTextStyles.body.copyWith(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Short description of your event...',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle('BASIC INFO'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _buildStudioSelect('Category', _category,
                                    ['Party', 'Dance', 'Food', 'Chill'])),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStudioSelect(
                                  'Environment',
                                  _environment,
                                  ['Indoor', 'Outdoor', 'Virtual']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStudioSelect(
                            'City', _city, ['Karachi', 'Lahore', 'Islamabad']),
                        const SizedBox(height: 16),
                        _buildVirtualOptions(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('TICKETING'),
                        const SizedBox(height: 16),
                        ..._packages
                            .asMap()
                            .entries
                            .map((entry) => _buildPackageField(entry.key))
                            .toList(),
                        if (_packages.length < 3)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _addTier,
                              child: Text('+ Add Tier'),
                            ),
                          ),
                        const SizedBox(height: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(children: [
      Container(
        width: 4,
        height: 16,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
            color: AppColors.milapPlusPrimary,
            borderRadius: BorderRadius.circular(2)),
      ),
      Text(title,
          style: AppTextStyles.label
              .copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold))
    ]);
  }

  Widget _buildStudioSelect(String label, String value, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTextStyles.label.copyWith(
                  color: AppColors.milapPlusPrimary,
                  fontSize: 9,
                  letterSpacing: 0.5)),
          DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF222222),
            underline: const SizedBox.shrink(),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white54, size: 20),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            onChanged: (v) => setState(() {
              if (v != null) {
                if (label == 'Category')
                  _category = v;
                else if (label == 'Environment')
                  _environment = v;
                else
                  _city = v;
              }
            }),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageField(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('TIER ${index + 1}',
                style: AppTextStyles.label
                    .copyWith(color: Colors.white30, fontSize: 10)),
            if (_packages.length > 1)
              IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _removeTier(index),
                  icon: const Icon(Icons.close,
                      size: 18, color: Colors.redAccent))
          ]),
          const SizedBox(height: 16),
          const TextField(
              decoration: InputDecoration(
                  hintText: 'Pass Name (e.g. VIP)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInnerInput('Price (PKR)')),
              const SizedBox(width: 16),
              Expanded(child: _buildInnerInput('Quantity')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInnerInput(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTextStyles.label
                  .copyWith(color: Colors.white30, fontSize: 9)),
          const TextField(
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 8))),
        ],
      ),
    );
  }

  Widget _buildVirtualOptions() {
    _isVirtual = _environment == 'Virtual';
    if (!_isVirtual) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VIRTUAL EVENT OPTIONS',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.milapPlusPrimary,
                  fontSize: 9,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(
            'This event will be broadcast live to all ticket holders.',
            style: AppTextStyles.body.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.live_tv_rounded, color: Colors.redAccent, size: 16),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Milap+ Studio will generate a live room for this event.',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoAndGifting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _promoCodeController,
          decoration: const InputDecoration(
            labelText: 'DISCOUNT CODE',
            hintText: 'Enter code (Optional)',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: SwitchListTile.adaptive(
            value: _allowGifting,
            onChanged: (v) => setState(() => _allowGifting = v),
            activeColor: AppColors.milapPlusPrimary,
            title: const Text('Allow Gifting',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Guests can buy tickets for others',
                style: TextStyle(fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessToggle() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _goldOnly = false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: !_goldOnly
                      ? AppColors.milapPlusPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.public_rounded,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'PUBLIC',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _goldOnly = true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _goldOnly ? Colors.amber[700] : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'MILAP+',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
