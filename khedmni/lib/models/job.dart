import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String description;
  final List<String> requirements;
  final String postedDate;
  final String jobType; // Full-time, Part-time, Internship, etc.
  final String category; // Design, Development, Marketing, Finance, etc.
  final DateTime deadline;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.description,
    required this.requirements,
    required this.postedDate,
    required this.jobType,
    required this.category,
    required this.deadline,
  });

  Job copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? salary,
    String? description,
    List<String>? requirements,
    String? postedDate,
    String? jobType,
    String? category,
    DateTime? deadline,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      postedDate: postedDate ?? this.postedDate,
      jobType: jobType ?? this.jobType,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
    );
  }

  @override
  List<Object?> get props => [id, title, company, location, salary, description, requirements, postedDate, jobType, category, deadline];
}
