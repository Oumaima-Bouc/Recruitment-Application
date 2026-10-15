import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/auth_state.dart';
import '../widgets/category_item.dart';
import '../widgets/job_card_compact.dart';
import '../models/job.dart';
import '../models/company.dart';
import '../data/dao/company_dao.dart';
import 'job_details_screen.dart';
import 'company_public_profile_screen.dart';
import 'package:khedmni/core/routes/route_names.dart';
import 'dart:async';
import '../logic/cubits/job_cubit.dart';
import '../logic/cubits/job_state.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as error_widgets;
import '../logic/cubits/companies_cubit.dart';
import '../logic/cubits/companies_state.dart';
import 'all_companies_screen.dart';
import 'dart:io';
import 'package:khedmni/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _searchDebounce;

  // Khedmni‑Pro carousel state
  int _proIndex = 0;
  Timer? _proTimer;





  final List<Color> _proShades = [const Color(0xFFFF8C42), const Color(0xFFF77F00), const Color(0xFFFFA726)];

  @override
  void initState() {
    super.initState();
    context.read<JobCubit>().loadJobs();
    context.read<CompaniesCubit>().loadCompanies();

    // Start Khedmni‑Pro carousel auto-advance
    _proTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _proIndex = (_proIndex + 1) % 3;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _proTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kPrimaryDarkBlue = Color(0xFF1D3557);
    const kPrimaryOrange = Color(0xFFF77F00);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> _proFeatures = [
      {'title': AppLocalizations.of(context)!.proFeature1Title, 'subtitle': AppLocalizations.of(context)!.proFeature1Subtitle},
      {'title': AppLocalizations.of(context)!.proFeature2Title, 'subtitle': AppLocalizations.of(context)!.proFeature2Subtitle},
      {'title': AppLocalizations.of(context)!.proFeature3Title, 'subtitle': AppLocalizations.of(context)!.proFeature3Subtitle},
    ];
    // Determine pro card icon color based on gradient luminance for contrast
    final proLuminance = (_proShades[_proIndex].computeLuminance() + _proShades[(_proIndex + 1) % _proShades.length].computeLuminance()) / 2;
    // In light mode prefer a slightly darker grey for the menu icon for better visibility
    final proIconColor = !isDark ? Colors.grey[800]! : (proLuminance > 0.5 ? Colors.black87 : Colors.white);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main Content (Scrollable with RefreshIndicator)
            Expanded(
              child: RefreshIndicator(
                color: kPrimaryOrange,
                backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                onRefresh: () async {
                  await Future.wait([
                    context.read<JobCubit>().loadJobs(),
                    context.read<CompaniesCubit>().loadCompanies(),
                  ]);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.homeRefreshed),
                        backgroundColor: kPrimaryDarkBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section (Search only)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- SEARCH BAR ---
                            Container(
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
                                    context.read<JobCubit>().searchJobs(value);
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
                          ],
                        ),
                      ),

                      // --- KHEDMNI PRO PROMO CARD ---
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _proShades[_proIndex].withOpacity(1.0),
                                    _proShades[(_proIndex + 1) % _proShades.length].withOpacity(0.9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _proIndex == 0 ? AppLocalizations.of(context)!.khedmniPro_feature1_title : (_proIndex == 1 ? AppLocalizations.of(context)!.khedmniPro_feature2_title : AppLocalizations.of(context)!.khedmniPro_feature3_title),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _proIndex == 0 ? AppLocalizations.of(context)!.khedmniPro_feature1_subtitle : (_proIndex == 1 ? AppLocalizations.of(context)!.khedmniPro_feature2_subtitle : AppLocalizations.of(context)!.khedmniPro_feature3_subtitle),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.95),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: PopupMenuButton<int>(
                                      icon: Icon(Icons.more_vert, color: proIconColor),
                                      onSelected: (v) {
                                        if (v == 0) {
                                          Navigator.pushNamed(context, RouteNames.about);
                                        } else if (v == 1) {
                                          Navigator.pushNamed(context, RouteNames.settings);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        PopupMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.learnMore)),
                                        PopupMenuItem(value: 1, child: Text(AppLocalizations.of(context)!.subscribeAction)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_proFeatures.length, (i) {
                                final selected = i == _proIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  height: selected ? 10 : 8,
                                  width: selected ? 28 : 8,
                                  decoration: BoxDecoration(
                                    color: selected ? Colors.white : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      // --- TOP COMPANIES ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.topCompanies,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : kPrimaryDarkBlue,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AllCompaniesScreen()),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.seeAll,
                                    style: const TextStyle(color: kPrimaryOrange),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<CompaniesCubit, CompaniesState>(
                              builder: (context, state) {
                                if (state is CompaniesLoaded) {
                                  // Sort companies by follower count (desc) and take the top 5
                                  final topCompanies = List<Company>.from(state.companies)
                                    ..sort((a, b) => b.followers.compareTo(a.followers));

                                  final top5 = topCompanies.take(5).toList();

                                  if (top5.isEmpty) {
                                    return Text(
                                      AppLocalizations.of(context)!.noCompaniesYet,
                                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                    );
                                  }

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: top5.map((company) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CompanyPublicProfileScreen(company: company),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 20.0),
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 60, width: 60,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isDark ? Colors.grey[900] : Colors.white,
                                                    border: Border.all(
                                                      color: isDark ? Colors.grey[800]! : Colors.grey.shade200,
                                                    ),
                                                    image: company.logoUrl != null && company.logoUrl!.isNotEmpty
                                                        ? DecorationImage(
                                                            image: company.logoUrl!.startsWith('http') 
                                                                ? NetworkImage(company.logoUrl!) 
                                                                : FileImage(File(company.logoUrl!)) as ImageProvider,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                  ),
                                                  child: company.logoUrl == null || company.logoUrl!.isEmpty
                                                      ? Icon(Icons.business, color: isDark ? Colors.white70 : kPrimaryDarkBlue)
                                                      : null,
                                                ),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                  width: 70, 
                                                  child: Text(
                                                    company.name,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: isDark ? Colors.white70 : kPrimaryDarkBlue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- RECENT JOBS ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Jobs',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : kPrimaryDarkBlue,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, RouteNames.jobFeed);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.seeAll,
                                    style: const TextStyle(color: kPrimaryOrange),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<JobCubit, JobState>(
                              builder: (context, state) {
                                if (state is JobLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (state is JobError) {
                                  return Center(child: Text('Error: ${state.message}'));
                                }
                                if (state is JobLoaded) {
                                  if (state.jobs.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'No jobs found.',
                                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                      ),
                                    );
                                  }
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: state.jobs.take(5).map((job) {
                                        return JobCardCompact(
                                          job: job,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => JobDetailsScreen(job: job),
                                              ),
                                            );
                                          },
                                          onCompanyTap: () async {
                                            final company = await CompanyDao().getCompanyByName(job.company);
                                            if (mounted) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => CompanyPublicProfileScreen(
                                                    company: company ?? Company(
                                                      id: 'dummy_id_${job.company.hashCode}',
                                                      name: job.company,
                                                      email: 'contact@example.com',
                                                      industry: 'Technology',
                                                      website: 'www.${job.company.replaceAll(' ', '').toLowerCase()}.com',
                                                      description: 'Leading company in the tech industry.',
                                                      contact: '+216 12 345 678',
                                                      logoUrl: null,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}