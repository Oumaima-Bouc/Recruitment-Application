import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubits/companies_cubit.dart';
import '../logic/cubits/companies_state.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/auth_state.dart';
import 'company_public_profile_screen.dart';
import 'package:khedmni/l10n/app_localizations.dart';

class FollowedCompaniesScreen extends StatefulWidget {
  const FollowedCompaniesScreen({super.key});

  @override
  State<FollowedCompaniesScreen> createState() => _FollowedCompaniesScreenState();
}

class _FollowedCompaniesScreenState extends State<FollowedCompaniesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1D3557);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.following, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<CompaniesCubit, CompaniesState>(
        builder: (context, state) {
          if (state is CompaniesLoaded) {
            final followedIds = state.followedCompanyIds;
            final followedCompanies = state.companies.where((c) => followedIds.contains(c.id)).toList();

            if (followedCompanies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_outlined, size: 60, color: isDark ? Colors.grey : Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.youAreNotFollowingAnyCompanies,
                      style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: followedCompanies.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final company = followedCompanies[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyPublicProfileScreen(company: company),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tileColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)
                  ),
                  leading: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      image: company.logoUrl != null && company.logoUrl!.isNotEmpty
                          ? DecorationImage(fit: BoxFit.cover, image: NetworkImage(company.logoUrl!))
                          : null,
                    ),
                    child: company.logoUrl == null 
                        ? const Icon(Icons.business, color: Colors.grey) 
                        : null,
                  ),
                  title: Text(
                    company.name,
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  ),
                  subtitle: Text(
                    company.industry,
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                       final authState = context.read<AuthCubit>().state;
                       final userId = authState is AuthAuthenticated ? authState.user.id : null;
                       if (userId != null) {
                         context.read<CompaniesCubit>().toggleFollow(userId, company.id);
                       }
                    },
                    child: Text(AppLocalizations.of(context)!.unfollow, style: const TextStyle(color: Color(0xFFF77F00))),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
