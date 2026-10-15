import 'package:flutter/material.dart';
import 'package:khedmni/l10n/app_localizations.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/log_in.dart';
import '../../screens/signup_screen.dart';
import '../../screens/create_profile.dart';
import '../../screens/create_company_profile.dart';
import '../../screens/company_home_screen.dart';
import '../../screens/job_feed_screen.dart';
import '../../models/company.dart';
import '../../screens/company_view_screen.dart';
import '../../screens/post_offer.dart';
import '../../screens/notification_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/email_verification_interstitial.dart';
import '../../screens/settings_screen.dart';
import '../../screens/about_screen.dart';
import 'route_names.dart';

import '../../screens/main_layout.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
      case RouteNames.createProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              CreateProfileScreen(name: args['name'], email: args['email']),
        );
      case RouteNames.createCompanyProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CreateCompanyProfileScreen(
            name: args['name'],
            email: args['email'],
          ),
        );
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const MainLayout());
      case RouteNames.companyHome:
        return MaterialPageRoute(
          builder: (_) =>
              CompanyHomeScreen(company: settings.arguments as Company),
        );
      case RouteNames.jobFeed:
        return MaterialPageRoute(builder: (_) => const JobFeedScreen());
      case RouteNames.companyProfile:
        // Expect a Company object to be passed via settings.arguments
        final company = settings.arguments as Company?;
        if (company != null) {
          return MaterialPageRoute(
            builder: (_) =>
                CompanyOwnProfileScreen(company: company, isEditable: false),
          );
        }
        // Fallback when no company provided
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context)!.companyNotProvided),
            ),
          ),
        );
      case RouteNames.postOffer:
        return MaterialPageRoute(
          builder: (_) =>
              PostOfferScreen(company: settings.arguments as Company),
        );
      case RouteNames.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case RouteNames.emailVerificationInterstitial:
        return MaterialPageRoute(
          builder: (_) => const EmailVerificationInterstitialScreen(),
        );
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case RouteNames.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case RouteNames.application:
        // Application screen is not available; show placeholder
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text(
                AppLocalizations.of(context)!.applicationScreenNotImplemented,
              ),
            ),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text(
                '${AppLocalizations.of(context)!.noRouteDefined}: ${settings.name}',
              ),
            ),
          ),
        );
    }
  }
}
