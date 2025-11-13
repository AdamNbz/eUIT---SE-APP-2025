import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/notification_item.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final bool isDark;
  final int index;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.isDark = true,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isUnread
              ? AppTheme.bluePrimary.withOpacity(0.3)
              : (isDark
                  ? AppTheme.darkBorder.withOpacity(0.2)
                  : AppTheme.lightBorder.withOpacity(0.3)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: notification.isUnread
                ? AppTheme.bluePrimary.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: notification.isUnread
                        ? const LinearGradient(
                            colors: [AppTheme.bluePrimary, AppTheme.blueLight],
                          )
                        : LinearGradient(
                            colors: [
                              (isDark ? AppTheme.darkBackground : Colors.grey.shade200),
                              (isDark ? AppTheme.darkBackground : Colors.grey.shade100),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: notification.isUnread
                        ? Colors.white
                        : (isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          color: isDark ? AppTheme.darkText : AppTheme.lightText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.body != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.body!,
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        notification.time,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.darkTextSecondary.withOpacity(0.6)
                              : AppTheme.lightTextSecondary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Unread indicator
                if (notification.isUnread)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.bluePrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.bluePrimary.withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(duration: 1.seconds)
                      .then()
                      .fadeOut(duration: 1.seconds),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (50 * index).ms)
        .slideX(begin: 0.2, end: 0);
  }
}

