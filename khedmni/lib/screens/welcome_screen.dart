import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/colors.dart';
import '../core/routes/route_names.dart';
import '../l10n/app_localizations.dart';
import '../logic/cubits/language_cubit.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.language, color: isDark ? Colors.white : const Color(0xFF1D3557)),
            tooltip: 'Change Language',
            onSelected: (String code) {
              context.read<LanguageCubit>().changeLanguage(code);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 100),
              
              // Logo
              Center(
                child: Image.asset(
                  isDark 
                      ? 'assets/images/logo-khedmni-dark.png' 
                      : 'assets/images/Logo_Khedmni.png',
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 60),

              // Title & subtitle
              Text(
                l10n.welcome,
                style: GoogleFonts.lato(
                  color: isDark ? Colors.white : AppColors.darkBlue,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),

              // Spacer replaced with fixed space to avoid layout issues in unbounded test environments
              const SizedBox(height: 40),

              // Student / Individual button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, RouteNames.signup, arguments: 'student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: AppColors.primaryOrange.withOpacity(0.3),
                  ),
                  child: Text(
                    l10n.studentIndividual,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Company / Organization button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, RouteNames.signup, arguments: 'company'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: AppColors.darkBlue.withOpacity(0.3),
                  ),
                  child: Text(
                    l10n.companyOrganization,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${l10n.alreadyHaveAccount} ',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, RouteNames.login),
                    child: Text(
                      l10n.signIn,
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
