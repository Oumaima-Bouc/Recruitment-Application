import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/job.dart';
import '../models/company.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/auth_state.dart';
import '../logic/cubits/job_cubit.dart';
import '../logic/cubits/job_state.dart';
import 'company_public_profile_screen.dart';
import '../models/application.dart';
import '../data/dao/application_dao.dart';
import '../data/dao/notification_dao.dart';
import '../models/notification_model.dart';
import '../logic/cubits/notification_cubit.dart';
import '../data/dao/company_dao.dart';

import 'package:khedmni/l10n/app_localizations.dart'; 
import '../core/routes/route_names.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({Key? key, required this.job}) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _favController;
  late Animation<double> _favScaleAnimation;
  bool _hasApplied = false;
  Company? _company;

  @override
  void initState() {
    super.initState();
    _favController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _favScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _favController, curve: Curves.easeInOut),
    );

    _favController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _favController.reverse();
      }
    });

    _checkApplicationStatus();

    // Load company info for logo display
    CompanyDao().getCompanyByName(widget.job.company).then((c) {
      if (mounted) {
        setState(() {
          _company = c;
        });
      }
    });
  }

  Future<void> _checkApplicationStatus() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final apps = await ApplicationDao().getApplicationsByStudentId(authState.user.id);
      final hasApplied = apps.any((app) => app.jobId == widget.job.id);
      if (mounted) {
        setState(() {
          _hasApplied = hasApplied;
        });
      }
    }
  }

  Future<void> _pickCv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        if (mounted) {
          context.read<AuthCubit>().updateProfile(cvUrl: path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.cvUploadedSuccessApply),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorPickingCv(e.toString()))),
        );
      }
    }
  }

  @override
  void dispose() {
    _favController.dispose();
    super.dispose();
  }

  void _handleSaveJob(BuildContext context, bool isSaved, String userId) {
    _favController.forward();
    context.read<JobCubit>().toggleSaveJob(userId, widget.job.id);
    
    // Feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved ? AppLocalizations.of(context)!.removedFromSaved : AppLocalizations.of(context)!.addedToFavorites,
          style: const TextStyle(color: Colors.white)
        ),
        backgroundColor: isSaved ? Colors.grey[800] : const Color(0xFFF77F00),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleApply(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Ensure email verified first
      final user = authState.user;
      if (!user.isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseVerifyEmail),
            action: SnackBarAction(
              label: 'Verify',
              onPressed: () => Navigator.pushNamed(context, RouteNames.emailVerificationInterstitial),
            ),
          ),
        );
        return;
      }

      // Check for CV using cvUrl
      final hasCV = user.cvUrl != null && user.cvUrl!.isNotEmpty;

      if (!hasCV) {
        // Show Message: Success but warn about CV
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(AppLocalizations.of(context)!.applicationSubmitted, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context)!.missingCvWarning, 
                         style: const TextStyle(fontSize: 13)),
                 ],
               ),
               backgroundColor: const Color(0xFFF77F00), // Warning Orange
               duration: const Duration(seconds: 5),
               action: SnackBarAction(
                 label: AppLocalizations.of(context)!.uploadCvAction,
                 textColor: Colors.white,
                 onPressed: _pickCv,
               ),
             ),
         );
      }
      // Success
      _submitApplication(context, user);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loginToApply)),
      );
    }
  }

  Future<void> _submitApplication(BuildContext context, dynamic user) async {
    try {
      final application = Application(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        jobId: widget.job.id,
        studentId: user.id,
        studentName: user.name,
        studentEmail: user.email,
        studentAvatar: user.photoUrl,
        coverLetter: 'Applying for ${widget.job.title}', // Default for now
        resumeUrl: user.cvUrl ?? '',
        appliedAt: DateTime.now(),
        status: 'pending',
      );

      await ApplicationDao().insertApplication(application);

      // Notify company (and student)
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_notif',
        title: 'Application Submitted',
        message: 'You applied for ${widget.job.title} at ${widget.job.company}.',
        timestamp: DateTime.now(),
        isRead: false,
        type: NotificationType.jobApplication,
        relatedId: application.id,
      );
      await NotificationDao().insertNotification(notification);

      if (context.mounted) {
        setState(() {
          _hasApplied = true;
        });
        // Update NotificationCubit to reflect new notification immediately
        context.read<NotificationCubit>().fetchNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.applicationSubmittedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSubmittingApplication(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _localizeJobType(BuildContext context, String jobType) {
    switch (jobType.toLowerCase()) {
      case 'full-time': return AppLocalizations.of(context)!.fullTime;
      case 'part-time': return AppLocalizations.of(context)!.partTime;
      case 'contract': return AppLocalizations.of(context)!.contract;
      case 'freelance': return AppLocalizations.of(context)!.freelance;
      case 'remote': return AppLocalizations.of(context)!.remote;
      case 'internship': return AppLocalizations.of(context)!.internship;
      default: return jobType;
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DARK MODE LOGIC START ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Core Colors
    const kPrimaryDarkBlue = Color(0xFF1D3557);
    const kPrimaryOrange = Color(0xFFF77F00);
    
    // Dynamic Colors based on Theme
    final kBgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA); // Pure black for cleaner dark mode
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    
    // Text Colors - CRITICAL for Clarity
    final mainTextColor = isDark ? Colors.white : kPrimaryDarkBlue;
    final bodyTextColor = isDark ? const Color(0xFFE0E0E0) : Colors.grey[800];
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    // --- DARK MODE LOGIC END ---

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: kBgColor,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                      BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, authState) {
                        final userId = (authState is AuthAuthenticated) ? authState.user.id : null;
                        
                        return BlocBuilder<JobCubit, JobState>(
                          builder: (context, jobState) {
                            bool isSaved = false;
                            if (jobState is JobLoaded && userId != null) {
                              isSaved = jobState.savedJobIds.contains(widget.job.id);
                            }

                            return ScaleTransition(
                              scale: _favScaleAnimation,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
                                    child: Icon(
                                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                                      color: isSaved ? kPrimaryOrange : (isDark ? Colors.white : Colors.black87),
                                      size: 24,
                                    ),
                                  ),
                                  onPressed: userId != null 
                                    ? () => _handleSaveJob(context, isSaved, userId)
                                    : () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.loginToSave))),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          // Subtle gradient in dark mode
                          colors: [
                            isDark ? Colors.white.withOpacity(0.05) : kPrimaryDarkBlue.withOpacity(0.1), 
                            kBgColor
                          ],
                        ),
                      ),
                      child: Center(
                          child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             GestureDetector(
                               onTap: () async {
                                  final company = _company ?? await CompanyDao().getCompanyByName(widget.job.company);
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CompanyPublicProfileScreen(
                                          company: company ?? Company(
                                            id: 'dummy_id_${widget.job.company.hashCode}',
                                            name: widget.job.company,
                                            email: 'contact@example.com',
                                            industry: 'Technology',
                                            website: 'www.example.com',
                                            description: 'Company description placeholder.',
                                            contact: '',
                                            logoUrl: null,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                               },
                               child: Hero(
                                  tag: 'company_logo_${widget.job.company}',
                                  child: Container(
                                     width: 80,
                                     height: 80,
                                     decoration: BoxDecoration(
                                       color: isDark ? const Color(0xFF2C2C2E) : cardColor,
                                       borderRadius: BorderRadius.circular(20),
                                       border: isDark ? Border.all(color: Colors.grey[800]!) : null,
                                       boxShadow: isDark 
                                          ? [] // No shadow in dark mode (cleaner)
                                          : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
                                       image: _company != null && _company!.logoUrl != null && _company!.logoUrl!.isNotEmpty
                                            ? DecorationImage(
                                                image: _company!.logoUrl!.startsWith('http')
                                                    ? NetworkImage(_company!.logoUrl!)
                                                    : FileImage(File(_company!.logoUrl!)) as ImageProvider,
                                               fit: BoxFit.cover,
                                             )
                                            : null,
                                     ),
                                     child: _company == null || _company!.logoUrl == null || _company!.logoUrl!.isEmpty
                                          ? Icon(Icons.business, size: 40, color: isDark ? Colors.white70 : kPrimaryDarkBlue)
                                          : null,
                                  ),
                               ),
                             ),
                           ],
                          ),
                       ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job Title
                        Center(
                          child: Text(
                            widget.job.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: mainTextColor, // Fixed for Dark Mode
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                         Center(
                           child: GestureDetector(
                             onTap: () async {
                                final company = await CompanyDao().getCompanyByName(widget.job.company);
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CompanyPublicProfileScreen(
                                        company: company ?? Company(
                                          id: 'dummy_id_${widget.job.company.hashCode}',
                                          name: widget.job.company,
                                          email: 'contact@example.com',
                                          industry: 'Technology',
                                          website: 'www.example.com',
                                          description: 'Company description placeholder.',
                                          contact: '',
                                          logoUrl: null,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                             },
                             child: Text(
                               widget.job.company,
                               style: GoogleFonts.lato(
                                 fontSize: 18,
                                 fontWeight: FontWeight.w600,
                                 color: kPrimaryOrange,
                               ),
                             ),
                           ),
                         ),
                         const SizedBox(height: 24),
                        
                        // Tags Row
                        Wrap(
                          spacing: 12, // Horizontal space
                          runSpacing: 12, // Vertical space
                          alignment: WrapAlignment.center,
                          children: [
                            _buildTag(widget.job.location, Icons.location_on_outlined),
                            _buildTag(_localizeJobType(context, widget.job.jobType), Icons.schedule),
                            _buildTag(widget.job.salary, Icons.attach_money),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Overview Title
                        Text(
                          AppLocalizations.of(context)!.overview,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: mainTextColor, // Fixed for Dark Mode
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Description Text
                        Text(
                          widget.job.description,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: bodyTextColor, // Fixed for Dark Mode
                            height: 1.6,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Requirements Title
                        Text(
                          AppLocalizations.of(context)!.requirements,
                          style: GoogleFonts.lato(
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                             color: mainTextColor, // Fixed for Dark Mode
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...widget.job.requirements.map((req) => _buildRequirementItem(req)).toList(),

                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Floating Bottom Bar for Apply
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: isDark ? [
                     // Light rim highlight for dark mode separation
                     BoxShadow(
                      color: Colors.white.withOpacity(0.05),
                      blurRadius: 0,
                      spreadRadius: 1,
                      offset: const Offset(0, -1),
                    ),
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: ElevatedButton(
                    onPressed: _hasApplied ? null : () => _handleApply(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryOrange,
                      disabledBackgroundColor: const Color(0xFF455A64),
                      disabledForegroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _hasApplied ? 0 : 8,
                      shadowColor: kPrimaryOrange.withOpacity(0.4),
                    ),
                    child: Text(
                      _hasApplied ? AppLocalizations.of(context)!.applied : AppLocalizations.of(context)!.applyNow,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tagBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final textColor = isDark ? Colors.grey[300] : Colors.grey[800];
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: tagBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    // Dynamic text color for list items
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey[300] : Colors.grey[700];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFF77F00),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 15,
                color: textColor, // Updated
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}