import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import '../data/repositories/auth_repository.dart';
import '../logic/cubits/auth_cubit.dart';
import '../logic/cubits/auth_state.dart';
import '../core/routes/route_names.dart';
import '../core/utils/deep_links.dart';
import 'package:khedmni/l10n/app_localizations.dart';

class EmailVerificationInterstitialScreen extends StatefulWidget {
  const EmailVerificationInterstitialScreen({super.key});

  @override
  State<EmailVerificationInterstitialScreen> createState() => _EmailVerificationInterstitialScreenState();
}

class _EmailVerificationInterstitialScreenState extends State<EmailVerificationInterstitialScreen> {
  bool _isSending = false;
  bool _checking = false;
  bool _autoSent = false; // track whether we've auto-sent the code once
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  StreamSubscription? _linkSub; // listens for incoming deep links
  String? _initialCode;
  
  // Design constants
  static const Color kPrimaryOrange = Color(0xFFF77F00);
  static const Color kPrimaryDarkBlue = Color(0xFF1D3557);

  @override
  void initState() {
    super.initState();
    // Auto-send the verification code when the screen first appears for pending verification states
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      // Auto-send when entering this screen for pending verification states
      if ((authState is AuthPendingVerification || authState is AuthAuthenticated) && !_autoSent) {
        _sendCode();
        setState(() => _autoSent = true);
      }

      // Check for an initial code passed via route arguments (deep link -> main pushes route with args)
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['code'] != null) {
        _initialCode = args['code'] as String;
        if (_initialCode != null && _initialCode!.length >= 4) {
          _fillCodeAndVerify(_initialCode!);
        }
      }

