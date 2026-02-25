/// Modèle utilisateur (Candidat ou Recruteur).
enum UserType { candidate, recruiter }

class AppUser {
  final String id;
  final String email;
  final UserType type;
  final String? displayName;
  final String? phone;
  final String? photoUrl;
  final String? cvUrl;
  final String? cvText;
  final List<String> skills;
  final String? domain;
  final String? city;
  final String? country;
  final String? description;
  // Recruteur
  final String? companyName;
  final String? companyDescription;
  final String? companySector;
  final String? companyLogoUrl;

  const AppUser({
    required this.id,
    required this.email,
    required this.type,
    this.displayName,
    this.phone,
    this.photoUrl,
    this.cvUrl,
    this.cvText,
    this.skills = const [],
    this.domain,
    this.city,
    this.country,
    this.description,
    this.companyName,
    this.companyDescription,
    this.companySector,
    this.companyLogoUrl,
  });

  bool get isCandidate => type == UserType.candidate;
  bool get isRecruiter => type == UserType.recruiter;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'type': type.name,
      'displayName': displayName,
      'phone': phone,
      'photoUrl': photoUrl,
      'cvUrl': cvUrl,
      'cvText': cvText,
      'skills': skills,
      'domain': domain,
      'city': city,
      'country': country,
      'description': description,
      'companyName': companyName,
      'companyDescription': companyDescription,
      'companySector': companySector,
      'companyLogoUrl': companyLogoUrl,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] as String? ?? '',
      type: map['type'] == 'recruiter' ? UserType.recruiter : UserType.candidate,
      displayName: map['displayName'] as String?,
      phone: map['phone'] as String?,
      photoUrl: map['photoUrl'] as String?,
      cvUrl: map['cvUrl'] as String?,
      cvText: map['cvText'] as String?,
      skills: List<String>.from(map['skills'] as List? ?? []),
      domain: map['domain'] as String?,
      city: map['city'] as String?,
      country: map['country'] as String?,
      description: map['description'] as String?,
      companyName: map['companyName'] as String?,
      companyDescription: map['companyDescription'] as String?,
      companySector: map['companySector'] as String?,
      companyLogoUrl: map['companyLogoUrl'] as String?,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    UserType? type,
    String? displayName,
    String? phone,
    String? photoUrl,
    String? cvUrl,
    String? cvText,
    List<String>? skills,
    String? domain,
    String? city,
    String? country,
    String? description,
    String? companyName,
    String? companyDescription,
    String? companySector,
    String? companyLogoUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      cvUrl: cvUrl ?? this.cvUrl,
      cvText: cvText ?? this.cvText,
      skills: skills ?? this.skills,
      domain: domain ?? this.domain,
      city: city ?? this.city,
      country: country ?? this.country,
      description: description ?? this.description,
      companyName: companyName ?? this.companyName,
      companyDescription: companyDescription ?? this.companyDescription,
      companySector: companySector ?? this.companySector,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
    );
  }
}
