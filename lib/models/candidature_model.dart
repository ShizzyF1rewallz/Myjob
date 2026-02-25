/// Statut d'une candidature.
enum CandidatureStatus { pending, accepted, rejected }

/// Modèle d'une candidature (postulation).
class Candidature {
  final String id;
  final String jobId;
  final String candidateId;
  final String recruiterId;
  final String? cvUrl;
  final String? coverMessage;
  final CandidatureStatus status;
  final DateTime createdAt;
  final String? candidateName;
  final String? candidateEmail;
  final String? jobTitle;

  const Candidature({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.recruiterId,
    this.cvUrl,
    this.coverMessage,
    this.status = CandidatureStatus.pending,
    required this.createdAt,
    this.candidateName,
    this.candidateEmail,
    this.jobTitle,
  });

  String get statusLabel {
    switch (status) {
      case CandidatureStatus.pending:
        return 'En attente';
      case CandidatureStatus.accepted:
        return 'Acceptée';
      case CandidatureStatus.rejected:
        return 'Refusée';
    }
  }

  static CandidatureStatus statusFromString(String? s) {
    switch (s) {
      case 'accepted':
        return CandidatureStatus.accepted;
      case 'rejected':
        return CandidatureStatus.rejected;
      default:
        return CandidatureStatus.pending;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'candidateId': candidateId,
      'recruiterId': recruiterId,
      'cvUrl': cvUrl,
      'coverMessage': coverMessage,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'candidateName': candidateName,
      'candidateEmail': candidateEmail,
      'jobTitle': jobTitle,
    };
  }

  factory Candidature.fromMap(Map<String, dynamic> map, String id) {
    return Candidature(
      id: id,
      jobId: map['jobId'] as String? ?? '',
      candidateId: map['candidateId'] as String? ?? '',
      recruiterId: map['recruiterId'] as String? ?? '',
      cvUrl: map['cvUrl'] as String?,
      coverMessage: map['coverMessage'] as String?,
      status: statusFromString(map['status'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
      candidateName: map['candidateName'] as String?,
      candidateEmail: map['candidateEmail'] as String?,
      jobTitle: map['jobTitle'] as String?,
    );
  }

  Candidature copyWith({
    String? id,
    String? jobId,
    String? candidateId,
    String? recruiterId,
    String? cvUrl,
    String? coverMessage,
    CandidatureStatus? status,
    DateTime? createdAt,
    String? candidateName,
    String? candidateEmail,
    String? jobTitle,
  }) {
    return Candidature(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      candidateId: candidateId ?? this.candidateId,
      recruiterId: recruiterId ?? this.recruiterId,
      cvUrl: cvUrl ?? this.cvUrl,
      coverMessage: coverMessage ?? this.coverMessage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      candidateName: candidateName ?? this.candidateName,
      candidateEmail: candidateEmail ?? this.candidateEmail,
      jobTitle: jobTitle ?? this.jobTitle,
    );
  }
}
