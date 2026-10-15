import 'package:flutter/material.dart';
import 'package:khedmni/l10n/app_localizations.dart';
import '../models/company.dart';
import '../models/job_post.dart';
import '../models/application.dart';
import '../data/dao/application_dao.dart';
import '../logic/cubits/notification_cubit.dart';
import '../models/notification_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'application_review_screen.dart';

class CompanyApplicationsScreen extends StatefulWidget {
  final Company company;
  final List<JobPost> jobPosts;

  const CompanyApplicationsScreen({
    Key? key,
    required this.company,
    required this.jobPosts,
  }) : super(key: key);

  @override
  State<CompanyApplicationsScreen> createState() =>
      _CompanyApplicationsScreenState();
}

class _CompanyApplicationsScreenState extends State<CompanyApplicationsScreen> {
  final ApplicationDao _applicationDao = ApplicationDao();
  List<Application> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() => _isLoading = true);
    List<Application> allApps = [];
    for (var job in widget.jobPosts) {
      final apps = await _applicationDao.getApplicationsByJobPostId(job.id);
      allApps.addAll(apps);
    }

    setState(() {
      _applications = allApps;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F12) : Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.applicants),
        backgroundColor: isDarkMode ? const Color(0xFF0F1720) : null,
        foregroundColor: isDarkMode ? Colors.white : null,
        leading: widget.jobPosts.length == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Applications list
                Expanded(
                  child: _applications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 80,
                                color: isDarkMode
                                    ? Colors.grey[600]
                                    : Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.noApplicationsYet,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _applications.length,
                          itemBuilder: (context, index) {
                            return _buildApplicationCard(
                              _applications[index],
                              isDarkMode,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildApplicationCard(Application application, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          backgroundImage:
              application.studentAvatar != null &&
                  application.studentAvatar!.isNotEmpty
              ? NetworkImage(application.studentAvatar!)
              : null,
          child:
              application.studentAvatar == null ||
                  application.studentAvatar!.isEmpty
              ? Icon(
                  Icons.person,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                )
              : null,
        ),
        title: Text(
          application.studentName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF1E3A5F),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildStatusChip(application.status),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.grey[500] : null,
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplicationReviewScreen(
                application: application,
                company: widget.company,
              ),
            ),
          );
          if (result == true) {
            _fetchApplications();
          }
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        label = AppLocalizations.of(context)!.statusAccepted;
        break;
      case 'rejected':
        color = Colors.red;
        label = AppLocalizations.of(context)!.statusRejected;
        break;
      default:
        color = Colors.orange;
        label = AppLocalizations.of(context)!.statusPending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
