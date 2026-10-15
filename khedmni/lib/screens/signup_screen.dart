import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../core/routes/route_names.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/auth_state.dart';
import 'package:khedmni/l10n/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String _userType = 'student'; // Default

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _userType = args;
    }
  }

  @override
  void dispose() {
    _fullnameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  OutlineInputBorder _fieldBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color ?? const Color(0xFFE5E7EB),
        width: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                print('DEBUG: Authenticated with userType: ${state.userType}'); // Debug print

                // If email is not verified, show verification interstitial
                if (!state.user.isEmailVerified) {
                  Navigator.pushNamed(
                    context,
                    RouteNames.emailVerificationInterstitial,
                  );
                  return;
                }

                if (state.userType == 'company') {
                  // Navigate to company profile creation
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.createCompanyProfile,
                    (route) => false,
                    arguments: {
                      'name': _fullnameCtrl.text,
                      'email': state.email,
                    },
                  );
                } else {
                  // Navigate to student profile creation
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.createProfile,
                    (route) => false,
                    arguments: {
                      'name': _fullnameCtrl.text,
                      'email': state.email,
                    },
                  );
                }
              } else if (state is AuthPendingVerification) {
                 // show a confirmation then navigate to verification screen
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('${AppLocalizations.of(context)!.verificationSentTo} ${state.email}'),
                     backgroundColor: Colors.green,
                     behavior: SnackBarBehavior.floating,
                   ),
                 );
                 Navigator.pushNamed(
                  context,
                  RouteNames.emailVerificationInterstitial,
                );
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Back arrow
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              RouteNames.welcome,
                              (route) => false,
                            );
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Logo
                      Center(
                        child: Image.asset(
                          isDark 
                              ? 'assets/images/logo-khedmni-dark.png' 
                              : 'assets/images/Logo_Khedmni.png',
                          width: 200,
                          height: 53,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Title - Dynamic based on user type
                      Center(
                        child: Text(
                          _userType == 'company'
                              ? AppLocalizations.of(context)!.createCompanyAccount
                              : AppLocalizations.of(context)!.signupStudentTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.darkBlue,
                            height: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          _userType == 'company'
                              ? AppLocalizations.of(context)!.joinAsCompany
                              : AppLocalizations.of(context)!.signupStudentSubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Full name
                      Text(
                        _userType == 'company' ? AppLocalizations.of(context)!.companyName : AppLocalizations.of(context)!.fullName,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _fullnameCtrl,
                        keyboardType: TextInputType.name,
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: _userType == 'company' 
                              ? AppLocalizations.of(context)!.enterCompanyName
                              : AppLocalizations.of(context)!.enterYourFullName,
                          hintStyle: GoogleFonts.lato(
                            color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            _userType == 'company' 
                                ? Icons.business_outlined
                                : Icons.person_outline_rounded,
                            color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: _fieldBorder(),
                          focusedBorder: _fieldBorder(
                            color: AppColors.primaryOrange,
                          ),
                          errorBorder: _fieldBorder(
                            color: AppColors.error,
                          ),
                          focusedErrorBorder: _fieldBorder(
                            color: AppColors.error,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return _userType == 'company'
                                ? AppLocalizations.of(context)!.pleaseEnterCompanyName
                                : AppLocalizations.of(context)!.pleaseEnterFullName;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Email Field
                      Text(
                        AppLocalizations.of(context)!.emailAddress,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.enterYourEmail,
                          hintStyle: GoogleFonts.lato(
                            color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: _fieldBorder(),
                          focusedBorder: _fieldBorder(
                            color: AppColors.primaryOrange,
                          ),
                          errorBorder: _fieldBorder(
                            color: AppColors.error,
                          ),
                          focusedErrorBorder: _fieldBorder(
                            color: AppColors.error,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return AppLocalizations.of(context)!.pleaseEnterEmail;
                          }
                          if (!v.contains('@')) {
                            return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      Text(
                        AppLocalizations.of(context)!.password,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.createPassword,
                          hintStyle: GoogleFonts.lato(
                            color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                            ),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: _fieldBorder(),
                          focusedBorder: _fieldBorder(
                            color: AppColors.primaryOrange,
                          ),
                          errorBorder: _fieldBorder(
                            color: AppColors.error,
                          ),
                          focusedErrorBorder: _fieldBorder(
                            color: AppColors.error,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppLocalizations.of(context)!.pleaseEnterPassword2; // Reusing or create a new one
                          }
                          if (v.length < 6) {
                            return AppLocalizations.of(context)!.passwordMinLength;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    print('DEBUG: Signing up with userType: $_userType'); // Debug print
                                    context.read<AuthCubit>().signup(
                                          _fullnameCtrl.text,
                                          _emailCtrl.text,
                                          _passCtrl.text,
                                          userType: _userType,
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            disabledBackgroundColor:
                                AppColors.primaryOrange.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: AppColors.primaryOrange.withOpacity(0.3),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.createAccountAction,
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppLocalizations.of(context)!.orContinueWith,
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              icon: 'assets/images/Logo_Google.jpg',
                              label: AppLocalizations.of(context)!.google,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(
                              icon: 'https://cdn-icons-png.flaticon.com/512/174/174857.png',
                              label: AppLocalizations.of(context)!.linkedin,
                              isNetwork: true,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Login Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.alreadyHaveAccount} ',
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                color: isDark ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                RouteNames.login,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.signIn,
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isNetwork;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isNetwork)
              Image.network(
                icon,
                width: 20,
                height: 20,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.link,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
              )
            else
              Image.asset(
                icon,
                width: 20,
                height: 20,
              ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}