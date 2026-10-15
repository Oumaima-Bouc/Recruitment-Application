class Company {
  final String id;
  final String name;
  final String email;
  final String industry;
  final String website;
  final String description;
  final String contact;
  final String? logoUrl;
  final int followers;
  final bool isVerified; // ⭐ NEW: Verification status
  final List<String> verificationDocs; // ⭐ NEW: List of document paths
  final List<String> photos; // ⭐ NEW: Company photos gallery

  Company({
    required this.id,
    required this.name,
    required this.email,
    required this.industry,
    required this.website,
    required this.description,
    required this.contact,
    this.logoUrl,
    this.followers = 0,
    this.isVerified = false, // ⭐ NEW: Default not verified
    this.verificationDocs = const [], // ⭐ NEW: Default empty list
    this.photos = const [], // ⭐ NEW: Default empty list
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'industry': industry,
      'website': website,
      'description': description,
      'contact': contact,
      'logoUrl': logoUrl,
      'followers': followers,
      'isVerified': isVerified ? 1 : 0, // ⭐ NEW: SQLite stores as 0/1
      'verificationDocs': verificationDocs.join(
        ',',
      ), // ⭐ NEW: Store as comma-separated
      'photos': photos.join(','), // ⭐ NEW: Store as comma-separated
    };
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      industry: json['industry'],
      website: json['website'],
      description: json['description'],
      contact: json['contact'],
      logoUrl: json['logoUrl'],
      followers: json['followers'] ?? 0,
      isVerified: json['isVerified'] == 1, // ⭐ NEW: Convert 0/1 to bool
      verificationDocs:
          json['verificationDocs'] != null &&
              json['verificationDocs'].isNotEmpty
          ? (json['verificationDocs'] as String).split(',')
          : [], // ⭐ NEW: Split comma-separated string
      photos: json['photos'] != null && json['photos'].isNotEmpty
          ? (json['photos'] as String).split(',')
          : [], // ⭐ NEW: Split comma-separated string
    );
  }

  // Copy with method for updating company
  Company copyWith({
    String? id,
    String? name,
    String? email,
    String? industry,
    String? website,
    String? description,
    String? contact,
    String? logoUrl,
    int? followers,
    bool? isVerified, // ⭐ NEW
    List<String>? verificationDocs, // ⭐ NEW
    List<String>? photos, // ⭐ NEW
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      industry: industry ?? this.industry,
      website: website ?? this.website,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      logoUrl: logoUrl ?? this.logoUrl,
      followers: followers ?? this.followers,
      isVerified: isVerified ?? this.isVerified, // ⭐ NEW
      verificationDocs: verificationDocs ?? this.verificationDocs, // ⭐ NEW
      photos: photos ?? this.photos, // ⭐ NEW
    );
  }
}
