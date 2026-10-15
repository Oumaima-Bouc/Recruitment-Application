import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubits/auth_cubit.dart';
import 'package:khedmni/l10n/app_localizations.dart';

// --- Constants (Matching your Theme) ---
const Color kAccentOrange = Color(0xFFFF9500);
const Color kTextSecondary = Color(0xFF8E8E93);
const double kRadius = 12.0;

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // UX State
  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  double _strength = 0; // 0 to 1

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // Simple password strength logic
  void _updateStrength(String val) {
    double score = 0;
    if (val.length >= 6) score += 0.2;
    if (val.length >= 10) score += 0.2;
    if (val.contains(RegExp(r'[0-9]'))) score += 0.2;
    if (val.contains(RegExp(r'[A-Z]'))) score += 0.2;
    if (val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 0.2;
    
    setState(() {
      _strength = score;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Close keyboard
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);
    final success = await context.read<AuthCubit>().changePassword(
        _currentCtrl.text.trim(), 
        _newCtrl.text.trim()
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.passwordChangeFailed))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDarkMode ? Colors.grey[900]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: dialogBg,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.changePassword,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Fields ---
                _buildPasswordField(
                  controller: _currentCtrl,
                  label: AppLocalizations.of(context)!.enterCurrentPassword,
                  obscure: _obscureCurrent,
                  onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  isDarkMode: isDarkMode,
                  validator: (v) => (v == null || v.isEmpty) 
                      ? AppLocalizations.of(context)!.enterCurrentPassword 
                      : null,
                ),
                const SizedBox(height: 16),

                _buildPasswordField(
                  controller: _newCtrl,
                  label: AppLocalizations.of(context)!.enterNewPassword,
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  isDarkMode: isDarkMode,
                  onChanged: _updateStrength,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppLocalizations.of(context)!.enterNewPassword;
                    if (v.length < 6) return AppLocalizations.of(context)!.passwordMinLength;
                    return null;
                  },
                ),
                
                // --- Strength Indicator ---
                if (_newCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _strength,
                      backgroundColor: Colors.grey[300],
                      color: _strength < 0.4 ? Colors.red : (_strength < 0.8 ? Colors.orange : Colors.green),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _strength < 0.4 ? AppLocalizations.of(context)!.weak : (_strength < 0.8 ? AppLocalizations.of(context)!.medium : AppLocalizations.of(context)!.strong),
                      style: TextStyle(
                        fontSize: 12,
                        color: _strength < 0.4 ? Colors.red : (_strength < 0.8 ? Colors.orange : Colors.green),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                _buildPasswordField(
                  controller: _confirmCtrl,
                  label: AppLocalizations.of(context)!.confirmPassword,
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  isDarkMode: isDarkMode,
                  validator: (v) => (v != _newCtrl.text) 
                      ? AppLocalizations.of(context)!.passwordsDoNotMatch 
                      : null,
                ),

                const SizedBox(height: 24),

                // --- Actions ---
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: const TextStyle(color: kTextSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccentOrange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: _loading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                            : Text(
                                AppLocalizations.of(context)!.save,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper for consistent password fields ---
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDarkMode,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      cursorColor: kAccentOrange,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kTextSecondary),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : const Color(0xFFF2F2F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius),
          borderSide: const BorderSide(color: kAccentOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: kTextSecondary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}