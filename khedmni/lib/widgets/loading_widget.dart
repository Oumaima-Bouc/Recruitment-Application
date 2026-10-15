import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

/// Reusable loading widget for consistent loading states across the app
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  
  const LoadingWidget({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primaryOrange,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small inline loading indicator for buttons or small spaces
class SmallLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;
  
  const SmallLoadingIndicator({
    super.key,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }
}
