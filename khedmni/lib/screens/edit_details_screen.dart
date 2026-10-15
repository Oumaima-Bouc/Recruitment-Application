import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../logic/cubits/auth_cubit.dart';
import 'package:khedmni/l10n/app_localizations.dart';

// --- Constants (Matching Settings Page) ---
const Color kBackgroundColor = Color(0xFFF2F2F7);
const Color kGroupColor = Colors.white;
const Color kAccentOrange = Color(0xFFFF9500);
const Color kTextSecondary = Color(0xFF8E8E93);
const double kGroupCornerRadius = 12.0;

class EditDetailsScreen extends StatefulWidget {
  final dynamic user;
  const EditDetailsScreen({super.key, required this.user});

  @override
  State<EditDetailsScreen> createState() => _EditDetailsScreenState();
}

class _EditDetailsScreenState extends State<EditDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _bioCtrl;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _bioCtrl = TextEditingController(text: widget.user.bio ?? '');
    _pickedImagePath = widget.user.photoUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthCubit>().updateProfile(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          photoUrl: _pickedImagePath,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)));
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(
        type: FileType.image, withData: false);
    if (res != null && res.files.isNotEmpty) {
      setState(() {
        _pickedImagePath = res.files.first.path;
      });
    }
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter email';
    final re = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    if (!re.hasMatch(v)) return 'Invalid email';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenBg = isDarkMode ? Colors.black : kBackgroundColor;
    final groupBg = isDarkMode ? Colors.grey[900]! : kGroupColor;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editDetails,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        backgroundColor: screenBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: kAccentOrange), // Orange back arrow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // --- Section 1: Avatar ---
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: groupBg, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50, // Big Avatar
                        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        backgroundImage: _pickedImagePath != null
                            ? FileImage(File(_pickedImagePath!))
                            : null,
                        child: _pickedImagePath == null
                            ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                            : null,
                      ),
                    ),
                    // Camera Icon Badge
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kAccentOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: screenBg, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            Text(
              "Tap to change photo",
              style: TextStyle(
                color: kTextSecondary, 
                fontSize: 13,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 30),

            // --- Section 2: Form Fields ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: groupBg,
                borderRadius: BorderRadius.circular(kGroupCornerRadius),
                // Subtle shadow for depth
                boxShadow: isDarkMode ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4)
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, AppLocalizations.of(context)!.fullName),
                    _buildTextField(
                      controller: _nameCtrl,
                      hint: "Enter your name",
                      isDarkMode: isDarkMode,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppLocalizations.of(context)!.pleaseEnterFullName
                          : null,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildLabel(context, AppLocalizations.of(context)!.emailAddress),
                    _buildTextField(
                      controller: _emailCtrl,
                      hint: "name@example.com",
                      isDarkMode: isDarkMode,
                      validator: _emailValidator,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildLabel(context, AppLocalizations.of(context)!.bio),
                    _buildTextField(
                      controller: _bioCtrl,
                      hint: "Tell us about yourself...",
                      isDarkMode: isDarkMode,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Section 3: Save Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55, // Bigger button
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentOrange,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for consistent labels
  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  // Helper for "Bigger" styled text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDarkMode,
    String? Function(String?)? validator,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: inputType,
      maxLines: maxLines,
      cursorColor: kAccentOrange, // Orange cursor to match theme
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kTextSecondary.withOpacity(0.7)),
        filled: true,
        // Slightly darker fill to stand out from the white group background
        fillColor: isDarkMode ? Colors.grey[800] : const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Bigger padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // Clean look, no borders
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kAccentOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
      ),
    );
  }
}