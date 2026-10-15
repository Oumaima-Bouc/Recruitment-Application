import 'package:flutter/material.dart';
import 'package:khedmni/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/application.dart';
import '../models/company.dart';
import '../data/dao/application_dao.dart';
import '../data/dao/notification_dao.dart';
import '../models/notification_model.dart';
import '../logic/cubits/notification_cubit.dart';

class ApplicationReviewScreen extends StatelessWidget {
  final Application application;
  final Company company;

  const ApplicationReviewScreen({
    Key? key,
    required this.application,
    required this.company,
  }) : super(key: key);

  Future<void> _updateStatus(BuildContext context, String status) async {
    final dao = ApplicationDao();
    await dao.updateApplicationStatus(application.id, status);

    // Save notification for student
    final notifDao = NotificationDao();
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: status == 'accepted'
          ? 'Application Accepted!'
          : 'Application Update',
      message:
          'Your application for a position at ${company.name} has been $status.',
      timestamp: DateTime.now(),
      isRead: false,
      type: status == 'accepted'
          ? NotificationType.jobAccepted
          : NotificationType.jobApplication,
      relatedId: application.id,
    );
    await notifDao.insertNotification(notification);

    if (context.mounted) {
      context.read<NotificationCubit>().fetchNotifications();
      Navigator.pop(context, true); // Return true to refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    const kPrimaryDarkBlue = Color(0xFF1D3557);
    const kPrimaryOrange = Color(0xFFF77F00);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F12) : Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.applicationDetails),
        backgroundColor: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : kPrimaryDarkBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
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
                          size: 40,
                          color: isDarkMode ? Colors.grey[600] : Colors.grey,
                        )
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.studentName,
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
                        ),
                      ),
                      Text(
                        application.studentEmail,
                        style: GoogleFonts.lato(
                          fontSize: 16,
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
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.coverLetter,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0F1720) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Text(
                application.coverLetter,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  height: 1.5,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (application.resumeUrl.isNotEmpty) ...[
              Text(
                AppLocalizations.of(context)!.resumeCv,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  // Mock open URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.openingResume,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.viewResume,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: isDarkMode ? Colors.grey[500] : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(context, 'rejected'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.rejectCandidate),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(context, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.acceptCandidate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
