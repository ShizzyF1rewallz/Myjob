import 'package:flutter/foundation.dart';
import '../models/offre_model.dart';
import '../services/firestore_service.dart';
import '../services/jobs_api_service.dart';

class JobsController extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final JobsApiService _apiService = JobsApiService();

  List<Offre> _allJobs = [];
  List<Offre> _filteredJobs = [];
  List<OffreDto> _externalJobs = [];
  bool _loading = false;
  String? _error;

  List<Offre> get jobs => _filteredJobs;
  List<OffreDto> get externalJobs => _externalJobs;
  bool get loading => _loading;
  String? get error => _error;

  void setRecruiterStream(String? recruiterId) {
    _firestore.jobsStream(recruiterId: recruiterId).handleError((_, __) {}).listen((list) {
      _allJobs = list;
      _applyFilters();
      notifyListeners();
    });
  }

  void loadAllJobs() {
    setRecruiterStream(null);
  }

  void loadRecruiterJobs(String recruiterId) {
    setRecruiterStream(recruiterId);
  }

  String? _titleFilter;
  String? _locationFilter;
  String? _typeFilter;
  String? _domainFilter;

  void setFilters({
    String? title,
    String? location,
    String? type,
    String? domain,
  }) {
    _titleFilter = title;
    _locationFilter = location;
    _typeFilter = type;
    _domainFilter = domain;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredJobs = _allJobs;
    if (_titleFilter != null && _titleFilter!.isNotEmpty) {
      final t = _titleFilter!.toLowerCase();
      _filteredJobs =
          _filteredJobs.where((o) => o.title.toLowerCase().contains(t)).toList();
    }
    if (_locationFilter != null && _locationFilter!.isNotEmpty) {
      final loc = _locationFilter!.toLowerCase();
      _filteredJobs = _filteredJobs
          .where((o) => o.location.toLowerCase().contains(loc))
          .toList();
    }
    if (_typeFilter != null && _typeFilter!.isNotEmpty) {
      _filteredJobs = _filteredJobs
          .where((o) => o.type.name == _typeFilter)
          .toList();
    }
    if (_domainFilter != null && _domainFilter!.isNotEmpty) {
      final d = _domainFilter!.toLowerCase();
      _filteredJobs = _filteredJobs.where((o) {
        if (o.skills.any((s) => s.toLowerCase().contains(d))) return true;
        if (o.companyName != null &&
            o.companyName!.toLowerCase().contains(d)) return true;
        return false;
      }).toList();
    }
  }

  Future<void> searchJobs({
    String? title,
    String? location,
    String? type,
    String? domain,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _allJobs = await _firestore.getJobs(
        titleQuery: title,
        locationQuery: location,
        typeQuery: type,
        domainQuery: domain,
      );
      _titleFilter = title;
      _locationFilter = location;
      _typeFilter = type;
      _domainFilter = domain;
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<Offre?> getJob(String id) async {
    return _firestore.getJob(id);
  }

  Future<List<Offre>> getJobsByIds(List<String> ids) async {
    return _firestore.getJobsByIds(ids);
  }

  Future<String?> createJob({
    required String recruiterId,
    required String title,
    required String description,
    required ContractType type,
    required String location,
    String? salary,
    required DateTime deadline,
    List<String> skills = const [],
  }) async {
    _error = null;
    try {
      final job = Offre(
        id: '',
        recruiterId: recruiterId,
        title: title,
        description: description,
        type: type,
        location: location,
        salary: salary,
        deadline: deadline,
        skills: skills,
        createdAt: DateTime.now(),
      );
      final id = await _firestore.addJob(job);
      return id;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<bool> updateJob(Offre job) async {
    _error = null;
    try {
      await _firestore.updateJob(job.id, job.toMap());
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteJob(String id) async {
    _error = null;
    try {
      await _firestore.deleteJob(id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> fetchExternalJobs() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _externalJobs = await _apiService.fetchExternalJobs();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  /// Importe une offre externe dans Firestore (recruiterId = utilisateur qui importe).
  Future<String?> importExternalJob(String recruiterId, OffreDto dto) async {
    _error = null;
    try {
      final job = Offre(
        id: '',
        recruiterId: recruiterId,
        title: dto.title,
        description: dto.description,
        type: dto.type,
        location: dto.location,
        deadline: dto.deadline,
        skills: dto.skills,
        createdAt: DateTime.now(),
        fromExternalApi: true,
        externalUrl: dto.externalUrl,
        companyName: dto.companyName,
      );
      return await _firestore.addJob(job);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
}
