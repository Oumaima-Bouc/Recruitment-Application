import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khedmni/logic/cubits/auth_cubit.dart';
import 'package:khedmni/logic/cubits/auth_state.dart';
import '../core/routes/route_names.dart';
import '../core/constants/colors.dart';
import '../l10n/app_localizations.dart';
import '../models/company.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              if (state.userType == 'company') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.companyHome,
                  (route) => false,
                  arguments: Company(
                    id: state.user.id,
                    name: state.user.name,
                    email: state.user.email,
                    industry: 'My Industry', // Placeholder until Company profile edit is implemented
                    website: '',
                    description: state.user.bio ?? 'Welcome to my company profile',
                    contact: state.user.phone ?? '',
                    logoUrl: '',
                  ),
                );
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.home,
                  (route) => false,
                );
              }
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

                    // Welcome Text
                    Center(
                      child: Text(
                        l10n.welcomeBack,
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
                        l10n.signInToContinue,
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

                    // Email Field
                    Text(
                      l10n.emailAddress,
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
                        hintText: l10n.enterYourEmail,
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
                          return l10n.pleaseEnterEmail;
                        }
                        if (!v.contains('@')) {
                          return l10n.pleaseEnterValidEmail;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    Text(
                      l10n.password,
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
                        hintText: l10n.enterYourPassword,
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
                          return l10n.pleaseEnterPassword;
                        }
                        if (v.length < 6) {
                          return l10n.passwordMinLength;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.forgotPassword,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().login(
                                        _emailCtrl.text.trim(),
                                        _passCtrl.text.trim(),
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
                                l10n.signIn,
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
                            l10n.orContinueWith,
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

                    // Social Login Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            icon: 'assets/images/Logo_Google.jpg',
                            label: l10n.google,
                            onTap: () {
                              // TODO: Implement Google login
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SocialButton(
                            icon: 'https://cdn-icons-png.flaticon.com/512/174/174857.png',
                            label: l10n.linkedin,
                            isNetwork: true,
                            onTap: () {
                              // TODO: Implement LinkedIn login
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${l10n.dontHaveAccount} ',
                            style: GoogleFonts.lato(
                              fontSize: 15,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.signup,
                            ),
                            child: Text(
                              l10n.signUp,
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
