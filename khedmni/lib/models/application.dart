class Application {
  final String id;
  final String? jobPostId;
  final String? jobId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String? studentAvatar;
  final String coverLetter;
  final String resumeUrl;
  final DateTime appliedAt;
  final String status; // 'pending', 'accepted', 'rejected'

  Application({
    required this.id,
    this.jobPostId,
    this.jobId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.studentAvatar,
    required this.coverLetter,
    required this.resumeUrl,
    required this.appliedAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_post_id': jobPostId,
      'job_id': jobId,
      'student_id': studentId,
      'student_name': studentName,
      'student_email': studentEmail,
      'student_avatar': studentAvatar,
      'cover_letter': coverLetter,
      'resume_url': resumeUrl,
      'applied_at': appliedAt.toIso8601String(),
      'status': status,
    };
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      jobPostId: json['job_post_id'],
      jobId: json['job_id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      studentEmail: json['student_email'],
      studentAvatar: json['student_avatar'],
      coverLetter: json['cover_letter'],
      resumeUrl: json['resume_url'],
      appliedAt: DateTime.parse(json['applied_at']),
      status: json['status'],
    );
  }

  Application copyWith({String? status}) {
    return Application(
      id: id,
      jobPostId: jobPostId,
      jobId: jobId,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      studentAvatar: studentAvatar,
      coverLetter: coverLetter,
      resumeUrl: resumeUrl,
      appliedAt: appliedAt,
      status: status ?? this.status,
    );
  }
}