import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khedmni/models/company.dart';
import 'package:khedmni/logic/cubits/company_cubit.dart';
import 'package:khedmni/logic/cubits/company_state.dart';
import 'package:khedmni/logic/cubits/auth_cubit.dart';
import 'package:khedmni/logic/cubits/auth_state.dart';
import '../core/routes/route_names.dart';
import 'package:khedmni/l10n/app_localizations.dart'; // Add import

class PostOfferScreen extends StatefulWidget {
  final Company company;

  const PostOfferScreen({super.key, required this.company});

  @override
  State<PostOfferScreen> createState() => _PostOfferScreenState();
}

class _PostOfferScreenState extends State<PostOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _deadline;
  String _selectedCategory = 'IT & Tech';
  final List<String> _categories = ['IT & Tech', 'Design', 'Marketing', 'Finance', 'Education', 'Health'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _handlePostOffer() {
    if (_formKey.currentState!.validate()) {
      if (_deadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectDeadline)),
        );
        return;
      }

      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loginToApply)),
        );
        return;
      }

      final user = (authState).user;
      if (user.userType != 'company') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only company accounts can post offers')),
        );
        return;
      }

      if (!user.isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please verify your email before posting.'),
            action: SnackBarAction(
              label: 'Verify',
              onPressed: () => Navigator.pushNamed(context, RouteNames.emailVerificationInterstitial),
            ),
          ),
        );
        return;
      }

      // Use CompanyCubit to post the job
      context.read<CompanyCubit>().postJob(
            title: _titleController.text,
            description: _descriptionController.text,
            requirements: _requirementsController.text,
            location: _locationController.text,
            deadline: _deadline!,
            type: 'Full-time',
            category: _selectedCategory,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyCubit, CompanyState>(
      listener: (context, state) {
        if (state is JobPostAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.jobPostedSuccess)),
          );
          Navigator.pop(context);
        } else if (state is CompanyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppLocalizations.of(context)!.postNewOffer,
            style: const TextStyle(
              color: Color(0xFF1E3A5F),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job title
                  Text(
                    AppLocalizations.of(context)!.jobTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.jobTitleHint,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterJobTitle;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Job Description
                  Text(
                    AppLocalizations.of(context)!.jobDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.jobDescriptionHint,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                         return AppLocalizations.of(context)!.pleaseEnterJobDescription;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Requirements
                   Text(
                    AppLocalizations.of(context)!.requirementsLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _requirementsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.requirementsHint,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterRequirements;
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
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.locationHint,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterLocation;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Category
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // Application Deadline
                   Text(
                    AppLocalizations.of(context)!.applicationDeadline,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDeadline,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _deadline == null
                                ? AppLocalizations.of(context)!.selectDeadline
                                : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                            style: TextStyle(
                              color: _deadline == null ? Colors.grey[600] : Colors.black,
                            ),
                          ),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Post Offer Button
                  SizedBox(
                    width: double.infinity,
                    child: BlocBuilder<CompanyCubit, CompanyState>(
                      builder: (context, state) {
                        final isSubmitting = state is CompanySubmitting;
                        return ElevatedButton(
                          onPressed: isSubmitting ? null : _handlePostOffer,
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(AppLocalizations.of(context)!.postOfferAction),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}