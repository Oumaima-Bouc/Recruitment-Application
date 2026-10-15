import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
// Adjust these imports to match your project structure
import '../logic/cubits/theme_cubit.dart';
import '../logic/cubits/theme_state.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/auth_state.dart';
import 'package:khedmni/l10n/app_localizations.dart';
import 'edit_details_screen.dart';
import 'change_password_dialog.dart';
import 'package:khedmni/logic/cubits/language_cubit.dart';
import 'package:khedmni/logic/cubits/language_state.dart';
import '../core/routes/route_names.dart';

// --- Constants for the new design ---
const Color kBackgroundColor = Color(
  0xFFF2F2F7,
); // iOS-style grouped background
const Color kGroupColor = Colors.white;
const Color kTextPrimary = Color(0xFF000000);
const Color kTextSecondary = Color(0xFF8E8E93);
const Color kAccentOrange = Color(0xFFFF9500); // Vibrant orange from the image
const Color kBlueIcon = Color(0xFF1D3557); // Use app's primary dark blue
const double kGroupCornerRadius = 12.0;
const double kTilePaddingVertical = 16.0; // Increased for bigger fields

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Simulate premium status (always false as per request)
  Future<bool> _getPremiumStatus() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getBool('subscribed_to_feature') ?? false;
    return false; // "not active for any one till now"
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final groupBackground = isDarkMode ? Colors.grey[900]! : kGroupColor;
    final screenBackground = isDarkMode ? Colors.black : kBackgroundColor;
    final primaryTextColor = isDarkMode ? Colors.white : kTextPrimary;

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: screenBackground,
        iconTheme: IconThemeData(color: primaryTextColor),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        // Increased padding to make the page feel less empty
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            // --- Section 1: Profile ---
            _SettingsGroup(
              backgroundColor: groupBackground,
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return Padding(
                        padding: const EdgeInsets.all(kTilePaddingVertical),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32, // Larger avatar
                              backgroundColor: kAccentOrange,
                              backgroundImage:
                                  state.user.photoUrl != null &&
                                      state.user.photoUrl!.isNotEmpty
                                  ? (state.user.photoUrl!.startsWith('http')
                                        ? NetworkImage(state.user.photoUrl!)
                                              as ImageProvider
                                        : FileImage(File(state.user.photoUrl!))
                                              as ImageProvider)
                                  : null,
                              child:
                                  state.user.photoUrl == null ||
                                      state.user.photoUrl!.isEmpty
                                  ? Text(
                                      state.user.name
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.user.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.user.email,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : kTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditDetailsScreen(user: state.user),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.edit_outlined,
                                color: isDarkMode ? Colors.white : kBlueIcon,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return _SettingsTile(
                      icon: Icons.account_circle_outlined,
                      title: AppLocalizations.of(context)!.notLoggedIn,
                    );
                  },
                ),
              ],
            ),

            // --- Section 2: Premium Banner (Prominent Orange) ---
            // This is placed outside the groups to stand out.
            _buildPremiumBanner(context),

            // --- Section 3: Preferences ---
            _SettingsGroup(
              backgroundColor: groupBackground,
              headerTitle: AppLocalizations.of(context)!.preferences,
              children: [
                // Dark Mode Switch
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    final isDark = state.mode == ThemeMode.dark;
                    return SwitchListTile.adaptive(
                      secondary: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.dark_mode_outlined,
                          color: isDarkMode ? Colors.white : kBlueIcon,
                          size: 26,
                        ),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.darkMode,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: primaryTextColor,
                        ),
                      ),
                      value: isDark,
                      activeColor: kAccentOrange,
                      onChanged: (v) => themeCubit.toggleTheme(v),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: kTilePaddingVertical - 4,
                      ),
                      tileColor: Colors.transparent,
                    );
                  },
                ),
                _buildDivider(isDarkMode),
                // Language Picker
                _SettingsTile(
                  icon: Icons.language,
                  iconColor: isDarkMode ? Colors.white : kBlueIcon,
                  title: AppLocalizations.of(context)!.language,
                  trailing: BlocBuilder<LanguageCubit, LanguageState>(
                    builder: (context, state) {
                      String label = 'English';
                      if (state is LanguageLoaded) {
                        if (state.locale.languageCode == 'fr')
                          label = 'Français';
                        if (state.locale.languageCode == 'ar')
                          label = 'العربية';
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: kTextSecondary.withOpacity(0.5),
                          ),
                        ],
                      );
                    },
                  ),
                  onTap: () => _showLanguageDialog(context),
                ),
              ],
            ),

            // --- Section 4: Security ---
            _SettingsGroup(
              backgroundColor: groupBackground,
              headerTitle: AppLocalizations.of(context)!.security,
              children: [
                _SettingsTile(
                  icon: Icons.lock_outline,
                  iconColor: isDarkMode ? Colors.white : kBlueIcon,
                  title: AppLocalizations.of(context)!.changePassword,
                  onTap: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => const ChangePasswordDialog(),
                    );
                    if (result == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.passwordChangedSuccess,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            // --- Section 5: About ---
            _SettingsGroup(
              backgroundColor: groupBackground,
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: isDarkMode ? Colors.white : kBlueIcon,
                  title: AppLocalizations.of(context)!.aboutKhedmni,
                  onTap: () => Navigator.pushNamed(context, RouteNames.about),
                ),
              ],
            ),

            // --- Section 6: Account ---
            _SettingsGroup(
              backgroundColor: groupBackground,
              children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  iconColor: Colors.redAccent,
                  title: AppLocalizations.of(context)!.logout,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.logout),
                        content: Text(
                          AppLocalizations.of(context)!.logoutConfirmation,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              AppLocalizations.of(context)!.logout,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      await context.read<AuthCubit>().logout();
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteNames.welcome,
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // A prominent, bold orange banner for subscription
  Widget _buildPremiumBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        // Bold orange gradient
        gradient: const LinearGradient(
          colors: [kAccentOrange, Color(0xFFFFB340)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kAccentOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // The "AI sparkle" icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.subscribeToPro,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.subscribeToProDesc,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement subscription flow
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.comingSoon),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kAccentOrange,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              AppLocalizations.of(context)!.subscribeAction,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 60, // Aligned with text
      color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    // ... (Language dialog implementation remains the same)
    String current = 'en';
    final langState = context.read<LanguageCubit>().state;
    if (langState is LanguageLoaded) current = langState.locale.languageCode;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) {
        String selected = current;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.language),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'en',
                    groupValue: selected,
                    title: const Text('English'),
                    onChanged: (v) => setState(() => selected = v!),
                  ),
                  RadioListTile<String>(
                    value: 'fr',
                    groupValue: selected,
                    title: const Text('Français'),
                    onChanged: (v) => setState(() => selected = v!),
                  ),
                  RadioListTile<String>(
                    value: 'ar',
                    groupValue: selected,
                    title: const Text('العربية'),
                    onChanged: (v) => setState(() => selected = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            );
          },
        );
      },
    );

    if (choice != null && choice != current && mounted) {
      context.read<LanguageCubit>().changeLanguage(choice);
    }
  }
}

// ==========================================
// HELPER WIDGETS FOR THE NEW DESIGN
// ==========================================

/// A rounded container to group settings tiles together.
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final String? headerTitle;
  final Color backgroundColor;

  const _SettingsGroup({
    required this.children,
    required this.backgroundColor,
    this.headerTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerTitle != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 32.0,
              bottom: 10.0,
              top: 24.0,
            ),
            child: Text(
              headerTitle!.toUpperCase(),
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : kTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(kGroupCornerRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kGroupCornerRadius),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

/// A standard tile representing a single setting option.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor =
        iconColor ?? (isDarkMode ? Colors.white : Colors.black87);
    final textColor = isDarkMode ? Colors.white : kTextPrimary;

    Widget trailingWidget =
        trailing ??
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: isDarkMode ? Colors.white38 : kTextSecondary.withOpacity(0.5),
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          // Increased padding for "bigger fields"
          padding: const EdgeInsets.symmetric(
            vertical: kTilePaddingVertical,
            horizontal: 16.0,
          ),
          child: Row(
            children: [
              Icon(icon, color: effectiveIconColor, size: 26),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15, // Reduced font size
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white54 : kTextSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailingWidget != null) trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}
