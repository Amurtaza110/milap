import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

/// Service for handling real image uploads to Firebase Storage for $0 cost
class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  factory ImageUploadService() {
    return _instance;
  }

  ImageUploadService._internal();

  /// Compress image before upload to save storage costs
  Future<File?> _compressImage(String path) async {
    final tempDir = await path_provider.getTemporaryDirectory();
    final targetPath = p.join(tempDir.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 70, // High quality, low size
      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : null;
  }

  /// Upload image to Firebase Storage and return the public URL
  Future<String> uploadImage(String imagePath, String folder) async {
    try {
      if (imagePath.startsWith('http')) return imagePath;

      // 1. Compress locally
      File? compressedFile = await _compressImage(imagePath);
      final File fileToUpload = compressedFile ?? File(imagePath);

      // 2. Prepare reference
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(folder).child(fileName);

      // 3. Start upload
      final UploadTask uploadTask = ref.putFile(
        fileToUpload,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      
      // 4. Cleanup temporary compressed file
      if (compressedFile != null && await compressedFile.exists()) {
        await compressedFile.delete();
      }

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Firebase Storage Error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Firebase Storage Delete Error: $e');
    }
  }
}
