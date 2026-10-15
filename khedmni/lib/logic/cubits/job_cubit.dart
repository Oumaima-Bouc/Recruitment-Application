import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/job.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/dao/saved_job_dao.dart';
import 'job_state.dart';

class JobCubit extends Cubit<JobState> {
  final JobRepository _jobRepository = JobRepository();
  
  JobCubit() : super(JobInitial());

  List<Job> _allJobs = [];
  List<Job> get allJobs => List.unmodifiable(_allJobs);

  /// Load all jobs from database
  Future<void> loadJobs() async {
    emit(JobLoading());
    try {
      // Load from database (will auto-seed if empty)
      _allJobs = await _jobRepository.getAllJobs();
      emit(JobLoaded(jobs: _allJobs, savedJobIds: List.from(_savedJobIds)));
      print('📦 Loaded ${_allJobs.length} jobs with ${_savedJobIds.length} saved');
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  /// Filter jobs by job type
  void filterByJobType(String? jobType) {
    if (state is JobLoaded) {
      final currentState = state as JobLoaded;
      final filteredJobs = _getFilteredJobs(
        jobType: jobType,
        category: currentState.selectedCategory,
        searchQuery: currentState.searchQuery,
      );
      emit(currentState.copyWith(
        jobs: filteredJobs,
        selectedJobType: jobType,
        clearJobType: jobType == null,
      ));
    }
  }

  /// Filter jobs by category
  void filterByCategory(String? category) {
    if (state is JobLoaded) {
      final currentState = state as JobLoaded;
      final filteredJobs = _getFilteredJobs(
        jobType: currentState.selectedJobType,
        category: category,
        searchQuery: currentState.searchQuery,
      );
      emit(currentState.copyWith(
        jobs: filteredJobs,
        selectedCategory: category,
        clearCategory: category == null,
      ));
    }
  }

  /// Search jobs by query
  void searchJobs(String query) {
    if (state is JobLoaded) {
      final currentState = state as JobLoaded;
      final filteredJobs = _getFilteredJobs(
        jobType: currentState.selectedJobType,
        category: currentState.selectedCategory,
        searchQuery: query,
      );
      emit(currentState.copyWith(
        jobs: filteredJobs,
        searchQuery: query,
      ));
    }
  }

  /// Filter jobs based on type, category and search query
  List<Job> _getFilteredJobs({String? jobType, String? category, String searchQuery = ''}) {
    return _allJobs.where((job) {
      final matchesJobType = jobType == null || job.jobType == jobType;
      final matchesCategory = category == null || job.category == category;
      final matchesSearch = searchQuery.isEmpty ||
          job.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          job.company.toLowerCase().contains(searchQuery.toLowerCase()) ||
          job.location.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesJobType && matchesCategory && matchesSearch;
    }).toList();
  }

  /// Get all unique job types
  List<String> getJobTypes() {
    final types = <String>{};
    for (var job in _allJobs) {
      types.add(job.jobType);
    }
    return types.toList();
  }

  /// Add a new job
  Future<void> addJob(Job job) async {
    try {
      await _jobRepository.addJob(job);
      await loadJobs(); 
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  /// Delete a job
  Future<void> deleteJob(String jobId) async {
    try {
      // Optimistic update
      _allJobs.removeWhere((job) => job.id == jobId);
      
      // Update UI immediately (filtering holds context of current search/filter)
      if (state is JobLoaded) {
          final currentState = state as JobLoaded;
          final filteredJobs = _getFilteredJobs(
            jobType: currentState.selectedJobType,
            category: currentState.selectedCategory,
            searchQuery: currentState.searchQuery,
          );
          emit(currentState.copyWith(jobs: filteredJobs));
      }

      await _jobRepository.deleteJob(jobId);
    } catch (e) {
      emit(JobError(e.toString()));
      // Revert if failed (optional, but good practice)
      await loadJobs();
    }
  }

  final SavedJobDao _savedJobDao = SavedJobDao();
  List<String> _savedJobIds = [];

  // New Method to load saved jobs
  Future<void> loadSavedJobs(String userId) async {
     try {
       print('🔍 Loading saved jobs for user: $userId');
       _savedJobIds = await _savedJobDao.getSavedJobIds(userId);
       print('✅ Loaded ${_savedJobIds.length} saved jobs: $_savedJobIds');
       
       // Always emit if state is JobLoaded
       if (state is JobLoaded) {
          emit((state as JobLoaded).copyWith(savedJobIds: List.from(_savedJobIds)));
          print('📤 Emitted JobLoaded state with ${_savedJobIds.length} saved jobs');
       } else {
          print('ℹ️ State is ${state.runtimeType}, saved IDs will be included when jobs load');
       }
     } catch (e) {
       print("❌ Error loading saved jobs: $e");
     }
  }

  Future<List<Job>> getSavedJobsList() async {
     if (_allJobs.isEmpty) {
        await loadJobs();
     }
     return _allJobs.where((job) => _savedJobIds.contains(job.id)).toList();
  }

  Future<void> toggleSaveJob(String userId, String jobId) async {
    try {
      print('🔄 Toggling save for job: $jobId, user: $userId');
      final isActuallySaved = await _savedJobDao.isJobSaved(userId, jobId);
      print('📊 Job is currently saved in DB: $isActuallySaved');

      if (isActuallySaved) {
        await _savedJobDao.unsaveJob(userId, jobId);
        _savedJobIds.remove(jobId);
        print('➖ Unsaved job $jobId');
      } else {
        await _savedJobDao.saveJob(userId, jobId);
        if (!_savedJobIds.contains(jobId)) {
          _savedJobIds.add(jobId);
        }
        print('➕ Saved job $jobId');
      }
      
      print('📋 Current saved jobs count: ${_savedJobIds.length}');
      
      // Notify UI
      if (state is JobLoaded) {
        final curr = state as JobLoaded;
        emit(curr.copyWith(savedJobIds: List.from(_savedJobIds))); 
        print('📤 Emitted updated state with ${_savedJobIds.length} saved jobs');
      }
    } catch (e) {
      print('❌ Failed to toggle save job: $e');
      emit(JobError("Failed to update favorite: $e"));
      await loadSavedJobs(userId);
    }
  }

  Future<void> randomizeCategories() async {
    if (state is JobLoaded) {
      final currentState = state as JobLoaded;
      final categories = ['IT & Tech', 'Design', 'Marketing', 'Finance', 'Education', 'Health'];
      final random = DateTime.now().millisecondsSinceEpoch;
      
      final updatedJobs = _allJobs.map((job) {
        final categoryIndex = (job.id.hashCode + random) % categories.length;
        return job.copyWith(category: categories[categoryIndex.abs()]);
      }).toList();

      // Update in DB
      for (var job in updatedJobs) {
        await _jobRepository.addJob(job);
      }

      await loadJobs();
    }
  }

  bool isJobSaved(String jobId) => _savedJobIds.contains(jobId);

  /// Reset and reseed database (useful for testing)
  Future<void> resetDatabase() async {
    emit(JobLoading());
    try {
      await _jobRepository.resetAndSeed();
      await loadJobs();
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }
}
