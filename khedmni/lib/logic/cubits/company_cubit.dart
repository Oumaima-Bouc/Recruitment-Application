import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/company.dart';
import '../../models/job_post.dart';
import 'company_state.dart';
import '../../data/repositories/job_repository.dart';
import '../../models/job.dart';
import '../../data/dao/company_dao.dart';
import '../../data/dao/job_post_dao.dart';

class CompanyCubit extends Cubit<CompanyState> {
  CompanyCubit() : super(CompanyInitial());

  Company? _currentCompany;
  List<JobPost> _jobPosts = [];
  final JobRepository _jobRepository = JobRepository();
  final CompanyDao _companyDao = CompanyDao();
  final JobPostDao _jobPostDao = JobPostDao();

  // Fetch company information
  Future<void> loadCompanyInfo(String companyId) async {
    emit(CompanyLoading());
    try {
      // Fetch from database
      _currentCompany = await _companyDao.getCompanyById(companyId);

      if (_currentCompany == null) {
        emit(const CompanyError('Company not found'));
        return;
      }

      // Fetch job posts for this company
      _jobPosts = await _jobPostDao.getJobPostsByCompanyId(companyId);

      emit(CompanyLoaded(company: _currentCompany!, jobPosts: _jobPosts));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  // Post a new job
  Future<void> postJob({
    required String title,
    required String description,
    required String requirements,
    required String location,
    required DateTime deadline,
    required String type,
    required String category,
  }) async {
    if (_currentCompany == null) {
      emit(const CompanyError('Company not loaded'));
      return;
    }

    try {
      emit(CompanySubmitting());

      // Create new job post
      final newJobPost = JobPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyId: _currentCompany!.id,
        companyName: _currentCompany!.name,
        companyLogo: _currentCompany!.logoUrl,
        title: title,
        description: description,
        requirements: requirements,
        location: location,
        deadline: deadline,
        createdAt: DateTime.now(),
        type: type,
        category: category,
      );

      // Save to JobPostDao (Persistence)
      await _jobPostDao.insertJobPost(newJobPost);

      // Refresh local list
      _jobPosts = await _jobPostDao.getJobPostsByCompanyId(_currentCompany!.id);

      // Sync with global JobRepository (for Feed)
      final globalJob = Job(
        id: newJobPost.id,
        title: newJobPost.title,
        company: newJobPost.companyName,
        location: newJobPost.location,
        jobType: newJobPost.type,
        postedDate: 'Just now', // Simplified
        salary: '\$0 - \$0', // Default or add input later
        description: newJobPost.description,
        requirements: [
          newJobPost.requirements,
        ], // Wrap in list as Job expects List<String>
        category: newJobPost.category,
        deadline: newJobPost.deadline, // Add deadline from JobPost
      );
      await _jobRepository.addJob(globalJob);

      // Emit updated state
      emit(
        CompanyLoaded(
          company: _currentCompany!,
          jobPosts: List.from(_jobPosts),
        ),
      );
      emit(CompanyLoaded(company: _currentCompany!, jobPosts: _jobPosts));

      // Emit success state
      emit(JobPostAdded(newJobPost));

      // Return to loaded state
      emit(
        CompanyLoaded(
          company: _currentCompany!,
          jobPosts: List.from(_jobPosts),
        ),
      );
      emit(CompanyLoaded(company: _currentCompany!, jobPosts: _jobPosts));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  // Get all job posts for the company
  List<JobPost> getJobPosts() {
    return List.from(_jobPosts);
  }

  // Delete a job post
  Future<void> deleteJobPost(String jobPostId) async {
    try {
      await _jobPostDao.deleteJobPost(jobPostId);

      if (_currentCompany != null) {
        emit(
          CompanyLoaded(
            company: _currentCompany!,
            jobPosts: List.from(_jobPosts),
          ),
        );
        _jobPosts = await _jobPostDao.getJobPostsByCompanyId(
          _currentCompany!.id,
        );
        emit(CompanyLoaded(company: _currentCompany!, jobPosts: _jobPosts));
      }
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  // Update company information
  void updateCompanyInfo(Company company) {
    _currentCompany = company;
    emit(CompanyLoaded(company: company, jobPosts: _jobPosts));
  }

  // Update company profile
  Future<void> updateCompanyProfile(Company updatedCompany) async {
    try {
      emit(CompanySubmitting());

      // Simulate network delay (in real app, this would be an API call)
      await Future.delayed(const Duration(milliseconds: 500));

      _currentCompany = updatedCompany;

      emit(CompanyLoaded(company: _currentCompany!, jobPosts: _jobPosts));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  void updateCompany(Company result) {}
}
