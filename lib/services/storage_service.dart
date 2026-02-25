import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Service Firebase Storage pour photos et fichiers (CV).
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadPhoto(String userId, File file) async {
    final ref = _storage.ref().child('users/$userId/photo_${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String?> uploadCv(String userId, File file) async {
    final ref = _storage.ref().child('users/$userId/cv_${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String?> uploadCompanyLogo(String userId, File file) async {
    final ref = _storage.ref().child('companies/$userId/logo_${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