      // Also listen for in-app incoming links while this screen is visible
      DeepLinks.init();
      _linkSub = DeepLinks.uriLinkStream.listen((uri) {
        final code = uri?.queryParameters['code'];
        if (code != null && code.length >= 4) {
          _fillCodeAndVerify(code);
        }
      }, onError: (_) {});
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() => _isSending = true);
    final authState = context.read<AuthCubit>().state;
    String? email;
    if (authState is AuthAuthenticated) {
      email = authState.user.email;
    } else if (authState is AuthPendingVerification) {
      email = authState.email;
    }

    if (email != null) {
      try {
        await AuthRepository().sendVerificationEmail(email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.verificationSentTo + ' $email'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            )
          );
        }
      } catch (e) {
        // Show a clear error message to the user (rate-limit or service error)
        final msg = e.toString().replaceAll('Exception: ', '');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            )
          );
        }
      }
    }

    if (mounted) setState(() => _isSending = false);
  }

  // Fill controllers from a 4+ digit code and try to verify automatically
  void _fillCodeAndVerify(String code) {
    if (code.length < 4) return;
    final digits = code.trim().substring(0,4).split('');
    for (var i = 0; i < 4; i++) {
      _controllers[i].text = digits[i];
    }
    // Hide keyboard and verify
    FocusScope.of(context).unfocus();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.codeAutofilled), behavior: SnackBarBehavior.floating)
    );
    _verifyCode();
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((e) => e.text).join();
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enter4DigitCode),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        )
      );
      return;
    }
    setState(() => _checking = true);
    final authState = context.read<AuthCubit>().state;

    if (authState is AuthPendingVerification) {
      // Check code locally (or we could call repo)
      if (authState.code == code) {
        // Success! Now finalize the signup in the database
        await context.read<AuthCubit>().finalizeSignup(
          authState.name,
          authState.email,
          authState.password,
          authState.userType,
        );

        // After finalizeSignup, AuthCubit emits AuthAuthenticated. We'll navigate
        // directly to the Create Profile screen and clear previous routes so the
        // user can't go back to signup screens.
        final newState = context.read<AuthCubit>().state;
        if (newState is AuthAuthenticated) {
          final routeName = newState.user.userType == 'company' ? RouteNames.createCompanyProfile : RouteNames.createProfile;
          if (mounted) Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false, arguments: {
            'name': newState.user.name,
            'email': newState.user.email,
          });
          return;
        } else {
          if (mounted) Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invalidCode),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            )
          );
        }
      }
    } else if (authState is AuthAuthenticated) {
      final ok = await AuthRepository().verifyEmailToken(authState.user.id, code);
      if (ok) {
        if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.emailVerifiedSuccess),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              )
            );
        }
        final user = await AuthRepository().getCurrentUserById(authState.user.id);
        if (user != null && mounted) {
          context.read<AuthCubit>().emitAuthUpdateAfterVerification(user);
        }
        // For an already-authenticated user, just close the interstitial
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invalidCode),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            )
          );
        }
      }
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.verificationTitle, style: GoogleFonts.lato(color: isDark ? Colors.white : kPrimaryDarkBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : kPrimaryDarkBlue, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               // --- Fun Progress Stepper ---
               _buildProgressStepper(loc),
               
               const SizedBox(height: 48),

               // --- Trusted Visual ---
               Stack(
                 alignment: Alignment.center,
                 children: [
                   Container(
                     width: 120,
                     height: 120,
                     decoration: BoxDecoration(
                       color: kPrimaryOrange.withOpacity(0.05),
                       shape: BoxShape.circle,
                     ),
                   ),
                   Container(
                     width: 100,
                     height: 100,
                     decoration: BoxDecoration(
                       color: kPrimaryOrange.withOpacity(0.1),
                       shape: BoxShape.circle,
                     ),
                   ),
                   const Icon(
                     Icons.mark_email_read_rounded,
                     size: 56,
                     color: kPrimaryOrange,
                   ),
                   Positioned(
                     bottom: 0,
                     right: 0,
                     child: Container(
                       padding: const EdgeInsets.all(4),
                       decoration: const BoxDecoration(
                         color: Colors.green,
                         shape: BoxShape.circle,
                       ),
                       child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                     ),
                   )
                 ],
               ),
               const SizedBox(height: 32),

               // --- Text ---
               Text(
                 loc.checkYourEmail,
                 style: GoogleFonts.lato(
                   fontSize: 26,
                   fontWeight: FontWeight.w800,
                   color: isDark ? Colors.white : kPrimaryDarkBlue,
                 ),
               ),
               const SizedBox(height: 12),
               BlocBuilder<AuthCubit, AuthState>(
                 builder: (context, state) {
                   String email = "...";
                   if (state is AuthAuthenticated) {
                     email = state.user.email;
                   } else if (state is AuthPendingVerification) {
                     email = state.email;
                   }
                   return RichText(
                     textAlign: TextAlign.center,
                     text: TextSpan(
                       style: GoogleFonts.lato(fontSize: 15, color: isDark ? Colors.white70 : Colors.grey[600], height: 1.5),
                       children: [
                         TextSpan(text: loc.verificationSentTo + '\n'),
                         TextSpan(
                           text: email,
                           style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : kPrimaryDarkBlue),
                         ),
                       ],
                     ),
                   );
                 },
               ),

               const SizedBox(height: 40),

               // --- Fun Digit Inputs ---
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: List.generate(4, (index) => _buildDigitInput(index)),
               ),

               // --- DEV: show token in debug builds for easy testing ---
               if (kDebugMode) ...[
                 const SizedBox(height: 16),
                 BlocBuilder<AuthCubit, AuthState>(
                   builder: (context, state) {
                     String debugToken = '';
                     if (state is AuthPendingVerification) {
                       debugToken = state.code;
                     } else if (state is AuthAuthenticated) {
                       debugToken = state.user.emailVerificationToken ?? '';
                     }

                     if (debugToken.isEmpty) return const SizedBox.shrink();

                     return GestureDetector(
                       onTap: () {
                         Clipboard.setData(ClipboardData(text: debugToken));
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text(AppLocalizations.of(context)!.devCodeCopied),
                             behavior: SnackBarBehavior.floating,
                           ),
                         );
                       },
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                         decoration: BoxDecoration(
                           color: Colors.orange.withOpacity(0.06),
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.orange.withOpacity(0.14)),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             const Icon(Icons.info_outline, size: 18, color: Colors.orange),
                             const SizedBox(width: 8),
                             Text('DEV CODE: $debugToken', style: GoogleFonts.lato(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                             const SizedBox(width: 8),
                             const Icon(Icons.copy, size: 16, color: Colors.grey),
                           ],
                         ),
                       ),
                     );
                   },
                 ),
               ],

               const SizedBox(height: 48),

               // --- Actions ---
               SizedBox(
                 width: double.infinity,
                 height: 58,
                 child: ElevatedButton(
                   onPressed: _checking ? null : _verifyCode,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: kPrimaryOrange,
                     foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(18),
                     ),
                     elevation: 4,
                     shadowColor: kPrimaryOrange.withOpacity(0.5),
                   ),
                   child: _checking
                       ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                       : Text(
                           loc.verifyAccount,
                           style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                         ),
                 ),
               ),
               
               const SizedBox(height: 32),
               
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text(loc.didntReceiveCode, style: GoogleFonts.lato(color: isDark ? Colors.white60 : Colors.grey[600])),
                   TextButton(
                     onPressed: _isSending ? null : _sendCode,
                     child: _isSending 
                       ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) 
                       : Text(loc.resendCode, style: GoogleFonts.lato(color: kPrimaryOrange, fontWeight: FontWeight.bold)),
                   ),
                 ],
               ),
               
               const SizedBox(height: 20),
               // Security trust badge
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                   const SizedBox(width: 4),
                   Text(
                     AppLocalizations.of(context)!.secureVerification,
                     style: GoogleFonts.lato(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey),
                   ),
                 ],
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStepper(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepItem(1, loc.stepSignUp, true, true),
          _buildStepDivider(true),
          _buildStepItem(2, loc.stepVerify, true, false), // Current
          _buildStepDivider(false),
          _buildStepItem(3, loc.stepProfile, false, false),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, bool isActive, bool isDone) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDone ? Colors.green : (isActive ? kPrimaryOrange : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.white)),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? Colors.green : (isActive ? kPrimaryOrange : (Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey[300]!)),
              width: 2,
            ),
            boxShadow: isActive ? [BoxShadow(color: kPrimaryOrange.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Center(
            child: isDone 
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Text(
                  '$step',
                  style: GoogleFonts.lato(
                    color: isActive ? Colors.white : Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : kPrimaryDarkBlue) : Colors.grey[400],
          ),
        )
      ],
    );
  }

  Widget _buildStepDivider(bool isActive) {
    return Container(
      width: 40,
      height: 3,
      margin: const EdgeInsets.only(bottom: 24, left: 4, right: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : (Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey[200]),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDigitInput(int index) {
    return SizedBox(
      width: 60,
      height: 70,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        cursorColor: kPrimaryOrange,
        style: GoogleFonts.sourceCodePro(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : kPrimaryDarkBlue),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9FAFB),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kPrimaryOrange, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (_controllers.every((e) => e.text.isNotEmpty)) {
            // Auto-verify: if all digits entered, trigger verification automatically
            FocusScope.of(context).unfocus();
            _verifyCode();
          }
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
}
