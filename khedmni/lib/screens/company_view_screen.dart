import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubits/company_cubit.dart';
import '../logic/cubits/company_state.dart';
import '../models/company.dart';
import 'edit_company_profile_screen.dart';
import '../l10n/app_localizations.dart';

// Color constants
const Color kPrimaryDarkBlue = Color(0xFF1D3557);
const Color kPrimaryOrange = Color(0xFFF77F00);

class CompanyOwnProfileScreen extends StatelessWidget {
  final Company? company;
  final bool isEditable;

  const CompanyOwnProfileScreen({
    super.key,
    this.company,
    this.isEditable = true,
  });

  // DUMMY DATA for UI showcase
  final int _totalJobsPosted = 12;
  final int _totalApplications = 156;
  final int _profileViews = 2847;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        Company? displayCompany = company;

        if (displayCompany == null && state is CompanyLoaded) {
          displayCompany = state.company;
        }

        if (displayCompany == null) {
          if (state is! CompanyLoading) {
            context.read<CompanyCubit>().loadCompanyInfo('c1');
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDarkMode
              ? const Color(0xFF0B0F12)
              : Colors.grey[50],
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDarkMode
                ? const Color(0xFF0F1720)
                : Colors.white,
            elevation: 0,
            title: Row(children: [Image.asset('assets/photos/logo.png')]),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  // Share profile
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  // Navigate to settings
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Professional Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Picture - Left Side
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child:
                                  displayCompany.logoUrl != null &&
                                      displayCompany.logoUrl!.isNotEmpty
                                  ? Image.network(
                                      displayCompany.logoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildDefaultLogo(),
                                    )
                                  : _buildDefaultLogo(),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Company Info - Right Side
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Company Name with Verified Badge
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        displayCompany.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white
                                              : const Color(0xFF2C3E50),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                    if (displayCompany.isVerified) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.verified,
                                        color: kPrimaryOrange,
                                        size: 22,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Industry
                                Text(
                                  displayCompany.industry,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : const Color(0xFF7F8C8D),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Website
                                if (displayCompany.website.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      // Open website
                                    },
                                    child: Text(
                                      displayCompany.website,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: kPrimaryOrange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Edit Profile Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCompanyProfileScreen(
                                  company: displayCompany!,
                                ),
                              ),
                            );
                            if (result != null && result is Company) {
                              context.read<CompanyCubit>().updateCompany(
                                result,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryDarkBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text(
                            AppLocalizations.of(context)!.editProfile,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.work_outline,
                          value: '$_totalJobsPosted',
                          label: AppLocalizations.of(context)!.jobsPosted,
                          color: Colors.blue,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people_outline,
                          value: '$_totalApplications',
                          label: AppLocalizations.of(context)!.applications,
                          color: Colors.green,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.visibility_outlined,
                          value: '$_profileViews',
                          label: AppLocalizations.of(context)!.profileViews,
                          color: kPrimaryOrange,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Verification Status Card
                if (!displayCompany.isVerified)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.orange[900]!.withOpacity(0.2)
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange[700],
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.notVerified,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.orange[300]
                                        : Colors.orange[900],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  displayCompany.verificationDocs.isEmpty
                                      ? AppLocalizations.of(
                                          context,
                                        )!.uploadDocumentsToGetVerified
                                      : AppLocalizations.of(
                                          context,
                                        )!.documentsSubmittedPendingReview,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.orange[400]
                                        : Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // About Section
                _buildSectionCard(
                  title: AppLocalizations.of(context)!.aboutSection,
                  icon: Icons.info_outline,
                  isDarkMode: isDarkMode,
                  child: Text(
                    displayCompany.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.6,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Contact Information
                _buildSectionCard(
                  title: AppLocalizations.of(context)!.contactInformation,
                  icon: Icons.contact_phone_outlined,
                  isDarkMode: isDarkMode,
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: AppLocalizations.of(context)!.email,
                        value: displayCompany.email,
                        color: Colors.blue,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: AppLocalizations.of(context)!.phone,
                        value: displayCompany.contact,
                        color: Colors.green,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.language_outlined,
                        label: AppLocalizations.of(context)!.website,
                        value: displayCompany.website,
                        color: kPrimaryOrange,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.quickActions,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionTile(
                        icon: Icons.lock_outline,
                        title: AppLocalizations.of(context)!.changePassword,
                        color: Colors.blue,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          // Navigate to change password
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionTile(
                        icon: Icons.notifications_outlined,
                        title: AppLocalizations.of(
                          context,
                        )!.notificationSettings,
                        color: Colors.purple,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          // Navigate to notification settings
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionTile(
                        icon: Icons.help_outline,
                        title: AppLocalizations.of(context)!.helpSupport,
                        color: Colors.orange,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          // Navigate to help
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionTile(
                        icon: Icons.logout,
                        title: AppLocalizations.of(context)!.logout,
                        color: Colors.red,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      color: Colors.grey[100],
      child: Icon(Icons.business_rounded, size: 45, color: Colors.grey[400]),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kPrimaryOrange, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[700]),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.logoutTitle,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.areYouSureLogout,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: isDarkMode ? Colors.grey[300] : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: GoogleFonts.inter(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Perform logout
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );
  }
}
