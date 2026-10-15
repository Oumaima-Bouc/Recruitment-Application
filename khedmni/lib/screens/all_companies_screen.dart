import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../logic/cubits/companies_cubit.dart';
import '../logic/cubits/companies_state.dart';
import '../models/company.dart';
import 'company_public_profile_screen.dart';
import 'package:khedmni/l10n/app_localizations.dart';

class AllCompaniesScreen extends StatefulWidget {
  const AllCompaniesScreen({super.key});

  @override
  State<AllCompaniesScreen> createState() => _AllCompaniesScreenState();
}

class _AllCompaniesScreenState extends State<AllCompaniesScreen> {
  String? _selectedIndustry;
  
  @override
  void initState() {
    super.initState();
    // We'll initialize _selectedIndustry in build or use a localized 'All'
  }
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Check Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // App Colors & Theme Variables
    const kPrimaryDarkBlue = Color(0xFF1D3557);
    const kPrimaryOrange = Color(0xFFF77F00);
    
    // "Blackkk" Theme Logic
    final bgColor = isDark ? Colors.black : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF141414) : Colors.white; // Very dark grey for cards in dark mode
    final textColor = isDark ? Colors.white : kPrimaryDarkBlue;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark ? Colors.grey[900]! : Colors.grey.shade300;
    final searchBarColor = isDark ? const Color(0xFF141414) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: bgColor, // Removes material 3 tint
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.companies,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          
          // --- 1. SEARCH BAR (Home Page Style) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: searchBarColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textColor),
                onChanged: (value) {
                  // Connect to your search logic here
                  // context.read<CompaniesCubit>().searchCompanies(value);
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchCompaniesHint,
                  hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey),
                  prefixIcon: Icon(
                    Icons.search, 
                    color: isDark ? Colors.grey[500] : Colors.black54
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),

          // --- 2. FILTER SECTION ---
          BlocBuilder<CompaniesCubit, CompaniesState>(
            builder: (context, state) {
              if (state is CompaniesLoaded) {
                 final industries = context.read<CompaniesCubit>().getIndustries();
                 return Container(
                   height: 50,
                   margin: const EdgeInsets.symmetric(vertical: 12),
                   child: ListView.separated(
                     padding: const EdgeInsets.symmetric(horizontal: 24),
                     scrollDirection: Axis.horizontal,
                     itemCount: industries.length,
                     separatorBuilder: (c, i) => const SizedBox(width: 8),
                     itemBuilder: (context, index) {
                       final ind = industries[index];
                       final isSelected = (_selectedIndustry ?? 'All') == ind;
                       return ChoiceChip(
                         label: Text(ind == 'All' ? AppLocalizations.of(context)!.categoryAll : ind),
                         labelStyle: TextStyle(
                           color: isSelected ? Colors.white : (isDark ? Colors.white : kPrimaryDarkBlue),
                           fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                           fontSize: 13,
                         ),
                         selected: isSelected,
                         showCheckmark: false,
                         selectedColor: kPrimaryOrange,
                         backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                         side: BorderSide(
                           color: isSelected 
                             ? Colors.transparent 
                             : (isDark ? Colors.grey[800]! : Colors.grey.shade300),
                         ),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(24),
                         ),
                         onSelected: (val) {
                           setState(() {
                             _selectedIndustry = ind;
                           });
                           context.read<CompaniesCubit>().filterCompanies(industry: ind);
                         },
                       );
                     },
                   ),
                 );
              }
              return const SizedBox(height: 16);
            },
          ),
          
          // --- 3. COMPANIES GRID ---
          Expanded(
            child: BlocBuilder<CompaniesCubit, CompaniesState>(
              builder: (context, state) {
                if (state is CompaniesLoading) {
                  return const Center(child: CircularProgressIndicator(color: kPrimaryOrange));
                } else if (state is CompaniesLoaded) {
                  if (state.companies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business_outlined, size: 64, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noCompaniesFound,
                            style: TextStyle(color: subTextColor, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75, // Aspect ratio for vertical card
                    ),
                    itemCount: state.companies.length,
                    itemBuilder: (context, index) {
                      final company = state.companies[index];
                      return _buildCompanyCard(
                        context, 
                        company, 
                        isDark, 
                        cardColor, 
                        textColor, 
                        subTextColor, 
                        borderColor, 
                        kPrimaryDarkBlue, 
                        kPrimaryOrange
                      );
                    },
                  );
                } else if (state is CompaniesError) {
                  return Center(child: Text("Error: ${state.message}", style: TextStyle(color: textColor)));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(
    BuildContext context, 
    Company company, 
    bool isDark,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
    Color borderColor,
    Color primaryDarkBlue,
    Color primaryOrange,
  ) {
    return GestureDetector(
      onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
               builder: (context) => CompanyPublicProfileScreen(company: company),
            ),
         );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.grey[900]! : Colors.grey.shade200),
          boxShadow: isDark ? [] : [
             BoxShadow(
                color: const Color(0xFF1D3557).withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 8),
             )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Spacer(),
             // Logo
             Container(
               height: 65, width: 65,
               padding: const EdgeInsets.all(2), // White border spacer
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: isDark ? Colors.grey[900] : Colors.white,
                 border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey.shade100, width: 1),
               ),
               child: ClipOval(
                 child: company.logoUrl != null && company.logoUrl!.isNotEmpty
                   ? (company.logoUrl!.startsWith('http')
                       ? Image.network(company.logoUrl!, fit: BoxFit.cover)
                       : Image.file(File(company.logoUrl!), fit: BoxFit.cover))
                   : Icon(Icons.business, size: 30, color: isDark ? Colors.white54 : primaryDarkBlue),
               ),
             ),
             const SizedBox(height: 12),
             
             // Name
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 10.0),
               child: Text(
                 company.name,
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontWeight: FontWeight.bold,
                   fontSize: 15,
                   color: textColor,
                 ),
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
               ),
             ),
             
             const SizedBox(height: 4),
             
             // Industry
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 10.0),
               child: Text(
                 company.industry,
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 12,
                   color: subTextColor,
                   fontWeight: FontWeight.w400,
                 ),
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
               ),
             ),
             
             const Spacer(),
             
             // "View" Button Style Footer
             Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(vertical: 12),
               decoration: BoxDecoration(
                 color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
                 borderRadius: const BorderRadius.only(
                   bottomLeft: Radius.circular(20),
                   bottomRight: Radius.circular(20),
                 ),
                 border: Border(top: BorderSide(color: borderColor)),
               ),
               child: Text(
                 AppLocalizations.of(context)!.viewProfile,
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 12,
                   fontWeight: FontWeight.bold,
                   color: primaryOrange,
                 ),
               ),
             )
          ],
        ),
      ),
    );
  }
}