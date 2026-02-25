import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class FavoritesController extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<String> _jobIds = [];
  bool _loading = false;
  String? _error;

  List<String> get favoriteJobIds => _jobIds;
  bool get loading => _loading;
  String? get error => _error;

  void listenFavorites(String userId) {
    _firestore.favoritesStream(userId).handleError((_, __) {}).listen((ids) {
      _jobIds = ids;
      notifyListeners();
    });
  }

  Future<void> addFavorite(String userId, String jobId) async {
    _error = null;
    try {
      await _firestore.addFavorite(userId, jobId);
      if (!_jobIds.contains(jobId)) {
        _jobIds = [..._jobIds, jobId];
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String userId, String jobId) async {
    _error = null;
    try {
      await _firestore.removeFavorite(userId, jobId);
      _jobIds = _jobIds.where((id) => id != jobId).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  bool isFavorite(String jobId) => _jobIds.contains(jobId);

  Future<bool> toggleFavorite(String userId, String jobId) async {
    if (isFavorite(jobId)) {
      await removeFavorite(userId, jobId);
      return false;
    } else {
      await addFavorite(userId, jobId);
      return true;
    }
  }
}
