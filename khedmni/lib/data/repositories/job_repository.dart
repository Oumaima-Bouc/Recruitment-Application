import '../dao/job_dao.dart';
import '../dao/job_post_dao.dart';
import '../../models/job.dart';
import '../../models/job_post.dart';
// import '../dummy_data.dart'; // Removed dummy data import

class JobRepository {
  final JobDao _jobDao = JobDao();
  final JobPostDao _jobPostDao = JobPostDao();
  bool _isSeeded = false;

  /// Convert JobPost -> Job (best-effort mapping for UI compatibility)
  Job _fromJobPost(JobPost p) {
    return Job(
      id: p.id,
      title: p.title,
      company: p.companyName,
      location: p.location,
      salary: '', // Not available on job_posts
      description: p.description,
      requirements: p.requirements is String ? (p.requirements as String).split('|') : [p.requirements],
      postedDate: p.createdAt.toIso8601String(),
      jobType: p.type,
      category: p.category,
      deadline: p.deadline,
    );
  }

  /// Get all jobs (auto-seed if empty). Prefers normalized job_posts when available.
  Future<List<Job>> getAllJobs() async {
    await _ensureSeeded();

    // Prefer job_posts if available
    final posts = await _jobPostDao.getAllJobPosts();
    if (posts.isNotEmpty) {
      return posts.map(_fromJobPost).toList();
    }

    // Fallback to legacy jobs
    return await _jobDao.getAllJobs();
  }

  /// Get job by ID
  Future<Job?> getJobById(String id) async {
    await _ensureSeeded();
    final post = await _jobPostDao.getJobPostById(id);
    if (post != null) return _fromJobPost(post);
    return await _jobDao.getJobById(id);
  }

  /// Search jobs
  Future<List<Job>> searchJobs(String query) async {
    await _ensureSeeded();

    final posts = await _jobPostDao.getAllJobPosts();
    if (posts.isNotEmpty) {
      final filtered = posts.where((p) => p.title.toLowerCase().contains(query.toLowerCase()) || p.companyName.toLowerCase().contains(query.toLowerCase())).toList();
      return filtered.map(_fromJobPost).toList();
    }

    return await _jobDao.searchJobs(query);
  }

  /// Filter jobs by type
  Future<List<Job>> getJobsByType(String jobType) async {
    await _ensureSeeded();

    final posts = await _jobPostDao.getAllJobPosts();
    if (posts.isNotEmpty) {
      final filtered = posts.where((p) => p.type == jobType).toList();
      return filtered.map(_fromJobPost).toList();
    }

    return await _jobDao.getJobsByType(jobType);
  }

  /// Add a new job
  Future<void> addJob(Job job) async {
    await _jobDao.insertJob(job);
  }

  /// Delete a job
  Future<void> deleteJob(String id) async {
    await _jobDao.deleteJob(id);
  }

  /// Ensure database is seeded (DISABLED)
  Future<void> _ensureSeeded() async {
    if (!_isSeeded) {
      // We still want to try consolidating existing data if it's there
      await _jobPostDao.seedFromJobs();
      _isSeeded = true;
    }
  }

  /// Reset database (DISABLED seeding)
  Future<void> resetAndSeed() async {
    await _jobDao.deleteAllJobs();
    await _jobPostDao.seedFromJobs();
    _isSeeded = true;
  }
}
