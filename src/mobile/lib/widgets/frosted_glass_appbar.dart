import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FrostedGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String studentId;
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onAvatarTap;
  final bool isDark;

  const FrostedGlassAppBar({
    super.key,
    required this.userName,
    required this.studentId,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onAvatarTap,
    this.isDark = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkCard.withOpacity(0.7)
                : Colors.white.withOpacity(0.7),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppTheme.darkBorder.withOpacity(0.3)
                    : AppTheme.lightBorder.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.bluePrimary, AppTheme.blueLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.bluePrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: onAvatarTap,
                      icon: const Icon(Icons.person_outline, color: Colors.white),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            color: isDark ? AppTheme.darkText : AppTheme.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'MSSV: $studentId',
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification button
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppTheme.darkBackground.withOpacity(0.5)
                              : Colors.white.withOpacity(0.5),
                        ),
                        child: IconButton(
                          onPressed: onNotificationTap,
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: isDark ? Colors.white : AppTheme.lightText,
                          ),
                        ),
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.error.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                notificationCount > 9 ? '9+' : '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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

