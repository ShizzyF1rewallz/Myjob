import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/offre_model.dart';

/// Réponse API Arbeitnow (emplois internationaux).
const String kArbeitnowApiUrl = 'https://www.arbeitnow.com/api/job-board-api';

class JobsApiService {
  /// Récupère les offres depuis l'API externe (Arbeitnow).
  Future<List<OffreDto>> fetchExternalJobs() async {
    try {
      final response = await http.get(Uri.parse(kArbeitnowApiUrl));
      if (response.statusCode != 200) return [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>? ?? [];
      return data.map((e) => _parseJob(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  OffreDto _parseJob(Map<String, dynamic> map) {
    final title = map['title'] as String? ?? 'Sans titre';
    final desc = map['description'] as String? ?? '';
    final location = map['location'] as String? ?? 'Non précisé';
    final company = map['company_name'] as String? ?? '';
    final tags = List<String>.from(map['tags'] as List? ?? []);
    final jobTypes = List<String>.from(map['job_types'] as List? ?? []);
    final remote = map['remote'] as bool? ?? false;
    final createdAt = (map['created_at'] as num?)?.toInt() ?? 0;
    final url = map['url'] as String?;
    final slug = map['slug'] as String? ?? '';

    ContractType type = ContractType.cdi;
    if (jobTypes.any((t) => t.toLowerCase().contains('stage'))) {
      type = ContractType.stage;
    } else if (jobTypes.any((t) => t.toLowerCase().contains('freelance'))) {
      type = ContractType.freelance;
    } else if (jobTypes.any((t) => t.toLowerCase().contains('cdd'))) {
      type = ContractType.cdd;
    }

    String loc = location;
    if (remote) loc = '$location (Remote)';

    final deadline = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000)
        .add(const Duration(days: 90));

    return OffreDto(
      externalId: slug,
      title: title,
      description: desc,
      type: type,
      location: loc,
      companyName: company,
      skills: tags,
      deadline: deadline,
      externalUrl: url,
    );
  }
}

/// DTO pour une offre importée de l'API (avant enregistrement Firestore).
class OffreDto {
  final String externalId;
  final String title;
  final String description;
  final ContractType type;
  final String location;
  final String? companyName;
  final List<String> skills;
  final DateTime deadline;
  final String? externalUrl;

  OffreDto({
    required this.externalId,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    this.companyName,
    this.skills = const [],
    required this.deadline,
    this.externalUrl,
  });
}
