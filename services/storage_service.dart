import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<List<String>> uploadMultipleImages(List<File> images, String basePath) async {
    List<String> urls = [];
    for (int i = 0; i < images.length; i++) {
      final url = await uploadImage(images[i], '$basePath/image_$i.jpg');
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    final path = 'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadImage(imageFile, path);
  }

  Future<String?> uploadProductImage(File imageFile, String productId, int index) async {
    final path = 'products/$productId/image_$index.jpg';
    return await uploadImage(imageFile, path);
  }

  Future<List<String>> uploadProductImages(List<File> images, String productId) async {
    return await uploadMultipleImages(images, 'products/$productId');
  }

  Future<String?> uploadChatImage(File imageFile, String chatId, String messageId) async {
    final path = 'chats/$chatId/messages/$messageId.jpg';
    return await uploadImage(imageFile, path);
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<void> deleteFolder(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final listResult = await ref.listAll();
      
      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      print('Error deleting folder: $e');
    }
  }

  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<List<File>> pickMultipleImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    return pickedFiles.map((file) => File(file.path)).toList();
  }
}