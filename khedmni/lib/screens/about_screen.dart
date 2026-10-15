import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khedmni/l10n/app_localizations.dart';

// --- Constants ---
const Color kBgLight = Color(0xFFF2F2F7);
const Color kBgDark = Color(0xFF000000);
const Color kCardLight = Colors.white;
const Color kCardDark = Color(0xFF1C1C1E);
const Color kAccentOrange = Color(0xFFFF9500);
// New Dark Blue for the Logo
const Color kDarkBlueLogo = Color.fromARGB(255, 9, 33, 58);

// Gradient for Instagram (Purple -> Pink -> Orange)
const Gradient kInstaGradient = LinearGradient(
  colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCAF45)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Gradient for Facebook (Blue tones)
const Gradient kFbGradient = LinearGradient(
  colors: [Color(0xFF1877F2), Color(0xFF3b5998)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Gradient for Website (Khedmni Orange)
const Gradient kWebGradient = LinearGradient(
  colors: [kAccentOrange, Color(0xFFFFB340)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// New Gradient for Email (Professional Blue-Grey)
const Gradient kEmailGradient = LinearGradient(
  colors: [Color(0xFF607D8B), Color(0xFF37474F)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _copyAndNotify(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.copiedToClipboard),
          ],
        ),
        backgroundColor: kAccentOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bg = isDarkMode ? kBgDark : kBgLight;
    final cardBg = isDarkMode ? kCardDark : kCardLight;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final mutedColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.aboutKhedmni,
          style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
        ),
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- 1. Hero Section (Logo & Version) ---
            Center(
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    // Placeholder for Logo
                    child: Center(
                      child: Text(
                        "K",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          // Changed color to Dark Blue as requested
                          color: kDarkBlueLogo, 
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Khedmni",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.aboutVersion("1.0.0"),
                    style: TextStyle(
                      fontSize: 14,
                      color: mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- 2. Mission Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Removed the Sparkle icon here
                    Text(
                      AppLocalizations.of(context)!.ourMission.toUpperCase(),
                      style: TextStyle(
                        color: kAccentOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.missionSubtitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.whoWeAreDescription,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            // --- 3. Socials & Contact Section ---
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 24.0, bottom: 8.0),
              child: Text(
                AppLocalizations.of(context)!.contactUs.toUpperCase(),
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Instagram (Using the gradient border for modern look)
                  _SocialTile(
                    title: AppLocalizations.of(context)!.instagram,
                    subtitle: "@khedmni_official",
                    gradient: kInstaGradient,
                    icon: Icons.camera_alt_outlined, 
                    onTap: () => _copyAndNotify(context, "@khedmni_official"),
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  _buildDivider(isDarkMode),
                  // Facebook
                  _SocialTile(
                    title: AppLocalizations.of(context)!.facebook,
                    subtitle: "facebook.com/khedmni",
                    gradient: kFbGradient,
                    icon: Icons.facebook,
                    onTap: () => _copyAndNotify(context, "facebook.com/khedmni"),
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  _buildDivider(isDarkMode),
                  // Email (Added new entry)
                  _SocialTile(
                    title: AppLocalizations.of(context)!.emailLabel,
                    subtitle: "contact@khedmni.com",
                    gradient: kEmailGradient,
                    icon: Icons.email_outlined,
                    onTap: () => _copyAndNotify(context, "contact@khedmni.com"),
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  _buildDivider(isDarkMode),
                  // Website
                  _SocialTile(
                    title: AppLocalizations.of(context)!.website,
                    subtitle: "www.khedmni.com",
                    gradient: kWebGradient,
                    icon: Icons.language,
                    onTap: () => _copyAndNotify(context, "https://khedmni.com"),
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            // --- 4. Footer (Updated Text) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.madeWith + " ", 
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
                Text(
                  AppLocalizations.of(context)!.studentCredits, 
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 70,
      color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
    );
  }
}

// --- Custom Widget for the Unique Border Tiles ---
class _SocialTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Gradient gradient;
  final IconData icon;
  final VoidCallback onTap;
  final Color textColor;
  final Color? mutedColor;

  const _SocialTile({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.onTap,
    required this.textColor,
    this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      // The Custom Gradient Border Avatar
      leading: Container(
        padding: const EdgeInsets.all(2.5), // Thickness of the gradient border
        decoration: BoxDecoration(
          gradient: gradient,
          shape: BoxShape.circle,
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // Background inside border
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: textColor),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textColor,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Text(
          subtitle,
          style: TextStyle(color: mutedColor, fontSize: 13),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.copy, size: 16, color: mutedColor),
      ),
    );
  }
}