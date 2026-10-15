import 'package:flutter/material.dart';
import 'package:khedmni/l10n/app_localizations.dart';
import 'package:khedmni/screens/job_feed_screen.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _university = TextEditingController();
  final _major = TextEditingController();
  final _workExp = TextEditingController();
  final _skills = TextEditingController();

  String? _educationLevel;
  String? _uploadedFileName;

  // sample education options
  final List<String> _educationOptions = [
    'High School',
    'Diploma',
    'Bachelor',
    'Master',
    'PhD'
  ]; // These could also be localized if needed, but keeping for now as they are often standard.

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _university.dispose();
    _major.dispose();
    _workExp.dispose();
    _skills.dispose();
    super.dispose();
  }

  void _chooseFile() {
    // Placeholder: simulate a picked file name
    setState(() {
      _uploadedFileName = 'resume_example.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.cvUploadedSuccess)),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'fullName': _fullName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'education': _educationLevel,
        'university': _university.text.trim(),
        'major': _major.text.trim(),
        'workExp': _workExp.text.trim(),
        'skills': _skills.text.trim(),
        'cv': _uploadedFileName,
      };

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.profileCreated),
          content: SingleChildScrollView(
            child: Text(data.entries.map((e) => '${e.key}: ${e.value}').join('\n')),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.ok)),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFixErrors)),
      );
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.orange.shade700),
      ),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Color primaryOrange = Color(0xFFF77F00);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(AppLocalizations.of(context)!.createAccount,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(AppLocalizations.of(context)!.joinNow, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.findNextOpportunity, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black54)),
                  const SizedBox(height: 18),

                  // Full Name
                  _label(AppLocalizations.of(context)!.fullName),
                  TextFormField(
                    controller: _fullName,
                    decoration: _fieldDecoration(AppLocalizations.of(context)!.enterFullName),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.pleaseEnterFullName;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Email
                  _label(AppLocalizations.of(context)!.emailAddress),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDecoration(AppLocalizations.of(context)!.enterEmailAddress),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.pleaseEnterEmail;
                      if (!v.contains('@')) return AppLocalizations.of(context)!.invalidEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone number
                  _label(AppLocalizations.of(context)!.phoneNumber),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: _fieldDecoration(AppLocalizations.of(context)!.enterPhoneNumber),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.pleaseEnterPhoneNumber;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Education Level (dropdown)
                  _label(AppLocalizations.of(context)!.educationLevel),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: _educationLevel,
                      value: _educationLevel,
                      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                      hint: Text(AppLocalizations.of(context)!.selectEducationLevel, style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500)),
                      items: _educationOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _educationLevel = v),
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppLocalizations.of(context)!.pleaseSelectEducationLevel;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // University
                  _label(AppLocalizations.of(context)!.university),
                  TextFormField(
                    controller: _university,
                    decoration: _fieldDecoration(AppLocalizations.of(context)!.enterUniversity),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.pleaseEnterUniversity;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Major
                  _label(AppLocalizations.of(context)!.major),
                  TextFormField(
                    controller: _major,
                    decoration: _fieldDecoration(AppLocalizations.of(context)!.enterMajor),
                  ),
                  const SizedBox(height: 12),

                  // Work Experience
                  _label(AppLocalizations.of(context)!.workExperience),
                  TextFormField(
                    controller: _workExp,
                    decoration: _fieldDecoration(AppLocalizations.of(context)!.describeWorkExperience),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  // Skills
                  _label(AppLocalizations.of(context)!.skills),
                  TextFormField(
                    controller: _skills,
                    decoration: _fieldDecoration(AppLocalizations.of(context)!.listSkills),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Upload CV - CLICKABLE BOX (no button)
                  _label(AppLocalizations.of(context)!.uploadCv),
                  GestureDetector(
                    onTap: _chooseFile,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? Colors.white12 : Colors.grey.shade100,
                              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                            ),
                            child: Icon(Icons.upload_file, size: 36, color: isDark ? Colors.white54 : Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Orange "Upload a file" text if no file, otherwise file name
                                if (_uploadedFileName == null) ...[
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
                                      children: [
                                        TextSpan(
                                          text: AppLocalizations.of(context)!.uploadFile,
                                          style: TextStyle(color: primaryOrange, fontWeight: FontWeight.w600),
                                        ),
                                        TextSpan(text: AppLocalizations.of(context)!.dragAndDrop, style: TextStyle(color: isDark ? Colors.white70 : Colors.black)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(AppLocalizations.of(context)!.supportedFormats, style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade600, fontSize: 12)),
                                ] else ...[
                                  Text(_uploadedFileName!, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                                  const SizedBox(height: 6),
                                  Text(AppLocalizations.of(context)!.tapToChangeFile, style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade600, fontSize: 12)),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Create Profile button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const JobFeedScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        AppLocalizations.of(context)!.createProfile,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

