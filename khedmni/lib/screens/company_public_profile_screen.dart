import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../models/company.dart';
import 'edit_company_profile_screen.dart';
import '../logic/cubits/company_cubit.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/auth_state.dart';
import '../logic/cubits/companies_cubit.dart';
import 'package:khedmni/l10n/app_localizations.dart';
import '../logic/cubits/companies_state.dart';

class CompanyPublicProfileScreen extends StatefulWidget {
  final Company company;
  final bool isOwnProfile;

  const CompanyPublicProfileScreen({
    super.key,
    required this.company,
    this.isOwnProfile = false,
  });

  @override
  State<CompanyPublicProfileScreen> createState() =>
      _CompanyPublicProfileScreenState();
}

class _CompanyPublicProfileScreenState extends State<CompanyPublicProfileScreen>
    with SingleTickerProviderStateMixin {
  late Company _currentCompany;
  final Color kPrimaryDarkBlue = const Color(0xFF1D3557);
  final Color kPrimaryOrange = const Color(0xFFF77F00);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentCompany = widget.company;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F12) : Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/photos/logo.png'),
        backgroundColor: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.language,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // Language selector
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
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture - Circular Professional Style
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[200]!,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryOrange.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            image:
                                _currentCompany.logoUrl != null &&
                                    _currentCompany.logoUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                      _currentCompany.logoUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child:
                              _currentCompany.logoUrl == null ||
                                  _currentCompany.logoUrl!.isEmpty
                              ? Icon(
                                  Icons.business_rounded,
                                  size: 50,
                                  color: Colors.grey[400],
                                )
                              : null,
                        ),
                        const SizedBox(width: 20),

                        // Company Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Company Name & Verification Badge
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _currentCompany.name,
                                      style: GoogleFonts.lato(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode
                                            ? Colors.white
                                            : kPrimaryDarkBlue,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  if (_currentCompany.isVerified) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: kPrimaryOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Industry Tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _currentCompany.industry,
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: kPrimaryOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Followers Count
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline_rounded,
                                    size: 16,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_currentCompany.followers} followers',
                                    style: GoogleFonts.lato(
                                      fontSize: 13,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        // Primary Action Button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: widget.isOwnProfile
                                ? () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditCompanyProfileScreen(
                                              company: _currentCompany,
                                            ),
                                      ),
                                    );
                                    if (result != null && result is Company) {
                                      setState(() {
                                        _currentCompany = result;
                                      });
                                      context
                                          .read<CompanyCubit>()
                                          .updateCompanyProfile(result);
                                    }
                                  }
                                : () {
                                    // Follow action
                                  },
                            icon: Icon(
                              widget.isOwnProfile ? Icons.edit : Icons.add,
                              size: 18,
                            ),
                            label: Text(
                              widget.isOwnProfile
                                  ? 'Edit Profile'
                                  : 'Follow Company',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryDarkBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Secondary Button - Visit Website
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Open website
                            },
                            icon: Icon(
                              Icons.language_rounded,
                              size: 18,
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : kPrimaryDarkBlue,
                            ),
                            label: Text(
                              'Website',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDarkMode
                                  ? Colors.grey[300]
                                  : kPrimaryDarkBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats Cards - More Prominent
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimaryDarkBlue.withOpacity(0.05),
                    kPrimaryOrange.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.work_outline_rounded,
                    value: '12',
                    label: 'Open Jobs',
                    isDarkMode: isDarkMode,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  ),
                  _buildStatItem(
                    icon: Icons.people_outline_rounded,
                    value: '${_currentCompany.followers}',
                    label: 'Followers',
                    isDarkMode: isDarkMode,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  ),
                  _buildStatItem(
                    icon: Icons.star_outline_rounded,
                    value: '4.8',
                    label: 'Rating',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // About Section
            _buildSection(
              title: 'About Company',
              icon: Icons.info_outline_rounded,
              isDarkMode: isDarkMode,
              child: Text(
                _currentCompany.description,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact Information
            _buildSection(
              title: 'Contact Information',
              icon: Icons.contact_phone_outlined,
              isDarkMode: isDarkMode,
              child: Column(
                children: [
                  _buildContactItem(
                    icon: Icons.phone_rounded,
                    label: 'Phone',
                    value: _currentCompany.contact,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: _currentCompany.email,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    icon: Icons.language_rounded,
                    label: 'Website',
                    value: _currentCompany.website,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Verification Status
            if (widget.isOwnProfile)
              _buildSection(
                title: 'Verification Status',
                icon: Icons.verified_user_outlined,
                isDarkMode: isDarkMode,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _currentCompany.isVerified
                        ? Colors.green.withOpacity(0.08)
                        : Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _currentCompany.isVerified
                          ? Colors.green.withOpacity(0.4)
                          : Colors.orange.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _currentCompany.isVerified
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _currentCompany.isVerified
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          color: _currentCompany.isVerified
                              ? Colors.green[700]
                              : Colors.orange[700],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentCompany.isVerified
                                  ? 'Verified Company'
                                  : 'Not Verified',
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _currentCompany.isVerified
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentCompany.isVerified
                                  ? 'Your company is verified. You can post jobs.'
                                  : 'Upload verification documents to get verified.',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isDarkMode,
  }) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryOrange, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F25) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: kPrimaryOrange, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1F25) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: kPrimaryOrange, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[900]!.withOpacity(0.3)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPrimaryOrange, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
