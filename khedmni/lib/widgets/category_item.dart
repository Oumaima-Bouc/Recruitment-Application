import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.title,
    this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF1E3A5F) 
              : (isDark ? Colors.grey[900] : Colors.white),
          borderRadius: BorderRadius.circular(100),
          border: isSelected 
              ? null 
              : Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey.shade300, 
                  width: 1,
                ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF1E3A5F).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF1E3A5F)),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? Colors.white70 : const Color(0xFF1E3A5F)),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
