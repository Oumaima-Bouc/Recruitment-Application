import 'package:equatable/equatable.dart';
import '../../models/company.dart';
import '../../models/job_post.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanySubmitting extends CompanyState {}

class CompanyLoaded extends CompanyState {
  final Company company;
  final List<JobPost> jobPosts;

  const CompanyLoaded({
    required this.company,
    required this.jobPosts,
  });

  @override
  List<Object?> get props => [company, jobPosts];

  CompanyLoaded copyWith({
    Company? company,
    List<JobPost>? jobPosts,
  }) {
    return CompanyLoaded(
      company: company ?? this.company,
      jobPosts: jobPosts ?? this.jobPosts,
    );
  }
}

class CompanyError extends CompanyState {
  final String message;

  const CompanyError(this.message);

  @override
  List<Object?> get props => [message];
}

class JobPostAdded extends CompanyState {
  final JobPost jobPost;

  const JobPostAdded(this.jobPost);

  @override
  List<Object?> get props => [jobPost];
}
