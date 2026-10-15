import 'package:equatable/equatable.dart';

abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class JobLoaded extends JobState {
  final List jobs;
  final String? selectedJobType;
  final String? selectedCategory;
  final String searchQuery;
  final List<String> savedJobIds;

  const JobLoaded({
    required this.jobs,
    this.selectedJobType,
    this.selectedCategory,
    this.searchQuery = '',
    this.savedJobIds = const [],
  });

  @override
  List<Object?> get props => [jobs, selectedJobType, selectedCategory, searchQuery, savedJobIds];

  JobLoaded copyWith({
    List? jobs,
    String? selectedJobType,
    String? selectedCategory,
    String? searchQuery,
    List<String>? savedJobIds,
    bool clearJobType = false,
    bool clearCategory = false,
  }) {
    return JobLoaded(
      jobs: jobs ?? this.jobs,
      selectedJobType: clearJobType ? null : (selectedJobType ?? this.selectedJobType),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      savedJobIds: savedJobIds ?? this.savedJobIds,
    );
  }
}

class JobError extends JobState {
  final String message;

  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}
