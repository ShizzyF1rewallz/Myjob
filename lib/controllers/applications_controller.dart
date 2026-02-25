import 'package:flutter/foundation.dart';
import '../models/candidature_model.dart';
import '../services/firestore_service.dart';

class ApplicationsController extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<Candidature> _candidateApplications = [];
  List<Candidature> _jobApplications = [];
  bool _loading = false;
  String? _error;

  List<Candidature> get candidateApplications => _candidateApplications;
  List<Candidature> get jobApplications => _jobApplications;
  bool get loading => _loading;
  String? get error => _error;

  void listenCandidateApplications(String candidateId) {
    _firestore.applicationsByCandidate(candidateId).handleError((_, __) {}).listen((list) {
      _candidateApplications = list;
      notifyListeners();
    });
  }

  void listenJobApplications(String jobId) {
    _firestore.applicationsByJob(jobId).handleError((_, __) {}).listen((list) {
      _jobApplications = list;
      notifyListeners();
    });
  }

  Future<bool> hasApplied(String candidateId, String jobId) async {
    return _firestore.hasApplied(candidateId, jobId);
  }

  Future<bool> apply({
    required String jobId,
    required String candidateId,
    required String recruiterId,
    required String jobTitle,
    String? cvUrl,
    String? coverMessage,
    String? candidateName,
    String? candidateEmail,
  }) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      final exists = await _firestore.hasApplied(candidateId, jobId);
      if (exists) {
        _error = 'Vous avez déjà postulé à cette offre.';
        _loading = false;
        notifyListeners();
        return false;
      }
      final app = Candidature(
        id: '',
        jobId: jobId,
        candidateId: candidateId,
        recruiterId: recruiterId,
        cvUrl: cvUrl,
        coverMessage: coverMessage,
        status: CandidatureStatus.pending,
        createdAt: DateTime.now(),
        candidateName: candidateName,
        candidateEmail: candidateEmail,
        jobTitle: jobTitle,
      );
      await _firestore.addApplication(app);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(String applicationId, CandidatureStatus status) async {
    _error = null;
    try {
      await _firestore.updateApplicationStatus(applicationId, status);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteApplication(String id) async {
    _error = null;
    try {
      await _firestore.deleteApplication(id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<List<Candidature>> getRecruiterApplications(String recruiterId) async {
    try {
      return await _firestore.applicationsByRecruiter(recruiterId);
    } catch (_) {
      return [];
    }
  }
}
