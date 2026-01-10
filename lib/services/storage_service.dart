import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Simple storage helper to upload profile images to Firebase Storage.
/// Files are stored under /user_photos/{uid}.jpg
class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadProfileImage(String uid, File file) async {
    final ref = _storage.ref().child('user_photos').child('$uid.jpg');
    final task = await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }
}