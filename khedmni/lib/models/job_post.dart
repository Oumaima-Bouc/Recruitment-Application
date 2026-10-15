class JobPost {
  final String id;
  final String? companyId;
  final String companyName;
  final String? companyLogo;
  final String title;
  final String description;
  final String requirements;
  final String location;
  final DateTime deadline;
  final DateTime createdAt;
  final String type; // 'internship' or 'job'
  final String category;

  JobPost({
    required this.id,
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    required this.deadline,
    required this.createdAt,
    required this.type,
    required this.category,
  });

  JobPost copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? companyLogo,
    String? title,
    String? description,
    String? requirements,
    String? location,
    DateTime? deadline,
    DateTime? createdAt,
    String? type,
    String? category,
  }) {
    return JobPost(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      title: title ?? this.title,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      location: location ?? this.location,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'title': title,
      'description': description,
      'requirements': requirements,
      'location': location,
      'deadline': deadline.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'type': type,
      'category': category,
    };
  }

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'],
      companyId: json['companyId'],
      companyName: json['companyName'],
      companyLogo: json['companyLogo'],
      title: json['title'],
      description: json['description'],
      requirements: json['requirements'],
      location: json['location'],
      deadline: DateTime.parse(json['deadline']),
      createdAt: DateTime.parse(json['createdAt']),
      type: json['type'],
      category: json['category'] ?? 'Development',
    );
  }
}