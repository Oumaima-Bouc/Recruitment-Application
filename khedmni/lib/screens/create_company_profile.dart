import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../core/routes/route_names.dart';
import '../models/company.dart';
import '../data/dao/company_dao.dart';
import 'package:khedmni/l10n/app_localizations.dart';

// Color constants matching the app theme
const Color kPrimaryDarkBlue = Color(0xFF1D3557);
const Color kPrimaryOrange = Color(0xFFF77F00);
const Color kTagColor = Color(0xFFE8EEF2);
const Color kTagTextColor = Color(0xFF5A6C7D);
const Color kTextGray = Color(0xFF6B7280);
const Color kBorderGray = Color(0xFFD1D5DB);

class CreateCompanyProfileScreen extends StatefulWidget {
  final String name;
  final String email;

  const CreateCompanyProfileScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<CreateCompanyProfileScreen> createState() =>
      _CreateCompanyProfileScreenState();
}

class _CreateCompanyProfileScreenState
    extends State<CreateCompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();

  final CompanyDao _companyDao = CompanyDao();
  File? _logoImage;
  final List<File> _verificationDocs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _companyNameController.text = widget.name;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _logoImage = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.errorPickingImage(e.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _pickVerificationDocs() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _verificationDocs.add(File(file.path!));
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.documentsAdded(
                result.files.length,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.errorPickingDocuments(e.toString()),
          ),
        ),
      );
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _verificationDocs.removeAt(index);
    });
  }

  void _skipVerification() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.skipVerificationTitle),
          content: Text(AppLocalizations.of(context)!.skipVerificationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _completeProfile();
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryOrange),
              child: Text(AppLocalizations.of(context)!.skipForNow),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _completeProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create company object with verification docs
        final company = Company(
          id: 'company_${DateTime.now().millisecondsSinceEpoch}',
          name: _companyNameController.text,
          email: widget.email,
          industry: _industryController.text,
          website: _websiteController.text,
          description: _descriptionController.text,
          contact: _contactController.text,
          logoUrl: _logoImage?.path ?? '',
          isVerified: false,
          verificationDocs: _verificationDocs.map((doc) => doc.path).toList(),
        );

        // Save to database
        await _companyDao.insertCompany(company);
        print('✅ Company saved to database: ${company.id}');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _verificationDocs.isNotEmpty
                    ? AppLocalizations.of(
                        context,
                      )!.profileCreatedVerificationPending
                    : AppLocalizations.of(context)!.profileCreatedSuccessfully,
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Navigate to CompanyHomeScreen
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.companyHome,
            (route) => false,
            arguments: company,
          );
        }
      } catch (e) {
        print('❌ Error saving company: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.errorCreatingProfile(e.toString()),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryDarkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.createCompanyProfileTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Upload Section
              Center(
                child: GestureDetector(
                  onTap: _pickLogo,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimaryDarkBlue, width: 3),
                      image: _logoImage != null
                          ? DecorationImage(
                              image: FileImage(_logoImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _logoImage == null
                        ? const Icon(Icons.business, size: 50, color: kTagColor)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _pickLogo,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: Text(AppLocalizations.of(context)!.uploadLogo),
                  style: TextButton.styleFrom(
                    foregroundColor: kPrimaryDarkBlue,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Company Name
              Text(
                AppLocalizations.of(context)!.companyName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryDarkBlue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterCompanyName,
                  hintStyle: const TextStyle(color: kTextGray),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: kPrimaryDarkBlue,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterCompanyName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Industry
              Text(
                AppLocalizations.of(context)!.industry,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryDarkBlue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _industryController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.industryHint,
                  hintStyle: const TextStyle(color: kTextGray),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: kPrimaryDarkBlue,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterIndustry;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Website
              Text(
                AppLocalizations.of(context)!.website,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryDarkBlue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.websiteHint,
                  hintStyle: const TextStyle(color: kTextGray),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: kPrimaryDarkBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Contact
              Text(
                AppLocalizations.of(context)!.contactNumber,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryDarkBlue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.contactNumberHint,
                  hintStyle: const TextStyle(color: kTextGray),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: kPrimaryDarkBlue,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(
                      context,
                    )!.pleaseEnterContactNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Location
              Text(
                AppLocalizations.of(context)!.locationLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryDarkBlue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.locationHint,
                  hintStyle: const TextStyle(color: kTextGray),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: kPrimaryDarkBlue,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterLocation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                AppLocalizations.of(context)!.companyDescription,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryDarkBlue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  )!.companyDescriptionHint,
                  hintStyle: const TextStyle(color: kTextGray),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorderGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: kPrimaryDarkBlue,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(
                      context,
                    )!.pleaseEnterCompanyDescription;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // VERIFICATION DOCUMENTS SECTION
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: kPrimaryOrange, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.companyVerificationOptional,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryDarkBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.verificationDescription,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.acceptedDocuments,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Display uploaded documents
                    if (_verificationDocs.isNotEmpty) ...[
                      ...List.generate(_verificationDocs.length, (index) {
                        final doc = _verificationDocs[index];
                        final fileName = doc.path.split('/').last;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                fileName.endsWith('.pdf')
                                    ? Icons.picture_as_pdf
                                    : Icons.image,
                                color: kPrimaryOrange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeDocument(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],

                    // Upload button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickVerificationDocs,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          _verificationDocs.isEmpty
                              ? AppLocalizations.of(context)!.uploadDocuments
                              : AppLocalizations.of(context)!.addMoreDocuments,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimaryDarkBlue,
                          side: BorderSide(color: kPrimaryDarkBlue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Complete Profile Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryDarkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
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
                          _verificationDocs.isEmpty
                              ? AppLocalizations.of(context)!.completeProfile
                              : AppLocalizations.of(
                                  context,
                                )!.completeAndSubmitForVerification,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              // Skip verification option
              if (_verificationDocs.isEmpty) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _skipVerification,
                    child: Text(
                      AppLocalizations.of(context)!.skipForNowLink,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
