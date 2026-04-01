import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/user_provider.dart';
import '../../services/verification_service.dart';
import '../../services/image_upload_service.dart';
import '../../models/verification_request.dart';
import '../../theme/app_colors.dart';

class VerificationScreen extends StatefulWidget {
  final VoidCallback onBack;

  const VerificationScreen({super.key, required this.onBack});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  XFile? _idFront;
  XFile? _idBack;
  XFile? _selfie;
  bool _isSubmitting = false;
  final VerificationService _verificationService = VerificationService();
  final ImageUploadService _uploadService = ImageUploadService();

  Future<void> _pickImage(Function(XFile) onSelect) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      if (mounted) setState(() => onSelect(image));
    }
  }

  Future<void> _submitRequest() async {
    if (_idFront == null || _idBack == null || _selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All three images are required.')));
      return;
    }

    setState(() => _isSubmitting = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user!;

    try {
      // 1. Upload images to Firebase Storage
      final idFrontUrl = await _uploadService.uploadImage(_idFront!.path, 'verification/${user.id}');
      final idBackUrl = await _uploadService.uploadImage(_idBack!.path, 'verification/${user.id}');
      final selfieUrl = await _uploadService.uploadImage(_selfie!.path, 'verification/${user.id}');

      // 2. Create the request object
      final request = VerificationRequest(
        id: user.id,
        userId: user.id,
        userName: user.name,
        userPhoto: user.photos.isNotEmpty ? user.photos[0] : '',
        idFrontUrl: idFrontUrl,
        idBackUrl: idBackUrl,
        selfieUrl: selfieUrl,
        createdAt: DateTime.now(),
        status: VerificationStatus.pending,
      );

      // 3. Submit to Firestore
      await _verificationService.submitRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Verification request submitted successfully!'),
          backgroundColor: Colors.green,
        ));
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Get Verified'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadBox('1. ID Card (Front)', _idFront, () => _pickImage((f) => _idFront = f)),
            const SizedBox(height: 16),
            _buildUploadBox('2. ID Card (Back)', _idBack, () => _pickImage((f) => _idBack = f)),
            const SizedBox(height: 16),
            _buildUploadBox('3. Selfie with ID', _selfie, () => _pickImage((f) => _selfie = f)),
            const SizedBox(height: 32),
            Text('Your information is used for verification purposes only and will not be shared publicly.', 
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('SUBMIT FOR VERIFICATION'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox(String title, XFile? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          image: file != null ? DecorationImage(image: FileImage(File(file.path)), fit: BoxFit.cover) : null,
        ),
        child: file == null ? Center(child: Text(title)) : null,
      ),
    );
  }
}
