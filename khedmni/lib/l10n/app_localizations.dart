import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How would you like to use the app?'**
  String get welcomeSubtitle;

  /// No description provided for @studentIndividual.
  ///
  /// In en, this message translates to:
  /// **'Student/Individual'**
  String get studentIndividual;

  /// No description provided for @companyOrganization.
  ///
  /// In en, this message translates to:
  /// **'Company/Organization'**
  String get companyOrganization;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey'**
  String get signInToContinue;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @linkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedin;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createYourAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @enterYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmailAddress;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign up with'**
  String get orSignUpWith;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordMinLength8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength8;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterEmail2.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail2;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @pleaseEnterPassword2.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword2;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @companyAccount.
  ///
  /// In en, this message translates to:
  /// **'Company Account'**
  String get companyAccount;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @cv.
  ///
  /// In en, this message translates to:
  /// **'CV'**
  String get cv;

  /// No description provided for @uploadCvPrompt.
  ///
  /// In en, this message translates to:
  /// **'Upload your CV'**
  String get uploadCvPrompt;

  /// No description provided for @uploadCvDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your resume to apply faster'**
  String get uploadCvDesc;

  /// No description provided for @uploadCv.
  ///
  /// In en, this message translates to:
  /// **'Upload CV'**
  String get uploadCv;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon!'**
  String get featureComingSoon;

  /// No description provided for @myApplications.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get myApplications;

  /// No description provided for @savedOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Saved Opportunities'**
  String get savedOpportunities;

  /// No description provided for @noJobsFound.
  ///
  /// In en, this message translates to:
  /// **'No jobs found'**
  String get noJobsFound;

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @postJob.
  ///
  /// In en, this message translates to:
  /// **'Post Job'**
  String get postJob;

  /// No description provided for @searchJobsHint.
  ///
  /// In en, this message translates to:
  /// **'Search for jobs or internships'**
  String get searchJobsHint;

  /// No description provided for @welcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBackTitle;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @noJobPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No job posts yet'**
  String get noJobPostsYet;

  /// No description provided for @createFirstJobPost.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first job post'**
  String get createFirstJobPost;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @filterClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get filterClosed;

  /// No description provided for @filterDrafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get filterDrafts;

  /// No description provided for @applicants.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get applicants;

  /// No description provided for @seeApplications.
  ///
  /// In en, this message translates to:
  /// **'See Applications'**
  String get seeApplications;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @tabJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get tabJobs;

  /// No description provided for @tabInternships.
  ///
  /// In en, this message translates to:
  /// **'Internship'**
  String get tabInternships;

  /// No description provided for @loadingJobs.
  ///
  /// In en, this message translates to:
  /// **'Loading jobs...'**
  String get loadingJobs;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get hello;

  /// No description provided for @noJobsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No jobs available'**
  String get noJobsAvailable;

  /// No description provided for @removedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved jobs'**
  String get removedFromSaved;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites!'**
  String get addedToFavorites;

  /// No description provided for @loginToSave.
  ///
  /// In en, this message translates to:
  /// **'Login to save jobs'**
  String get loginToSave;

  /// No description provided for @requirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirements;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @loginToApply.
  ///
  /// In en, this message translates to:
  /// **'Please log in to apply.'**
  String get loginToApply;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted!'**
  String get applicationSubmitted;

  /// No description provided for @applicationSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted Successfully!'**
  String get applicationSubmittedSuccess;

  /// No description provided for @missingCvWarning.
  ///
  /// In en, this message translates to:
  /// **'Note: Without a CV, your application is less likely to be noticed. Please upload one in Profile.'**
  String get missingCvWarning;

  /// No description provided for @uploadCvAction.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD CV'**
  String get uploadCvAction;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @applications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applications;

  /// No description provided for @createCompanyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Company Account'**
  String get createCompanyAccount;

  /// No description provided for @joinAsCompany.
  ///
  /// In en, this message translates to:
  /// **'Join us as a company and find talent'**
  String get joinAsCompany;

  /// No description provided for @joinUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join us and start your journey'**
  String get joinUsSubtitle;

  /// No description provided for @signupStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey'**
  String get signupStudentTitle;

  /// No description provided for @signupStudentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey with Khedmni as an individual'**
  String get signupStudentSubtitle;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get enterCompanyName;

  /// No description provided for @pleaseEnterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter company name'**
  String get pleaseEnterCompanyName;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @createAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountAction;

  /// No description provided for @pleaseSelectDeadline.
  ///
  /// In en, this message translates to:
  /// **'Please select a deadline'**
  String get pleaseSelectDeadline;

  /// No description provided for @jobPostedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Job Posted Successfully!'**
  String get jobPostedSuccess;

  /// No description provided for @postNewOffer.
  ///
  /// In en, this message translates to:
  /// **'Post a new offer'**
  String get postNewOffer;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitle;

  /// No description provided for @jobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g Senior Product Designer'**
  String get jobTitleHint;

  /// No description provided for @pleaseEnterJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter job title'**
  String get pleaseEnterJobTitle;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescription;

  /// No description provided for @jobDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write a detailed job description and expectations'**
  String get jobDescriptionHint;

  /// No description provided for @pleaseEnterJobDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter job description'**
  String get pleaseEnterJobDescription;

  /// No description provided for @requirementsLabel.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirementsLabel;

  /// No description provided for @requirementsHint.
  ///
  /// In en, this message translates to:
  /// **'List qualifications, experience, and...'**
  String get requirementsHint;

  /// No description provided for @pleaseEnterRequirements.
  ///
  /// In en, this message translates to:
  /// **'Please enter requirements'**
  String get pleaseEnterRequirements;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g Tunis, Remote'**
  String get locationHint;

  /// No description provided for @pleaseEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter location'**
  String get pleaseEnterLocation;

  /// No description provided for @applicationDeadline.
  ///
  /// In en, this message translates to:
  /// **'Application Deadline'**
  String get applicationDeadline;

  /// No description provided for @selectDeadline.
  ///
  /// In en, this message translates to:
  /// **'Select deadline'**
  String get selectDeadline;

  /// No description provided for @postOfferAction.
  ///
  /// In en, this message translates to:
  /// **'Post Offer'**
  String get postOfferAction;

  /// No description provided for @fullTime.
  ///
  /// In en, this message translates to:
  /// **'Full-Time'**
  String get fullTime;

  /// No description provided for @partTime.
  ///
  /// In en, this message translates to:
  /// **'Part-Time'**
  String get partTime;

  /// No description provided for @contract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contract;

  /// No description provided for @freelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get freelance;

  /// No description provided for @remote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// No description provided for @internship.
  ///
  /// In en, this message translates to:
  /// **'Internship'**
  String get internship;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to get noticed'**
  String get completeProfileSubtitle;

  /// No description provided for @professionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Title'**
  String get professionalTitle;

  /// No description provided for @professionalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Flutter Developer'**
  String get professionalTitleHint;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your title'**
  String get pleaseEnterTitle;

  /// No description provided for @skillsHint.
  ///
  /// In en, this message translates to:
  /// **'Add a skill (e.g. Dart)'**
  String get skillsHint;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself...'**
  String get bioHint;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @uploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload Logo'**
  String get uploadLogo;

  /// No description provided for @industry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industry;

  /// No description provided for @industryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Technology, Finance, Healthcare'**
  String get industryHint;

  /// No description provided for @pleaseEnterIndustry.
  ///
  /// In en, this message translates to:
  /// **'Please enter industry'**
  String get pleaseEnterIndustry;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @websiteHint.
  ///
  /// In en, this message translates to:
  /// **'www.yourcompany.com'**
  String get websiteHint;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @contactNumberHint.
  ///
  /// In en, this message translates to:
  /// **'+216 XX XXX XXX'**
  String get contactNumberHint;

  /// No description provided for @pleaseEnterContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter contact number'**
  String get pleaseEnterContactNumber;

  /// No description provided for @companyDescription.
  ///
  /// In en, this message translates to:
  /// **'Company Description'**
  String get companyDescription;

  /// No description provided for @companyDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your company...'**
  String get companyDescriptionHint;

  /// No description provided for @pleaseEnterCompanyDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter company description'**
  String get pleaseEnterCompanyDescription;

  /// No description provided for @noActiveJobPosts.
  ///
  /// In en, this message translates to:
  /// **'No active job posts'**
  String get noActiveJobPosts;

  /// No description provided for @postedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Posted: '**
  String get postedPrefix;

  /// No description provided for @deadlinePrefix.
  ///
  /// In en, this message translates to:
  /// **'Deadline: '**
  String get deadlinePrefix;

  /// No description provided for @applicantsSuffix.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get applicantsSuffix;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @loadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Loading notifications...'**
  String get loadingNotifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(Object days);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(Object hours);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @createCompanyProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Company Profile'**
  String get createCompanyProfileTitle;

  /// No description provided for @noApplicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No Applications Yet'**
  String get noApplicationsYet;

  /// No description provided for @noApplicationsMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t applied to any jobs yet. Start exploring opportunities!'**
  String get noApplicationsMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @securitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage password and account security'**
  String get securitySubtitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Password change failed'**
  String get passwordChangeFailed;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get enterCurrentPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get editDetails;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @verificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationTitle;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// No description provided for @verificationSentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 4-digit verification code to'**
  String get verificationSentTo;

  /// No description provided for @verifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get verifyAccount;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendCode;

  /// No description provided for @stepSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get stepSignUp;

  /// No description provided for @stepVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get stepVerify;

  /// No description provided for @stepProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get stepProfile;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get invalidCode;

  /// No description provided for @enter4DigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 4-digit code completely'**
  String get enter4DigitCode;

  /// No description provided for @emailVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success! Email verified.'**
  String get emailVerifiedSuccess;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @aboutKhedmni.
  ///
  /// In en, this message translates to:
  /// **'About Khedmni'**
  String get aboutKhedmni;

  /// No description provided for @whoWeAre.
  ///
  /// In en, this message translates to:
  /// **'Who we are'**
  String get whoWeAre;

  /// No description provided for @whoWeAreDescription.
  ///
  /// In en, this message translates to:
  /// **'Khedmni is a platform that connects talent with companies, making the hiring process easier and fairer.'**
  String get whoWeAreDescription;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow us for updates and product news'**
  String get followUs;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @subscribeToPro.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Khedmni-Pro'**
  String get subscribeToPro;

  /// No description provided for @subscribeToProDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock exclusive AI features.'**
  String get subscribeToProDesc;

  /// No description provided for @subscribeAction.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribeAction;

  /// No description provided for @cvLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String cvLastUpdated(Object date);

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @noSkillsAdded.
  ///
  /// In en, this message translates to:
  /// **'No skills added yet.'**
  String get noSkillsAdded;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @appliedOn.
  ///
  /// In en, this message translates to:
  /// **'Applied on {date}'**
  String appliedOn(Object date);

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Khedmni Version {version}'**
  String aboutVersion(Object version);

  /// No description provided for @ourMission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMission;

  /// No description provided for @missionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bridging talent & opportunity'**
  String get missionSubtitle;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @studentCredits.
  ///
  /// In en, this message translates to:
  /// **'From ENSIA students - Algiers, Algeria'**
  String get studentCredits;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️'**
  String get madeWith;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @deleteCv.
  ///
  /// In en, this message translates to:
  /// **'Delete CV'**
  String get deleteCv;

  /// No description provided for @addSkillHint.
  ///
  /// In en, this message translates to:
  /// **'Add a skill...'**
  String get addSkillHint;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @topCompanies.
  ///
  /// In en, this message translates to:
  /// **'Top Companies'**
  String get topCompanies;

  /// No description provided for @noCompaniesYet.
  ///
  /// In en, this message translates to:
  /// **'No companies yet.'**
  String get noCompaniesYet;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @followCompany.
  ///
  /// In en, this message translates to:
  /// **'Follow Company'**
  String get followCompany;

  /// No description provided for @youAreNotFollowingAnyCompanies.
  ///
  /// In en, this message translates to:
  /// **'You are not following any companies yet.'**
  String get youAreNotFollowingAnyCompanies;

  /// No description provided for @followingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Following'**
  String followingCount(Object count);

  /// No description provided for @khedmniPro_feature1_title.
  ///
  /// In en, this message translates to:
  /// **'Get Featured'**
  String get khedmniPro_feature1_title;

  /// No description provided for @khedmniPro_feature1_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Priority listings to boost your visibility'**
  String get khedmniPro_feature1_subtitle;

  /// No description provided for @khedmniPro_feature2_title.
  ///
  /// In en, this message translates to:
  /// **'Premium Support'**
  String get khedmniPro_feature2_title;

  /// No description provided for @khedmniPro_feature2_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Dedicated support for Pro members'**
  String get khedmniPro_feature2_subtitle;

  /// No description provided for @khedmniPro_feature3_title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get khedmniPro_feature3_title;

  /// No description provided for @khedmniPro_feature3_subtitle.
  ///
  /// In en, this message translates to:
  /// **'See who viewed and applied to your listings'**
  String get khedmniPro_feature3_subtitle;

  /// No description provided for @homeRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Home screen refreshed'**
  String get homeRefreshed;

  /// No description provided for @pleaseLoginToFollowCompanies.
  ///
  /// In en, this message translates to:
  /// **'Please login to follow companies'**
  String get pleaseLoginToFollowCompanies;

  /// No description provided for @aboutTab.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTab;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @recentJobs.
  ///
  /// In en, this message translates to:
  /// **'Recent Jobs'**
  String get recentJobs;

  /// No description provided for @noBioAdded.
  ///
  /// In en, this message translates to:
  /// **'No bio added yet.'**
  String get noBioAdded;

  /// No description provided for @companyProfile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get companyProfile;

  /// No description provided for @openJobs.
  ///
  /// In en, this message translates to:
  /// **'Open Jobs'**
  String get openJobs;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @deleteCvConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your CV?'**
  String get deleteCvConfirmation;

  /// No description provided for @cvRemoved.
  ///
  /// In en, this message translates to:
  /// **'CV removed.'**
  String get cvRemoved;

  /// No description provided for @cvUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'CV uploaded successfully!'**
  String get cvUploadedSuccess;

  /// No description provided for @errorOpeningCv.
  ///
  /// In en, this message translates to:
  /// **'Error opening CV: {error}'**
  String errorOpeningCv(Object error);

  /// No description provided for @couldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open file: {message}'**
  String couldNotOpenFile(Object message);

  /// No description provided for @errorPickingCv.
  ///
  /// In en, this message translates to:
  /// **'Error picking CV: {error}'**
  String errorPickingCv(Object error);

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please Log In'**
  String get pleaseLogIn;

  /// No description provided for @allOpportunities.
  ///
  /// In en, this message translates to:
  /// **'All Opportunities'**
  String get allOpportunities;

  /// No description provided for @filterJobs.
  ///
  /// In en, this message translates to:
  /// **'Filter Jobs'**
  String get filterJobs;

  /// No description provided for @jobType.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobType;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryITTech.
  ///
  /// In en, this message translates to:
  /// **'IT & Tech'**
  String get categoryITTech;

  /// No description provided for @categoryDesign.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get categoryDesign;

  /// No description provided for @categoryMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get categoryMarketing;

  /// No description provided for @categoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get categoryFinance;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @pleaseVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before applying.'**
  String get pleaseVerifyEmail;

  /// No description provided for @errorSubmittingApplication.
  ///
  /// In en, this message translates to:
  /// **'Error submitting application: {error}'**
  String errorSubmittingApplication(Object error);

  /// No description provided for @cvUploadedSuccessApply.
  ///
  /// In en, this message translates to:
  /// **'CV uploaded successfully! You can now apply.'**
  String get cvUploadedSuccessApply;

  /// No description provided for @companies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get companies;

  /// No description provided for @searchCompaniesHint.
  ///
  /// In en, this message translates to:
  /// **'Search companies...'**
  String get searchCompaniesHint;

  /// No description provided for @noCompaniesFound.
  ///
  /// In en, this message translates to:
  /// **'No companies found'**
  String get noCompaniesFound;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @applicationDetails.
  ///
  /// In en, this message translates to:
  /// **'Application Details'**
  String get applicationDetails;

  /// No description provided for @coverLetter.
  ///
  /// In en, this message translates to:
  /// **'Cover Letter'**
  String get coverLetter;

  /// No description provided for @resumeCv.
  ///
  /// In en, this message translates to:
  /// **'Resume / CV'**
  String get resumeCv;

  /// No description provided for @openingResume.
  ///
  /// In en, this message translates to:
  /// **'Opening Resume...'**
  String get openingResume;

  /// No description provided for @viewResume.
  ///
  /// In en, this message translates to:
  /// **'View Resume.pdf'**
  String get viewResume;

  /// No description provided for @rejectCandidate.
  ///
  /// In en, this message translates to:
  /// **'Reject Candidate'**
  String get rejectCandidate;

  /// No description provided for @acceptCandidate.
  ///
  /// In en, this message translates to:
  /// **'Accept Candidate'**
  String get acceptCandidate;

  /// No description provided for @proFeature1Title.
  ///
  /// In en, this message translates to:
  /// **'Get Featured'**
  String get proFeature1Title;

  /// No description provided for @proFeature1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Priority listings to boost your visibility'**
  String get proFeature1Subtitle;

  /// No description provided for @proFeature2Title.
  ///
  /// In en, this message translates to:
  /// **'Premium Support'**
  String get proFeature2Title;

  /// No description provided for @proFeature2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Dedicated support for Pro members'**
  String get proFeature2Subtitle;

  /// No description provided for @proFeature3Title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get proFeature3Title;

  /// No description provided for @proFeature3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'See who viewed and applied to your listings'**
  String get proFeature3Subtitle;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @joinNow.
  ///
  /// In en, this message translates to:
  /// **'Join Now'**
  String get joinNow;

  /// No description provided for @findNextOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Find your next opportunity'**
  String get findNextOpportunity;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @educationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education Level'**
  String get educationLevel;

  /// No description provided for @selectEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Select your education level'**
  String get selectEducationLevel;

  /// No description provided for @pleaseSelectEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Please select education level'**
  String get pleaseSelectEducationLevel;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @enterUniversity.
  ///
  /// In en, this message translates to:
  /// **'Enter your university'**
  String get enterUniversity;

  /// No description provided for @pleaseEnterUniversity.
  ///
  /// In en, this message translates to:
  /// **'Please enter your university'**
  String get pleaseEnterUniversity;

  /// No description provided for @major.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get major;

  /// No description provided for @enterMajor.
  ///
  /// In en, this message translates to:
  /// **'Enter your major'**
  String get enterMajor;

  /// No description provided for @workExperience.
  ///
  /// In en, this message translates to:
  /// **'Work Experience'**
  String get workExperience;

  /// No description provided for @describeWorkExperience.
  ///
  /// In en, this message translates to:
  /// **'Describe Your work experience'**
  String get describeWorkExperience;

  /// No description provided for @listSkills.
  ///
  /// In en, this message translates to:
  /// **'List your skills'**
  String get listSkills;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload a file'**
  String get uploadFile;

  /// No description provided for @dragAndDrop.
  ///
  /// In en, this message translates to:
  /// **' or drag and drop'**
  String get dragAndDrop;

  /// No description provided for @supportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported formats: PDF, DOC, DOCX - max 5MB'**
  String get supportedFormats;

  /// No description provided for @tapToChangeFile.
  ///
  /// In en, this message translates to:
  /// **'Tap to change file'**
  String get tapToChangeFile;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @codeAutofilled.
  ///
  /// In en, this message translates to:
  /// **'Code auto-filled — verifying...'**
  String get codeAutofilled;

  /// No description provided for @devCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Dev code copied to clipboard'**
  String get devCodeCopied;

  /// No description provided for @secureVerification.
  ///
  /// In en, this message translates to:
  /// **'Secure end-to-end verification'**
  String get secureVerification;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon!'**
  String get comingSoon;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @companyNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Company not provided'**
  String get companyNotProvided;

  /// No description provided for @applicationScreenNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Application screen not implemented'**
  String get applicationScreenNotImplemented;

  /// No description provided for @noRouteDefined.
  ///
  /// In en, this message translates to:
  /// **'No route defined for this page'**
  String get noRouteDefined;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @uploadDocumentsRequired.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents Required'**
  String get uploadDocumentsRequired;

  /// No description provided for @uploadDocumentsMsg.
  ///
  /// In en, this message translates to:
  /// **'Please upload verification documents before posting job offers.'**
  String get uploadDocumentsMsg;

  /// No description provided for @requiredDocuments.
  ///
  /// In en, this message translates to:
  /// **'Required documents:'**
  String get requiredDocuments;

  /// No description provided for @businessRegistration.
  ///
  /// In en, this message translates to:
  /// **'Business Registration'**
  String get businessRegistration;

  /// No description provided for @taxDocuments.
  ///
  /// In en, this message translates to:
  /// **'Tax Documents'**
  String get taxDocuments;

  /// No description provided for @companyLicense.
  ///
  /// In en, this message translates to:
  /// **'Company License'**
  String get companyLicense;

  /// No description provided for @goToEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Go to Edit Profile'**
  String get goToEditProfile;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get verificationPending;

  /// No description provided for @verificationSubmittedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your verification documents have been submitted and are awaiting admin approval.'**
  String get verificationSubmittedMsg;

  /// No description provided for @canPostJobsWhenVerified.
  ///
  /// In en, this message translates to:
  /// **'You can post jobs once your account is verified.'**
  String get canPostJobsWhenVerified;

  /// No description provided for @companyNotVerifiedMsg.
  ///
  /// In en, this message translates to:
  /// **'Company not verified. Upload documents to post jobs.'**
  String get companyNotVerifiedMsg;

  /// No description provided for @verificationPendingMsg.
  ///
  /// In en, this message translates to:
  /// **'Verification pending. We\'ll review your documents soon.'**
  String get verificationPendingMsg;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get dashboardOverview;

  /// No description provided for @activeJobs.
  ///
  /// In en, this message translates to:
  /// **'Active Jobs'**
  String get activeJobs;

  /// No description provided for @totalApplicants.
  ///
  /// In en, this message translates to:
  /// **'Total Applicants'**
  String get totalApplicants;

  /// No description provided for @newToday.
  ///
  /// In en, this message translates to:
  /// **'New Today'**
  String get newToday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @applicationsWord.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applicationsWord;

  /// No description provided for @trendThisWeek.
  ///
  /// In en, this message translates to:
  /// **'+2 this week'**
  String get trendThisWeek;

  /// No description provided for @trendTotalApplicants.
  ///
  /// In en, this message translates to:
  /// **'+12 this week'**
  String get trendTotalApplicants;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @postNewJob.
  ///
  /// In en, this message translates to:
  /// **'Post New Job'**
  String get postNewJob;

  /// No description provided for @viewApplications.
  ///
  /// In en, this message translates to:
  /// **'View Applications'**
  String get viewApplications;

  /// No description provided for @recentApplications.
  ///
  /// In en, this message translates to:
  /// **'Recent Applications'**
  String get recentApplications;

  /// No description provided for @yourActiveJobs.
  ///
  /// In en, this message translates to:
  /// **'Your Active Jobs'**
  String get yourActiveJobs;

  /// No description provided for @allJobs.
  ///
  /// In en, this message translates to:
  /// **'All Jobs'**
  String get allJobs;

  /// No description provided for @mostApplications.
  ///
  /// In en, this message translates to:
  /// **'Most Applications'**
  String get mostApplications;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get expiringSoon;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @seniorFlutterDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Senior Flutter Developer'**
  String get seniorFlutterDeveloper;

  /// No description provided for @marketingSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Marketing Specialist'**
  String get marketingSpecialist;

  /// No description provided for @uiUxDesigner.
  ///
  /// In en, this message translates to:
  /// **'UI/UX Designer'**
  String get uiUxDesigner;

  /// No description provided for @algiers.
  ///
  /// In en, this message translates to:
  /// **'Algiers, Algeria'**
  String get algiers;

  /// No description provided for @oran.
  ///
  /// In en, this message translates to:
  /// **'Oran, Algeria'**
  String get oran;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days left'**
  String get daysLeft;

  /// No description provided for @jobsPosted.
  ///
  /// In en, this message translates to:
  /// **'Jobs Posted'**
  String get jobsPosted;

  /// No description provided for @profileViews.
  ///
  /// In en, this message translates to:
  /// **'Profile Views'**
  String get profileViews;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get notVerified;

  /// No description provided for @uploadDocumentsToGetVerified.
  ///
  /// In en, this message translates to:
  /// **'Upload documents to get verified'**
  String get uploadDocumentsToGetVerified;

  /// No description provided for @documentsSubmittedPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Documents submitted, pending review'**
  String get documentsSubmittedPendingReview;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @editCompanyProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Company Profile'**
  String get editCompanyProfile;

  /// No description provided for @changeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change Logo'**
  String get changeLogo;

  /// No description provided for @companyInformation.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get companyInformation;

  /// No description provided for @pleaseEnterWebsite.
  ///
  /// In en, this message translates to:
  /// **'Please enter website'**
  String get pleaseEnterWebsite;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @verificationDocuments.
  ///
  /// In en, this message translates to:
  /// **'Verification Documents'**
  String get verificationDocuments;

  /// No description provided for @uploadBusinessRegistrationTaxDocs.
  ///
  /// In en, this message translates to:
  /// **'Upload business registration, tax documents, and company license'**
  String get uploadBusinessRegistrationTaxDocs;

  /// No description provided for @existingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Existing Documents:'**
  String get existingDocuments;

  /// No description provided for @newDocuments.
  ///
  /// In en, this message translates to:
  /// **'New Documents:'**
  String get newDocuments;

  /// No description provided for @addVerificationDocuments.
  ///
  /// In en, this message translates to:
  /// **'Add Verification Documents'**
  String get addVerificationDocuments;

  /// No description provided for @acceptedFormatsPdfJpgPng.
  ///
  /// In en, this message translates to:
  /// **'Accepted formats: PDF, JPG, PNG'**
  String get acceptedFormatsPdfJpgPng;

  /// No description provided for @companyPhotos.
  ///
  /// In en, this message translates to:
  /// **'Company Photos'**
  String get companyPhotos;

  /// No description provided for @showcaseCompanyWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Showcase your company workspace, team, or products'**
  String get showcaseCompanyWorkspace;

  /// No description provided for @currentPhotos.
  ///
  /// In en, this message translates to:
  /// **'Current Photos:'**
  String get currentPhotos;

  /// No description provided for @newPhotos.
  ///
  /// In en, this message translates to:
  /// **'New Photos:'**
  String get newPhotos;

  /// No description provided for @addCompanyPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Company Photos'**
  String get addCompanyPhotos;

  /// No description provided for @addUpTo10Photos.
  ///
  /// In en, this message translates to:
  /// **'Add up to 10 photos (JPG, PNG)'**
  String get addUpTo10Photos;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @logoSelected.
  ///
  /// In en, this message translates to:
  /// **'Logo selected: {fileName}'**
  String logoSelected(String fileName);

  /// No description provided for @errorPickingLogo.
  ///
  /// In en, this message translates to:
  /// **'Error picking logo: {error}'**
  String errorPickingLogo(String error);

  /// No description provided for @documentsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} document(s) added'**
  String documentsAdded(int count);

  /// No description provided for @errorPickingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Error picking documents: {error}'**
  String errorPickingDocuments(String error);

  /// No description provided for @photosAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s) added'**
  String photosAdded(int count);

  /// No description provided for @errorPickingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Error picking photos: {error}'**
  String errorPickingPhotos(String error);

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(String error);

  /// No description provided for @skipVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip Verification?'**
  String get skipVerificationTitle;

  /// No description provided for @skipVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'You can complete your profile now and upload verification documents later. Note: You must be verified before posting job offers.'**
  String get skipVerificationMessage;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @profileCreatedVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Profile created! Verification pending.'**
  String get profileCreatedVerificationPending;

  /// No description provided for @profileCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile created successfully!'**
  String get profileCreatedSuccessfully;

  /// No description provided for @errorCreatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error creating profile: {error}'**
  String errorCreatingProfile(String error);

  /// No description provided for @companyVerificationOptional.
  ///
  /// In en, this message translates to:
  /// **'Company Verification (Optional)'**
  String get companyVerificationOptional;

  /// No description provided for @verificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload official documents to verify your company. Required before posting job offers.'**
  String get verificationDescription;

  /// No description provided for @acceptedDocuments.
  ///
  /// In en, this message translates to:
  /// **'Accepted: Business License, Tax Registration, Company Certificate'**
  String get acceptedDocuments;

  /// No description provided for @uploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get uploadDocuments;

  /// No description provided for @addMoreDocuments.
  ///
  /// In en, this message translates to:
  /// **'Add More Documents'**
  String get addMoreDocuments;

  /// No description provided for @completeAndSubmitForVerification.
  ///
  /// In en, this message translates to:
  /// **'Complete & Submit for Verification'**
  String get completeAndSubmitForVerification;

  /// No description provided for @skipForNowLink.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNowLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
