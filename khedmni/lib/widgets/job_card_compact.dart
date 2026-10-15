import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/job.dart';
import 'package:khedmni/l10n/app_localizations.dart';

class JobCardCompact extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final VoidCallback? onCompanyTap;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const JobCardCompact({
    Key? key,
    required this.job,
    required this.onTap,
    this.onCompanyTap,
    this.width = 280,
    this.margin = const EdgeInsets.only(right: 16),
  }) : super(key: key);

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

  String _localizeCategory(BuildContext context, String category) {
    switch (category) {
      case 'IT & Tech': return AppLocalizations.of(context)!.categoryITTech;
      case 'Design': return AppLocalizations.of(context)!.categoryDesign;
      case 'Marketing': return AppLocalizations.of(context)!.categoryMarketing;
      case 'Finance': return AppLocalizations.of(context)!.categoryFinance;
      case 'Education': return AppLocalizations.of(context)!.categoryEducation;
      case 'Health': return AppLocalizations.of(context)!.categoryHealth;
      default: return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey.shade200,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1D3557),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF77F00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _localizeJobType(context, job.jobType),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF77F00),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onCompanyTap,
                child: Row(
                  children: [
                    Text(
                      job.company,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _localizeCategory(context, job.category),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.salary,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF77F00),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
