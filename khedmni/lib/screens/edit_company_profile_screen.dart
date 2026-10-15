import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/company.dart';
import '../logic/cubits/company_cubit.dart';
import '../l10n/app_localizations.dart';

// Color constants
const Color kPrimaryDarkBlue = Color(0xFF1D3557);
const Color kPrimaryOrange = Color(0xFFF77F00);

class EditCompanyProfileScreen extends StatefulWidget {
  final Company company;

  const EditCompanyProfileScreen({super.key, required this.company});

  @override
  State<EditCompanyProfileScreen> createState() =>
      _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _industryController;
  late TextEditingController _websiteController;
  late TextEditingController _descriptionController;
  late TextEditingController _contactController;

  List<String> _verificationDocs = [];
  List<String> _newDocuments = [];
  List<String> _photos = [];
  List<String> _newPhotos = [];
  String? _logoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company.name);
    _industryController = TextEditingController(text: widget.company.industry);
    _websiteController = TextEditingController(text: widget.company.website);
    _descriptionController = TextEditingController(
      text: widget.company.description,
    );
    _contactController = TextEditingController(text: widget.company.contact);
    _verificationDocs = List.from(widget.company.verificationDocs);
    _photos = List.from(widget.company.photos);
    _logoPath = widget.company.logoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _logoPath = result.files.single.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.logoSelected(result.files.single.name),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorPickingLogo(e.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _pickVerificationDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _newDocuments.addAll(result.files.map((file) => file.path!).toList());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.documentsAdded(result.files.length),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorPickingDocuments(e.toString()),
          ),
        ),
      );
    }
  }

  void _removeNewDocument(int index) {
    setState(() {
      _newDocuments.removeAt(index);
    });
  }

  Future<void> _pickPhotos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _newPhotos.addAll(result.files.map((file) => file.path!).toList());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.photosAdded(result.files.length),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorPickingPhotos(e.toString()),
          ),
        ),
      );
    }
  }

  void _removeNewPhoto(int index) {
    setState(() {
      _newPhotos.removeAt(index);
    });
  }

  void _removeExistingPhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Combine old and new documents
      final allDocs = [..._verificationDocs, ..._newDocuments];
      // Combine old and new photos
      final allPhotos = [..._photos, ..._newPhotos];

      // Create updated company
      final updatedCompany = Company(
        id: widget.company.id,
        name: _nameController.text.trim(),
        email: widget.company.email,
        industry: _industryController.text.trim(),
        website: _websiteController.text.trim(),
        description: _descriptionController.text.trim(),
        contact: _contactController.text.trim(),
        logoUrl: _logoPath,
        followers: widget.company.followers,
        isVerified: widget.company.isVerified,
        verificationDocs: allDocs,
        photos: allPhotos,
      );

      // Update via cubit
      context.read<CompanyCubit>().updateCompanyProfile(updatedCompany);

      // Show success and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.profileUpdatedSuccessfully,
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context, updatedCompany);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editCompanyProfile,
          style: GoogleFonts.lato(
            color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF0F1720) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : kPrimaryDarkBlue,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Section
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: kPrimaryOrange.withOpacity(0.2),
                            backgroundImage: _logoPath != null
                                ? NetworkImage(_logoPath!)
                                : null,
                            child: _logoPath == null
                                ? Icon(
                                    Icons.business,
                                    size: 50,
                                    color: kPrimaryOrange,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _pickLogo,
                            icon: const Icon(Icons.edit),
                            label: Text(
                              AppLocalizations.of(context)!.changeLogo,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: kPrimaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Company Name
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.companyInformation,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: AppLocalizations.of(context)!.companyName,
                      icon: Icons.business,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.pleaseEnterCompanyName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Industry
                    _buildTextField(
                      controller: _industryController,
                      label: AppLocalizations.of(context)!.industry,
                      icon: Icons.category,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.pleaseEnterIndustry;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Website
                    _buildTextField(
                      controller: _websiteController,
                      label: AppLocalizations.of(context)!.website,
                      icon: Icons.language,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.pleaseEnterWebsite;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contact
                    _buildTextField(
                      controller: _contactController,
                      label: AppLocalizations.of(context)!.contactNumber,
                      icon: Icons.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.pleaseEnterContactNumber;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: AppLocalizations.of(context)!.description,
                      icon: Icons.description,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.pleaseEnterCompanyDescription;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Verification Documents Section
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.verificationDocuments,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.uploadBusinessRegistrationTaxDocs,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Existing Documents
                    if (_verificationDocs.isNotEmpty) ...[
                      Text(
                        AppLocalizations.of(context)!.existingDocuments,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._verificationDocs.asMap().entries.map((entry) {
                        return _buildDocumentItem(
                          entry.value,
                          Icons.check_circle,
                          Colors.green,
                          false,
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // New Documents
                    if (_newDocuments.isNotEmpty) ...[
                      Text(
                        AppLocalizations.of(context)!.newDocuments,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._newDocuments.asMap().entries.map((entry) {
                        return _buildDocumentItem(
                          entry.value,
                          Icons.insert_drive_file,
                          kPrimaryOrange,
                          true,
                          onRemove: () => _removeNewDocument(entry.key),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Upload Button
                    OutlinedButton.icon(
                      onPressed: _pickVerificationDocuments,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        AppLocalizations.of(context)!.addVerificationDocuments,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryOrange,
                        side: BorderSide(color: kPrimaryOrange),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.acceptedFormatsPdfJpgPng,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Company Photos Section
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.companyPhotos,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.showcaseCompanyWorkspace,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Existing Photos Grid
                    if (_photos.isNotEmpty) ...[
                      Text(
                        AppLocalizations.of(context)!.currentPhotos,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          return _buildPhotoThumbnail(
                            _photos[index],
                            onRemove: () => _removeExistingPhoto(index),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // New Photos Grid
                    if (_newPhotos.isNotEmpty) ...[
                      Text(
                        AppLocalizations.of(context)!.newPhotos,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _newPhotos.length,
                        itemBuilder: (context, index) {
                          return _buildPhotoThumbnail(
                            _newPhotos[index],
                            isNew: true,
                            onRemove: () => _removeNewPhoto(index),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Upload Photos Button
                    OutlinedButton.icon(
                      onPressed: _pickPhotos,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(
                        AppLocalizations.of(context)!.addCompanyPhotos,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryOrange,
                        side: BorderSide(color: kPrimaryOrange),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.addUpTo10Photos,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryDarkBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.saveChanges,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kPrimaryDarkBlue,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kPrimaryOrange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: kPrimaryOrange, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDocumentItem(
    String path,
    IconData icon,
    Color color,
    bool showRemove, {
    VoidCallback? onRemove,
  }) {
    final fileName = path.split('/').last.split('\\').last;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: GoogleFonts.lato(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showRemove)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(
    String path, {
    bool isNew = false,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isNew ? kPrimaryOrange : Colors.grey[300]!,
              width: 2,
            ),
            image: DecorationImage(
              image: path.startsWith('http')
                  ? NetworkImage(path) as ImageProvider
                  : FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
