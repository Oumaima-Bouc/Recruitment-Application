class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String userType; // 'student' or 'company'
  final String? phone;
  final String? location;
  final String? skills; // JSON string of List<String>
  final String? bio;
  final String? title; // Professional Title
  final String? cvUrl;
  final String? photoUrl;
  final bool isEmailVerified; // new: whether user verified their email
  final String? emailVerificationToken;
  final DateTime? cvLastUpdated;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    this.phone,
    this.location,
    this.skills,
    this.bio,
    this.title,
    this.cvUrl,
    this.photoUrl,
    this.isEmailVerified = false,
    this.emailVerificationToken,
    this.cvLastUpdated,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'userType': userType,
      'phone': phone,
      'location': location,
      'skills': skills,
      'bio': bio,
      'title': title,
      'cvUrl': cvUrl,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified ? 1 : 0,
      'emailVerificationToken': emailVerificationToken,
      'cvLastUpdated': cvLastUpdated?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      userType: json['userType'] as String,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      skills: json['skills'] as String?,
      bio: json['bio'] as String?,
      title: json['title'] as String?,
      cvUrl: json['cvUrl'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isEmailVerified: (json['isEmailVerified'] as int? ?? 0) == 1,
      emailVerificationToken: json['emailVerificationToken'] as String?,
      cvLastUpdated: json['cvLastUpdated'] != null ? DateTime.parse(json['cvLastUpdated'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? userType,
    String? phone,
    String? location,
    String? skills,
    String? bio,
    String? title,
    String? cvUrl,
    String? photoUrl,
    bool? isEmailVerified,
    String? emailVerificationToken,
    DateTime? cvLastUpdated,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      title: title ?? this.title,
      cvUrl: cvUrl ?? this.cvUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      emailVerificationToken: emailVerificationToken ?? this.emailVerificationToken,
      cvLastUpdated: cvLastUpdated ?? this.cvLastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
