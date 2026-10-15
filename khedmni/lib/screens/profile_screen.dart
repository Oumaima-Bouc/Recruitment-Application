import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:khedmni/main.dart'; // Ensure this exists for theme access if needed
import 'package:khedmni/screens/settings_screen.dart';
import 'package:khedmni/logic/cubits/auth_cubit.dart';
import 'package:khedmni/logic/cubits/auth_state.dart';
import 'package:khedmni/logic/cubits/job_cubit.dart';
import 'package:khedmni/logic/cubits/job_state.dart';
// import 'package:khedmni/logic/cubits/language_state.dart'; // Unused in this file
// import '../models/company.dart'; // Unused in this file
// import 'company_home_screen.dart'; // Unused in this file
import 'debug_db_viewer.dart';
import 'package:khedmni/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selectedTab = "applications"; // Track active tab

  @override
  Widget build(BuildContext context) {
    // ==========================
    // 🎨 DYNAMIC THEME COLORS
    // ==========================
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // We keep your brand colors but adapt them for dark mode consistency
    final Color kPrimaryBlue = colorScheme.primary; 
    final Color kTextPrimary = colorScheme.onSurface;
    final Color kTextSecondary = colorScheme.onSurfaceVariant;
    
    // Cards: Dark mode needs lighter gray, Light mode needs white
    final Color kCardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color kTagBg = isDark ? const Color(0xFF2C3E50) : const Color(0xFFBCC3CD);
    final Color kTagText = isDark ? Colors.white70 : const Color(0xFF1D3557);
    
    // Special accent (Orange)
    const Color kAccentOrange = Color(0xFFF77F00);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2, // Material 3 scroll effect
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DebugDbViewerScreen()),
            );
          },
          child: Text(
            AppLocalizations.of(context)!.profileTitle,
            style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
        ],
      ),

      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthAuthenticated) {
            final user = state.user;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // ======================
                  // 👤 PROFILE HEADER
                  // ======================
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary.withOpacity(0.2), width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null || user.photoUrl!.isEmpty
                          ? Icon(Icons.person, size: 60, color: colorScheme.primary)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: kTextPrimary),
                  ),
                  const SizedBox(height: 4),
                  if (user.title != null && user.title!.isNotEmpty)
                    Text(
                      user.title!,
                      style: textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w500, 
                        color: kPrimaryBlue
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    user.userType == 'company' 
                        ? AppLocalizations.of(context)!.companyAccount 
                        : (user.bio ?? 'No bio added yet.'),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium!.copyWith(
                      color: kTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ======================
                  // ✏️ EDIT PROFILE BUTTON
                  // ======================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Edit logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: Text(
                        AppLocalizations.of(context)!.editProfile,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ======================
                  // 🧠 SKILLS SECTION
                  // ======================
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.skills,
                      style: _sectionTitleStyle(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (user.skills != null && user.skills!.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.skills!.split(',').map((e) => 
                          _buildTagChip(e.trim(), kTagBg, kTagText)
                        ).toList(),
                      ),
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("No skills added yet.", style: TextStyle(color: kTextSecondary)),
                    ),

                  const SizedBox(height: 25),

                  // ======================
                  // 📄 CV SECTION
                  // ======================
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.cv,
                      style: _sectionTitleStyle(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (user.cvUrl == null || user.cvUrl!.isEmpty) ...[
                      // Empty CV State
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface, // Adapted
                          border: Border.all(color: kAccentOrange.withOpacity(0.5), style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                          // Subtle glow
                          boxShadow: [
                            BoxShadow(
                              color: kAccentOrange.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 48, color: kAccentOrange),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.uploadCvPrompt,
                              style: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold, color: kPrimaryBlue),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.uploadCvDesc,
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall!.copyWith(color: kTextSecondary),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.featureComingSoon)));
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kAccentOrange,
                                side: const BorderSide(color: kAccentOrange),
                              ),
                              child: Text(AppLocalizations.of(context)!.uploadCv),
                            )
                          ],
                        ),
                      )
                  ] else ...[
                      // Uploaded CV State
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: kCardBg,
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                             Icon(Icons.picture_as_pdf, color: Colors.red[400]),
                             const SizedBox(width: 12),
                             Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${user.name}_CV.pdf",
                                    style: TextStyle(
                                      color: kTextPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text("Last updated: 2 days ago", style: TextStyle(color: kTextSecondary, fontSize: 10))
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_red_eye_outlined, color: kPrimaryBlue),
                              onPressed: () {},
                              tooltip: "View",
                            ),
                            IconButton(
                              icon: Icon(Icons.file_upload_outlined, color: kPrimaryBlue),
                              onPressed: () {},
                              tooltip: "Update",
                            ),
                          ],
                        ),
                      ),
                  ],

                  const SizedBox(height: 35),

                  // ======================
                  // 📁 TABS SECTION
                  // ======================
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTab(context, AppLocalizations.of(context)!.myApplications, "applications"),
                        _buildTab(context, AppLocalizations.of(context)!.savedOpportunities, "saved"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ======================
                  // 💼 ANIMATED CONTENT
                  // ======================
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: selectedTab == "applications"
                        ? _buildJobCard(context, kCardBg, kTextPrimary, kTextSecondary, kPrimaryBlue)
                        : _buildSavedOpportunity(context, kCardBg, kTextPrimary, kTextSecondary, kPrimaryBlue),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          } else {
             return Center(child: Text("Please Log In", style: TextStyle(color: colorScheme.onSurface)));
          }
        },
      ),
    );
  }

  // ======================
  // 📌 Styles & Helpers
  // ======================

  TextStyle _sectionTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _buildTagChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, String key) {
    final bool isActive = selectedTab == key;
    final activeColor = const Color(0xFFF77F00);
    final inactiveColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = key),
      child: Container(
        color: Colors.transparent, // Increases touch area
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Theme.of(context).colorScheme.onSurface : inactiveColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 60 : 0, // Animate width
              height: 3,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2)
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================
  // 📌 Components
  // ======================

  Widget _buildJobCard(BuildContext context, Color cardBg, Color textPri, Color textSec, Color primary) {
    final List<dynamic> userApplications = []; // Mock data

    if (userApplications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.work_history_outlined, size: 60, color: textSec.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noApplicationsYet,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPri),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noApplicationsMessage,
              style: TextStyle(color: textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Example Application Card (Theme Aware)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50, width: 50,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.work_outline, color: primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Software Engineer",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPri),
                ),
                Text(
                  "Innovation Tech",
                  style: TextStyle(color: textSec, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9D9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Applied",
              style: TextStyle(color: Color(0xFFEB9743), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedOpportunity(BuildContext context, Color cardBg, Color textPri, Color textSec, Color primary) {
    return BlocBuilder<JobCubit, JobState>(
      builder: (context, state) {
        if (state is JobLoaded) {
          final savedJobs = state.jobs.where((j) => state.savedJobIds.contains(j.id)).toList();

          if (savedJobs.isEmpty) return _emptySavedState(context, textPri, textSec);

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savedJobs.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final job = savedJobs[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 48, width: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.business, color: textSec),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPri),
                          ),
                          Text(
                            job.company,
                            style: TextStyle(color: textSec, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark, color: Color(0xFFF77F00)),
                      onPressed: () {
                         final authState = context.read<AuthCubit>().state;
                         if (authState is AuthAuthenticated) {
                           context.read<JobCubit>().toggleSaveJob(authState.user.id, job.id);
                         }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
        return _emptySavedState(context, textPri, textSec);
      },
    );
  }

  Widget _emptySavedState(BuildContext context, Color textPri, Color textSec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bookmark_border, size: 50, color: textSec.withOpacity(0.5)),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.noJobsFound,
              style: TextStyle(color: textSec, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}