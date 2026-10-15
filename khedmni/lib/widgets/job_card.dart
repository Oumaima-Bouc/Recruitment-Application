import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/job.dart';
import 'package:khedmni/l10n/app_localizations.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onApply;
  final VoidCallback? onCompanyTap;

  const JobCard({
    super.key,
    required this.job,
    required this.onApply,
    this.onCompanyTap,
  });

  String _localizeJobType(BuildContext context, String jobType) {
    switch (jobType.toLowerCase()) {
      case 'full-time': return AppLocalizations.of(context)!.fullTime;
      case 'part-time': return AppLocalizations.of(context)!.partTime;
      case 'contract': return AppLocalizations.of(context)!.contract;
      case 'freelance': return AppLocalizations.of(context)!.freelance;
      case 'remote': return AppLocalizations.of(context)!.remote;
      case 'internship': return AppLocalizations.of(context)!.internship;
      default: return jobType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onApply, // Tapping the card applies/shows details
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job title
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Company name
              GestureDetector(
                onTap: onCompanyTap,
                child: Text(
                  job.company,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryOrange, // Highlight clickable
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Location and Job Type
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _localizeJobType(context, job.jobType),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Salary
              Text(
                job.salary, // Salary might also need localization logic if it has currency text, but usually it's numbers + symbol
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 12),

              // Description (truncated)
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: onApply,
                  child: Text(
                    AppLocalizations.of(context)!.applyNow,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
