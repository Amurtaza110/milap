import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_button_styles.dart';
import '../../services/image_upload_service.dart';

class StatusUploadScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String, String, String) onUpload;

  const StatusUploadScreen({
    Key? key,
    required this.onBack,
    required this.onUpload,
  }) : super(key: key);

  @override
  State<StatusUploadScreen> createState() => _StatusUploadScreenState();
}

class _StatusUploadScreenState extends State<StatusUploadScreen> {
  String? _selectedFile;
  String _fileType = 'image';
  final _captionController = TextEditingController();
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _selectedFile = picked.path;
        _fileType = 'image';
      });
    }
  }

  void _handlePost() {
    if (_selectedFile == null || _isUploading) return;

    setState(() => _isUploading = true);

    ImageUploadService().uploadImage(_selectedFile!).then((url) {
      widget.onUpload(url, _captionController.text, _fileType);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload status: $e')),
      );
    }).whenComplete(() {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Display
          Center(
            child: _selectedFile == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white24, width: 2)),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white54, size: 40),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('SELECT MEDIA',
                          style: AppTextStyles.label.copyWith(
                              color: Colors.white54,
                              fontSize: 10,
                              letterSpacing: 2.0)),
                    ],
                  )
                : Image.file(
                    File(_selectedFile!),
                    fit: BoxFit.contain,
                  ),
          ),

          // Header
          Positioned(
            top: 64,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: widget.onBack,
                    icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                            color: Colors.black26, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white))),
                ElevatedButton(
                  onPressed: _selectedFile == null || _isUploading
                      ? null
                      : _handlePost,
                  style: AppButtonStyles.primary.copyWith(
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12)),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('POST',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
              ],
            ),
          ),

          // Footer
          if (_selectedFile != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black, Colors.transparent])),
                child: TextField(
                  controller: _captionController,
                  style: AppTextStyles.body.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Add a caption...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
