import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubits/auth_cubit.dart';
import '../core/routes/route_names.dart';
import '../core/constants/colors.dart';
import 'package:khedmni/l10n/app_localizations.dart'; // Add import

// ==========================
// 🎨 COLOR PALETTE (From ProfileScreen)
// ==========================
const Color kPrimaryDarkBlue = Color(0xFF1D3557);
const Color kTagColor = Color(0xFFBCC3CD);
const Color kTagTextColor = Color(0xFF1D3557);
const Color kTextGray = Color(0xFF5F6368);
const Color kBorderGray = Color(0xFFBCC3CD);

class CreateProfileScreen extends StatefulWidget {
  final String name;
  final String email;

  const CreateProfileScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final _titleController = TextEditingController();
  final _skillController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  final List<String> _skills = [];
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _skillController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (res != null && res.files.single.path != null) {
      setState(() {
        _profileImage = File(res.files.single.path!);
      });
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _handleCompleteProfile() {
    if (_formKey.currentState!.validate()) {
      // 1. Gather Data
      final name = _nameController.text.trim();
      final title = _titleController.text.trim();
      final bio = _bioController.text.trim();
      final skills = _skills.join(','); // Store as CSV

      final phone = _phoneController.text.trim();
      final location = _locationController.text.trim();

      // 2. Update Profile via Cubit
      context.read<AuthCubit>().updateProfile(
            name: name,
            title: title,
            bio: bio,
            skills: skills,
            phone: phone,
            location: location,
            photoUrl: _profileImage?.path,
          );

      // 3. Navigate to MainLayout (Home)
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.home,
        (route) => false,
      );
    }
  }

  OutlineInputBorder _fieldBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color ?? kBorderGray.withOpacity(0.5),
        width: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Match ProfileScreen bg
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kPrimaryDarkBlue, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.createProfile,
          style: GoogleFonts.lato(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.completeProfileSubtitle,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: kTextGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Picture Upload
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120, // Slightly bigger
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: kPrimaryDarkBlue.withOpacity(0.2),
                              width: 2,
                            ),
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: AssetImage('assets/images/leena.jpg'), // Default placeholder if available, or use icon
                                    fit: BoxFit.cover,
                                    opacity: 0.5,
                                  ),
                          ),
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 60,
                                  color: kTagColor,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryDarkBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Full Name
                Text(
                  AppLocalizations.of(context)!.fullName,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterYourFullName,
                    hintStyle: GoogleFonts.lato(
                      color: kTextGray,
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: _fieldBorder(),
                    focusedBorder: _fieldBorder(color: kPrimaryDarkBlue),
                    errorBorder: _fieldBorder(color: AppColors.error),
                    focusedErrorBorder: _fieldBorder(color: AppColors.error),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterFullName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Professional Title
                Text(
                  AppLocalizations.of(context)!.professionalTitle,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.professionalTitleHint,
                    hintStyle: GoogleFonts.lato(
                      color: kTextGray,
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: _fieldBorder(),
                    focusedBorder: _fieldBorder(color: kPrimaryDarkBlue),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterTitle;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Contact Number
                Text(
                  AppLocalizations.of(context)!.contactNumber,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.contactNumberHint,
                    hintStyle: GoogleFonts.lato(
                      color: kTextGray,
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: _fieldBorder(),
                    focusedBorder: _fieldBorder(color: kPrimaryDarkBlue),
                  ),
                ),
                const SizedBox(height: 24),

                // Location
                Text(
                  AppLocalizations.of(context)!.locationLabel,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationController,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.locationHint,
                    hintStyle: GoogleFonts.lato(
                      color: kTextGray,
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: _fieldBorder(),
                    focusedBorder: _fieldBorder(color: kPrimaryDarkBlue),
                  ),
                ),
                const SizedBox(height: 24),

                // Skills
                Text(
                  AppLocalizations.of(context)!.skills,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _skillController,
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.skillsHint,
                          hintStyle: GoogleFonts.lato(
                            color: kTextGray,
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: _fieldBorder(),
                          focusedBorder:
                              _fieldBorder(color: kPrimaryDarkBlue),
                        ),
                        onFieldSubmitted: (_) => _addSkill(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _addSkill,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: kPrimaryDarkBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_skills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: kTagColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              skill,
                              style: const TextStyle(
                                color: kTagTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _removeSkill(skill),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: kTagTextColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),

                // Bio
                Text(
                  AppLocalizations.of(context)!.bio,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.bioHint,
                    hintStyle: GoogleFonts.lato(
                      color: kTextGray,
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: _fieldBorder(),
                    focusedBorder: _fieldBorder(color: kPrimaryDarkBlue),
                  ),
                ),
                const SizedBox(height: 40),

                // Complete Profile Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _handleCompleteProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryDarkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.completeProfile,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
