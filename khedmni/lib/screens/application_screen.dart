import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/job_post.dart';
import '../models/application.dart';

class ApplicationsScreen extends StatefulWidget {
  final Company company;
  final List<JobPost> jobPosts;

  const ApplicationsScreen({
    super.key,
    required this.company,
    required this.jobPosts,
  });

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  // Mock applications for demonstration
  final List<Application> _applications = [
    Application(
      id: '1',
      jobPostId: '1',
      studentId: 's1',
      studentName: 'Sara Beljers',
      studentEmail: 'sara.b@email.com',
      coverLetter: 'I am interested in this position...',
      resumeUrl: 'https://example.com/resume1.pdf',
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      status: 'pending',
    ),
    Application(
      id: '2',
      jobPostId: '1',
      studentId: 's2',
      studentName: 'Sara Beljers',
      studentEmail: 'sara.b@email.com',
      coverLetter: 'Looking forward to contributing...',
      resumeUrl: 'https://example.com/resume2.pdf',
      appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: 'pending',
    ),
    Application(
      id: '3',
      jobPostId: '1',
      studentId: 's3',
      studentName: 'Sara Beljers',
      studentEmail: 'sara.b@email.com',
      coverLetter: 'I have the skills required...',
      resumeUrl: 'https://example.com/resume3.pdf',
      appliedAt: DateTime.now(),
      status: 'accepted',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search for jobs or internships',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildFilterChip('History', true, isDarkMode),
              const SizedBox(width: 8),
              _buildFilterChip('Experience', false, isDarkMode),
              const SizedBox(width: 8),
              _buildFilterChip('Location', false, isDarkMode),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No applications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Applications will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[500],
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
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1E3A5F)
            : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildApplicationCard(Application application, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.studentName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1E3A5F),
                        ),
                      ),
                      Text(
                        'Marketing Intern',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusChip(application.status),
                const Spacer(),
                _buildInfoChip(Icons.location_on, 'Algiers', isDarkMode),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        final index = _applications.indexOf(application);
                        _applications[index] = application.copyWith(
                          status: 'rejected',
                        );
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      foregroundColor: Colors.grey[700],
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        final index = _applications.indexOf(application);
                        _applications[index] = application.copyWith(
                          status: 'accepted',
                        );
                      });
                    },
                    child: const Text('see app'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'accepted':
        color = Colors.green;
        label = 'Accepted';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
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

  Widget _buildInfoChip(IconData icon, String text, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
