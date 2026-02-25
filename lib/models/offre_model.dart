/// Type de contrat pour une offre.
enum ContractType { stage, cdi, cdd, freelance }

/// Modèle d'une offre d'emploi.
class Offre {
  final String id;
  final String recruiterId;
  final String title;
  final String description;
  final ContractType type;
  final String location;
  final String? salary;
  final DateTime deadline;
  final List<String> skills;
  final DateTime createdAt;
  final bool fromExternalApi;
  final String? externalUrl;
  final String? companyName;

  const Offre({
    required this.id,
    required this.recruiterId,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    this.salary,
    required this.deadline,
    this.skills = const [],
    required this.createdAt,
    this.fromExternalApi = false,
    this.externalUrl,
    this.companyName,
  });

  String get typeLabel {
    switch (type) {
      case ContractType.stage:
        return 'Stage';
      case ContractType.cdi:
        return 'CDI';
      case ContractType.cdd:
        return 'CDD';
      case ContractType.freelance:
        return 'Freelance';
    }
  }

  static String labelOf(ContractType t) {
    switch (t) {
      case ContractType.stage:
        return 'Stage';
      case ContractType.cdi:
        return 'CDI';
      case ContractType.cdd:
        return 'CDD';
      case ContractType.freelance:
        return 'Freelance';
    }
  }

  static ContractType typeFromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'cdi':
        return ContractType.cdi;
      case 'cdd':
        return ContractType.cdd;
      case 'freelance':
        return ContractType.freelance;
      default:
        return ContractType.stage;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'recruiterId': recruiterId,
      'title': title,
      'description': description,
      'type': type.name,
      'location': location,
      'salary': salary,
      'deadline': deadline.millisecondsSinceEpoch,
      'skills': skills,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'fromExternalApi': fromExternalApi,
      'externalUrl': externalUrl,
      'companyName': companyName,
    };
  }

  factory Offre.fromMap(Map<String, dynamic> map, String id) {
    return Offre(
      id: id,
      recruiterId: map['recruiterId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: typeFromString(map['type'] as String?),
      location: map['location'] as String? ?? '',
      salary: map['salary'] as String?,
      deadline: DateTime.fromMillisecondsSinceEpoch(
        (map['deadline'] as num?)?.toInt() ?? 0,
      ),
      skills: List<String>.from(map['skills'] as List? ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
      fromExternalApi: map['fromExternalApi'] as bool? ?? false,
      externalUrl: map['externalUrl'] as String?,
      companyName: map['companyName'] as String?,
    );
  }

  Offre copyWith({
    String? id,
    String? recruiterId,
    String? title,
    String? description,
    ContractType? type,
    String? location,
    String? salary,
    DateTime? deadline,
    List<String>? skills,
    DateTime? createdAt,
    bool? fromExternalApi,
    String? externalUrl,
    String? companyName,
  }) {
    return Offre(
      id: id ?? this.id,
      recruiterId: recruiterId ?? this.recruiterId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      deadline: deadline ?? this.deadline,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
      fromExternalApi: fromExternalApi ?? this.fromExternalApi,
      externalUrl: externalUrl ?? this.externalUrl,
      companyName: companyName ?? this.companyName,
    );
  }
}
