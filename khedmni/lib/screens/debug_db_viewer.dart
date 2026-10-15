import 'package:flutter/material.dart';
import '../data/dao/user_dao.dart';
import '../data/dao/job_dao.dart';
import '../models/user.dart';
import '../models/job.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubits/job_cubit.dart';

class DebugDbViewerScreen extends StatefulWidget {
  const DebugDbViewerScreen({super.key});

  @override
  State<DebugDbViewerScreen> createState() => _DebugDbViewerScreenState();
}

class _DebugDbViewerScreenState extends State<DebugDbViewerScreen> {
  final UserDao _userDao = UserDao();
  final JobDao _jobDao = JobDao();

  List<User> _users = [];
  List<Job> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final users = await _userDao.getAllUsers();
    final jobs = await _jobDao.getAllJobs();
    setState(() {
      _users = users;
      _jobs = jobs;
      _isLoading = false;
    });
  }

  Future<void> _clearJobs() async {
    await _jobDao.deleteAllJobs();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debug DB Viewer'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Jobs'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_jobs') _clearJobs();
                if (value == 'randomize_categories') {
                  context.read<JobCubit>().randomizeCategories().then((_) => _loadData());
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_jobs',
                  child: Text('Clear All Jobs (Reset Seed)'),
                ),
                const PopupMenuItem(
                  value: 'randomize_categories',
                  child: Text('Randomize Categories'),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildUserList(),
                  _buildJobList(),
                ],
              ),
      ),
    );
  }

  Widget _buildUserList() {
    if (_users.isEmpty) return const Center(child: Text('No users found'));
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('${user.name} (${user.userType})'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${user.email}'),
                Text('ID: ${user.id}'),
                Text('Created: ${user.createdAt}'),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildJobList() {
    if (_jobs.isEmpty) return const Center(child: Text('No jobs found'));
    return ListView.builder(
      itemCount: _jobs.length,
      itemBuilder: (context, index) {
        final job = _jobs[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(job.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Company: ${job.company}'),
                Text('ID: ${job.id}'),
                Text('Posted: ${job.postedDate}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
