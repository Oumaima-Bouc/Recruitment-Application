import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/job_post.dart';
import 'package:khedmni/l10n/app_localizations.dart'; // Add import

class ApplicationsScreen extends StatelessWidget {
  final Company company;
  final List<JobPost> jobPosts;

  const ApplicationsScreen({
    super.key,
    required this.company,
    required this.jobPosts,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F12) : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.applications,
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1E3A5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
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
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noActiveJobPosts,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
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
                  color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      job.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context)!.postedPrefix}${job.createdAt.day}/${job.createdAt.month}/${job.createdAt.year}',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context)!.deadlinePrefix}${job.deadline.day}/${job.deadline.month}/${job.deadline.year}',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '0 ${AppLocalizations.of(context)!.applicantsSuffix}', // Mocked for now
                        style: const TextStyle(
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () {
                      // Navigate to applicant details
                    },
                  ),
                );
              },
            ),
    );
  }
}
