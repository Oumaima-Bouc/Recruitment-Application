import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/colors.dart';
import '../models/job.dart';
import '../widgets/job_card_compact.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as error_widgets;
import '../logic/cubits/job_cubit.dart';
import '../logic/cubits/job_state.dart';
import '../models/company.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/auth_state.dart';
import '../core/routes/route_names.dart';
import 'company_public_profile_screen.dart';
import '../data/dao/company_dao.dart';
import 'job_details_screen.dart';
import '../widgets/category_item.dart';
import 'package:khedmni/l10n/app_localizations.dart';

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({super.key});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  Timer? _searchDebounce;
  
  @override
  void initState() {
    super.initState();
    context.read<JobCubit>().loadJobs().then((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<JobCubit>().loadSavedJobs(authState.user.id);
      }
    });
  }

  void _showJobDetails(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailsScreen(job: job),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> _categories = [
      {'title': AppLocalizations.of(context)!.categoryAll, 'icon': Icons.grid_view},
      {'title': AppLocalizations.of(context)!.categoryITTech, 'icon': Icons.computer},
      {'title': AppLocalizations.of(context)!.categoryDesign, 'icon': Icons.palette},
      {'title': AppLocalizations.of(context)!.categoryMarketing, 'icon': Icons.campaign},
      {'title': AppLocalizations.of(context)!.categoryFinance, 'icon': Icons.payments},
      {'title': AppLocalizations.of(context)!.categoryEducation, 'icon': Icons.school},
      {'title': AppLocalizations.of(context)!.categoryHealth, 'icon': Icons.medical_services},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.allOpportunities,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<JobCubit, JobState>(
        builder: (context, state) {
          if (state is JobLoading) {
            return LoadingWidget(
              message: AppLocalizations.of(context)!.loadingJobs,
            );
          }

          if (state is JobError) {
            return error_widgets.ErrorWidget(
              message: state.message,
              onRetry: () => context.read<JobCubit>().loadJobs(),
            );
          }

          if (state is JobLoaded) {
            final jobCubit = context.read<JobCubit>();

            return Column(
              children: [
                // Header Section (Search + Filter + Categories)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- SEARCH BAR + FILTER ---
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[900] : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                                ),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  _searchDebounce?.cancel();
                                  _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                                    jobCubit.searchJobs(value);
                                  });
                                },
                                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.searchJobsHint,
                                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey),
                                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.black54),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[900] : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.tune, color: isDark ? Colors.white70 : Colors.black87), 
                              onPressed: () {
                                 showModalBottomSheet(
                                   context: context,
                                   isScrollControlled: true,
                                   backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                   shape: const RoundedRectangleBorder(
                                     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                   ),
                                   builder: (context) => DraggableScrollableSheet(
                                     initialChildSize: 0.4,
                                     minChildSize: 0.3,
                                     maxChildSize: 0.8,
                                     expand: false,
                                     builder: (context, scrollController) {
                                       return SingleChildScrollView(
                                         controller: scrollController,
                                         padding: const EdgeInsets.all(24),
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             Text(
                                               AppLocalizations.of(context)!.filterJobs,
                                               style: TextStyle(
                                                 fontSize: 20, 
                                                 fontWeight: FontWeight.bold,
                                                 color: isDark ? Colors.white : Colors.black,
                                               ),
                                             ),
                                             const SizedBox(height: 16),
                                             Text(
                                               AppLocalizations.of(context)!.jobType, 
                                               style: TextStyle(
                                                 fontWeight: FontWeight.w600,
                                                 color: isDark ? Colors.white70 : Colors.black,
                                               ),
                                             ),
                                             const SizedBox(height: 8),
                                             Wrap(
                                               spacing: 8,
                                               children: ['Full-time', 'Part-time', 'Remote', 'Internship', 'Contract'].map((type) {
                                                   return FilterChip(
                                                     label: Text(type),
                                                     selected: state.selectedJobType == type,
                                                     onSelected: (selected) {
                                                       jobCubit.filterByJobType(selected ? type : null);
                                                       Navigator.pop(context);
                                                     },
                                                     backgroundColor: isDark ? Colors.grey[850] : Colors.grey[100],
                                                     selectedColor: const Color(0xFF1E3A5F).withOpacity(0.2),
                                                     labelStyle: TextStyle(
                                                       color: state.selectedJobType == type 
                                                             ? const Color(0xFF1E3A5F) 
                                                             : (isDark ? Colors.white70 : Colors.black87),
                                                     ),
                                                   );
                                                 }).toList(),
                                             ),
                                           ],
                                         ),
                                       );
                                     },
                                   ),
                                 );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // --- CATEGORIES ---
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _categories.map((cat) {
                            final title = cat['title'] as String;
                            final icon = cat['icon'] as IconData;
                            final isSelected = (state.selectedCategory ?? 'All') == title;
                            return CategoryItem(
                              title: title,
                              icon: icon,
                              isSelected: isSelected,
                              onTap: () {
                                jobCubit.filterByCategory(
                                  title == 'All' ? null : title
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Job List
                Expanded(
                  child: state.jobs.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.noJobsFound,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: state.jobs.length,
                          itemBuilder: (context, index) {
                            return JobCardCompact(
                              job: state.jobs[index],
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              onTap: () => _showJobDetails(state.jobs[index]),
                              onCompanyTap: () async {
                                final job = state.jobs[index];
                                final company = await CompanyDao().getCompanyByName(job.company);
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompanyPublicProfileScreen(
                                        company: company ?? Company(
                                          id: 'dummy_id_${job.company.hashCode}',
                                          name: job.company,
                                          email: 'contact@${job.company.replaceAll(' ', '').toLowerCase()}.com',
                                          industry: 'Technology',
                                          website: 'www.${job.company.replaceAll(' ', '').toLowerCase()}.com',
                                          description: 'Leading company in ${job.location}',
                                          contact: '+1234567890',
                                          logoUrl: null,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return Center(
            child: Text(AppLocalizations.of(context)!.noJobsAvailable),
          );
        },
      ),
    );
  }
}
