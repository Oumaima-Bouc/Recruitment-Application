import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/job_post.dart';
import 'package:khedmni/l10n/app_localizations.dart';
import 'company_applications_screen.dart';

class CompanyJobsScreen extends StatelessWidget {
  final Company company;
  final List<JobPost> jobPosts;

  const CompanyJobsScreen({
    super.key,
    required this.company,
    required this.jobPosts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(
            context,
          )!.applications, // Keeping the label for consistency in UI
          style: const TextStyle(
            color: Color(0xFF1E3A5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: jobPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noActiveJobPosts,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobPosts.length,
              itemBuilder: (context, index) {
                final job = jobPosts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context)!.postedPrefix}${job.createdAt.day}/${job.createdAt.month}/${job.createdAt.year}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context)!.deadlinePrefix}${job.deadline.day}/${job.deadline.month}/${job.deadline.year}',
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompanyApplicationsScreen(
                            company: company,
                            jobPosts: [
                              job,
                            ], // Show applicants for this specific job
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
