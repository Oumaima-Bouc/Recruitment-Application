import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khedmni/l10n/app_localizations.dart';
import 'package:khedmni/logic/cubits/language_cubit.dart';
import 'package:khedmni/core/routes/route_names.dart';
import '../models/company.dart';
import '../models/job_post.dart';
import 'applications_screen.dart';
import 'company_view_screen.dart';
import 'post_offer.dart';
import 'edit_company_profile_screen.dart';

// Color constants
const Color kPrimaryDarkBlue = Color(0xFF1D3557);
const Color kPrimaryOrange = Color(0xFFF77F00);

class CompanyHomeScreen extends StatefulWidget {
  final Company company;

  const CompanyHomeScreen({super.key, required this.company});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  int _selectedIndex = 0;
  final List<JobPost> _jobPosts = [];
  String _selectedFilter = 'All Jobs';
  late Company _currentCompany;

  // DUMMY DATA for UI showcase
  final int _activeJobsCount = 5;
  final int _newApplicationsToday = 8;
  final int _totalApplicationsThisWeek = 23;
  final int _totalApplicants = 47;

  @override
  void initState() {
    super.initState();
    _currentCompany = widget.company;
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToPostOffer() {
    if (_currentCompany.verificationDocs.isEmpty) {
      _showUploadDocumentsRequiredDialog();
      return;
    }
    if (!_currentCompany.isVerified) {
      _showVerificationRequiredDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostOfferScreen(company: _currentCompany),
      ),
    );
  }

  void _showUploadDocumentsRequiredDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.upload_file, color: kPrimaryOrange, size: 28),
            const SizedBox(width: 12),
            Text(
              l10n.uploadDocumentsRequired,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.uploadDocumentsMsg,
              style: GoogleFonts.lato(
                fontSize: 15,
                height: 1.5,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.orange[900]!.withOpacity(0.2)
                    : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.orange[700]! : Colors.orange[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.requiredDocuments,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? Colors.orange[300]
                          : Colors.orange[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDocumentItem(l10n.businessRegistration),
                  _buildDocumentItem(l10n.taxDocuments),
                  _buildDocumentItem(l10n.companyLicense),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.lato(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditCompanyProfileScreen(company: _currentCompany),
                ),
              );
              if (result != null && result is Company) {
                setState(() {
                  _currentCompany = result;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.edit, size: 18),
            label: Text(l10n.goToEditProfile),
          ),
        ],
      ),
    );
  }

  void _showVerificationRequiredDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.verified_user, color: kPrimaryOrange, size: 28),
            const SizedBox(width: 12),
            Text(
              l10n.verificationPending,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.verificationSubmittedMsg,
              style: GoogleFonts.lato(
                fontSize: 15,
                height: 1.5,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.blue[900]!.withOpacity(0.2)
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.blue[700]! : Colors.blue[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isDarkMode ? Colors.blue[400] : Colors.blue[800],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.canPostJobsWhenVerified,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: isDarkMode ? Colors.blue[300] : Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryDarkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: kPrimaryOrange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F12) : Colors.grey[50],
      appBar: _selectedIndex == 2
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: isDarkMode
                  ? const Color(0xFF0F1720)
                  : Colors.white,
              elevation: 0,
              title: Row(children: [Image.asset('assets/photos/logo.png')]),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onPressed: () {},
                    ),
                    if (_newApplicationsToday > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _newApplicationsToday > 9
                                ? '9+'
                                : '$_newApplicationsToday',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.language,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onSelected: (String code) {
                    context.read<LanguageCubit>().changeLanguage(code);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'en',
                          child: Row(
                            children: [
                              Text('🇺🇸', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text('English'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'fr',
                          child: Row(
                            children: [
                              Text('🇫🇷', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text('Français'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'ar',
                          child: Row(
                            children: [
                              Text('🇸🇦', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text('العربية'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : _selectedIndex == 1
          ? ApplicationsScreen(company: _currentCompany, jobPosts: _jobPosts)
          : CompanyOwnProfileScreen(company: _currentCompany),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: kPrimaryOrange,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.description_outlined),
            label: AppLocalizations.of(context)!.applications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: AppLocalizations.of(context)!.profileTitle,
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToPostOffer,
              backgroundColor: kPrimaryOrange,
              elevation: 4,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                AppLocalizations.of(context)!.postJob,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header Section
          Container(
            color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.welcomeBackTitle,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _currentCompany.name,
                                  style: GoogleFonts.lato(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: isDarkMode
                                        ? Colors.white
                                        : kPrimaryDarkBlue,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_currentCompany.isVerified) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.verified,
                                  color: kPrimaryOrange,
                                  size: 24,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings),
                        color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
                        onPressed: () =>
                            Navigator.pushNamed(context, RouteNames.settings),
                      ),
                    ),
                  ],
                ),
                if (!_currentCompany.isVerified) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.orange[900]!.withOpacity(0.2)
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.orange[700]!
                            : Colors.orange[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDarkMode
                              ? Colors.orange[400]
                              : Colors.orange[800],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _currentCompany.verificationDocs.isEmpty
                                ? AppLocalizations.of(
                                    context,
                                  )!.companyNotVerifiedMsg
                                : AppLocalizations.of(
                                    context,
                                  )!.verificationPendingMsg,
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: isDarkMode
                                  ? Colors.orange[300]
                                  : Colors.orange[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats Dashboard Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.dashboardOverview,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.work_outline,
                        title: AppLocalizations.of(context)!.activeJobs,
                        value: '$_activeJobsCount',
                        color: Colors.blue,
                        trend: AppLocalizations.of(context)!.trendThisWeek,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_outline,
                        title: AppLocalizations.of(context)!.totalApplicants,
                        value: '$_totalApplicants',
                        color: Colors.purple,
                        trend: AppLocalizations.of(
                          context,
                        )!.trendTotalApplicants,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.today_outlined,
                        title: AppLocalizations.of(context)!.newToday,
                        value: '$_newApplicationsToday',
                        color: Colors.green,
                        trend: AppLocalizations.of(context)!.applicationsWord,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up,
                        title: AppLocalizations.of(context)!.thisWeek,
                        value: '$_totalApplicationsThisWeek',
                        color: kPrimaryOrange,
                        trend: AppLocalizations.of(context)!.applicationsWord,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.quickActions,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.add_circle_outline,
                        label: AppLocalizations.of(context)!.postNewJob,
                        color: kPrimaryOrange,
                        onTap: _navigateToPostOffer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.description_outlined,
                        label: AppLocalizations.of(context)!.viewApplications,
                        color: kPrimaryDarkBlue,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent Applications Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.recentApplications,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.seeAll,
                        style: GoogleFonts.lato(
                          color: kPrimaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRecentApplicationCard(
                  name: 'Ahmed Benali',
                  jobTitle: 'Software Developer',
                  time: '2 hours ago',
                  avatarColor: Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildRecentApplicationCard(
                  name: 'Fatima Zahra',
                  jobTitle: 'Marketing Manager',
                  time: '5 hours ago',
                  avatarColor: Colors.purple,
                ),
                const SizedBox(height: 8),
                _buildRecentApplicationCard(
                  name: 'Karim Osman',
                  jobTitle: 'Graphic Designer',
                  time: '1 day ago',
                  avatarColor: Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Active Jobs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.yourActiveJobs,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(AppLocalizations.of(context)!.allJobs),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        AppLocalizations.of(context)!.mostApplications,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        AppLocalizations.of(context)!.expiringSoon,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(AppLocalizations.of(context)!.recent),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildJobCardEnhanced(
                  title: AppLocalizations.of(context)!.seniorFlutterDeveloper,
                  location: AppLocalizations.of(context)!.algiers,
                  applicants: 15,
                  daysLeft: 5,
                  type: AppLocalizations.of(context)!.fullTime,
                ),
                const SizedBox(height: 12),
                _buildJobCardEnhanced(
                  title: AppLocalizations.of(context)!.marketingSpecialist,
                  location: AppLocalizations.of(context)!.oran,
                  applicants: 8,
                  daysLeft: 12,
                  type: AppLocalizations.of(context)!.partTime,
                ),
                const SizedBox(height: 12),
                _buildJobCardEnhanced(
                  title: AppLocalizations.of(context)!.uiUxDesigner,
                  location: AppLocalizations.of(context)!.remote,
                  applicants: 22,
                  daysLeft: 3,
                  type: AppLocalizations.of(context)!.contract,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String trend,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withAlpha(50)
                : Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(51)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.lato(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentApplicationCard({
    required String name,
    required String jobTitle,
    required String time,
    required Color avatarColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withAlpha(30)
                : Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor.withAlpha(51),
            child: Text(
              name[0].toUpperCase(),
              style: GoogleFonts.lato(
                color: avatarColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Applied for $jobTitle',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'NEW',
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobCardEnhanced({
    required String title,
    required String location,
    required int applicants,
    required int daysLeft,
    required String type,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withAlpha(50)
                : Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[800]!
                              : Colors.grey[100]!,
                        ),
                        image:
                            _currentCompany.logoUrl != null &&
                                _currentCompany.logoUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_currentCompany.logoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          _currentCompany.logoUrl == null ||
                              _currentCompany.logoUrl!.isEmpty
                          ? Icon(
                              Icons.business,
                              color: isDarkMode
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : kPrimaryDarkBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildJobTag(Icons.access_time, type),
                    const SizedBox(width: 12),
                    _buildJobTag(Icons.calendar_today, '$daysLeft days left'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryOrange.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, size: 14, color: kPrimaryOrange),
                          const SizedBox(width: 4),
                          Text(
                            '$applicants',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobTag(IconData icon, String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? kPrimaryDarkBlue
              : (isDarkMode ? const Color(0xFF0F1720) : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? kPrimaryDarkBlue
                : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimaryDarkBlue.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.grey[300] : Colors.grey[600]),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
