import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  static Future<String> uploadProfileImage(File image, String userId) async {
    try {
      final fileName =
          'profiles/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final reference = _storage.ref().child(fileName);

      await reference.putFile(image);
      final downloadUrl = await reference.getDownloadURL();

      print('✅ Profile image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Pick image from gallery
  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Take photo from camera
  static Future<File?> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Delete old profile image
  static Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final reference = _storage.refFromURL(imageUrl);
      await reference.delete();
      print('✅ Old profile image deleted');
    } catch (e) {
      print('⚠️ Could not delete old image: $e');
    }
  }
}
