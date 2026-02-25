import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/offre_model.dart';
import '../models/candidature_model.dart';
import '../models/message_model.dart';

/// Service Firestore : users, jobs, applications, favorites.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _jobs =>
      _firestore.collection('jobs');
  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('applications');
  CollectionReference<Map<String, dynamic>> get _favorites =>
      _firestore.collection('favorites');
  CollectionReference<Map<String, dynamic>> get _messages =>
      _firestore.collection('messages');

  // ---------- USERS ----------
  Future<void> setUser(AppUser user) async {
    await _users.doc(user.id).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<AppUser?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // ---------- JOBS ----------
  Future<String> addJob(Offre job) async {
    final ref = await _jobs.add(job.toMap());
    return ref.id;
  }

  Future<void> updateJob(String id, Map<String, dynamic> data) async {
    await _jobs.doc(id).update(data);
  }

  Future<void> deleteJob(String id) async {
    await _jobs.doc(id).delete();
  }

  Future<Offre?> getJob(String id) async {
    final doc = await _jobs.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Offre.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<Offre>> getJobsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final List<Offre> result = [];
    for (final id in ids) {
      final job = await getJob(id);
      if (job != null) result.add(job);
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Stream des offres. Aucun orderBy Firestore pour éviter tout index composite ; tri en mémoire.
  Stream<List<Offre>> jobsStream({String? recruiterId}) {
    final Query<Map<String, dynamic>> query;
    if (recruiterId != null && recruiterId.isNotEmpty) {
      query = _jobs.where('recruiterId', isEqualTo: recruiterId);
    } else {
      query = _jobs;
    }
    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => Offre.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Récupère les offres (filtres et tri en mémoire pour éviter tout index Firestore).
  Future<List<Offre>> getJobs({
    String? titleQuery,
    String? locationQuery,
    String? typeQuery,
    String? domainQuery,
  }) async {
    final snap = await _jobs.get();
    var list = snap.docs.map((d) => Offre.fromMap(d.data(), d.id)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (titleQuery != null && titleQuery.isNotEmpty) {
      final t = titleQuery.toLowerCase();
      list = list.where((o) => o.title.toLowerCase().contains(t)).toList();
    }
    if (locationQuery != null && locationQuery.isNotEmpty) {
      final loc = locationQuery.toLowerCase();
      list = list.where((o) => o.location.toLowerCase().contains(loc)).toList();
    }
    if (typeQuery != null && typeQuery.isNotEmpty) {
      list = list.where((o) => o.type.name == typeQuery).toList();
    }
    if (domainQuery != null && domainQuery.isNotEmpty) {
      final d = domainQuery.toLowerCase();
      list = list.where((o) {
        if (o.skills.any((s) => s.toLowerCase().contains(d))) return true;
        if (o.companyName != null &&
            o.companyName!.toLowerCase().contains(d)) return true;
        return false;
      }).toList();
    }
    return list;
  }

  // ---------- APPLICATIONS ----------
  Future<String> addApplication(Candidature app) async {
    final ref = await _applications.add(app.toMap());
    return ref.id;
  }

  Future<void> updateApplicationStatus(
      String id, CandidatureStatus status) async {
    await _applications.doc(id).update({'status': status.name});
  }

  Future<void> deleteApplication(String id) async {
    await _applications.doc(id).delete();
  }

  Future<bool> hasApplied(String candidateId, String jobId) async {
    final snap = await _applications
        .where('candidateId', isEqualTo: candidateId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Sans index composite : where + tri en mémoire.
  Stream<List<Candidature>> applicationsByCandidate(String candidateId) {
    return _applications
        .where('candidateId', isEqualTo: candidateId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => Candidature.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<Candidature>> applicationsByJob(String jobId) {
    return _applications
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => Candidature.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<List<Candidature>> applicationsByRecruiter(String recruiterId) async {
    final snap = await _applications
        .where('recruiterId', isEqualTo: recruiterId)
        .get();
    final list = snap.docs
        .map((d) => Candidature.fromMap(d.data(), d.id))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<int> getJobCountByRecruiter(String recruiterId) async {
    final snap =
        await _jobs.where('recruiterId', isEqualTo: recruiterId).get();
    return snap.docs.length;
  }

  // ---------- FAVORITES ----------
  Future<void> addFavorite(String userId, String jobId) async {
    await _favorites.doc('${userId}_$jobId').set({
      'userId': userId,
      'jobId': jobId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String userId, String jobId) async {
    await _favorites.doc('${userId}_$jobId').delete();
  }

  Future<bool> isFavorite(String userId, String jobId) async {
    final doc = await _favorites.doc('${userId}_$jobId').get();
    return doc.exists;
  }

  Stream<List<String>> favoritesStream(String userId) {
    return _favorites
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => d.data()['jobId'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toList());
  }

  // ---------- MESSAGES (conversations candidature acceptée) ----------
  Future<void> sendMessage(ChatMessage message) async {
    await _messages.add(message.toMap());
  }

  /// Flux des messages d'une candidature (tri en mémoire pour éviter index composite).
  Stream<List<ChatMessage>> messagesStream(String candidatureId) {
    return _messages
        .where('candidatureId', isEqualTo: candidatureId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => ChatMessage.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }
}
