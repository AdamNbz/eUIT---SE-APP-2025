import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final bool isDark;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailingIcon,
    this.onTrailingTap,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.2, end: 0),
        if (trailingIcon != null)
          IconButton(
            onPressed: onTrailingTap,
            icon: Icon(
              trailingIcon,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
      ],
    );
  }
}

