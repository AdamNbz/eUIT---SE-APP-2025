import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final int index;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDark = true,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppTheme.darkCard,
                    AppTheme.darkCard.withOpacity(0.8),
                  ]
                : [
                    AppTheme.lightCard,
                    Colors.white,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppTheme.darkBorder.withOpacity(0.3)
                : AppTheme.lightBorder.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.bluePrimary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.bluePrimary, AppTheme.blueLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.bluePrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
                  const SizedBox(width: 14),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isDark ? AppTheme.darkText : AppTheme.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideX(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: (100 * index).ms)
          .slideY(begin: 0.3, end: 0),
    );
  }
}

