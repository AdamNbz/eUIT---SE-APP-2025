import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/quick_action.dart';

class QuickActionButton extends StatefulWidget {
  final QuickAction action;
  final VoidCallback onTap;
  final bool isDark;

  const QuickActionButton({
    super.key,
    required this.action,
    required this.onTap,
    this.isDark = true,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  IconData? _resolveIcon() {
    if (widget.action.textIcon != null) return null;
    switch (widget.action.iconName) {
      case 'school_outlined':
        return Icons.school_outlined;
      case 'calendar_today_outlined':
        return Icons.calendar_today_outlined;
      case 'monetization_on_outlined':
        return Icons.monetization_on_outlined;
      case 'edit_document':
        return Icons.edit_document;
      case 'check_box_outlined':
        return Icons.check_box_outlined;
      case 'description_outlined':
        return Icons.description_outlined;
      case 'workspace_premium_outlined':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _resolveIcon();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isDark
                        ? [
                            AppTheme.bluePrimary.withOpacity(0.2),
                            AppTheme.blueLight.withOpacity(0.1),
                          ]
                        : [
                            AppTheme.bluePrimary.withOpacity(0.1),
                            AppTheme.blueLight.withOpacity(0.05),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.bluePrimary.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.bluePrimary.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: iconData != null
                      ? Icon(
                          iconData,
                          color: AppTheme.bluePrimary,
                          size: 28,
                        )
                      : Text(
                          widget.action.textIcon ?? '',
                          style: TextStyle(
                            color: AppTheme.bluePrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
                  .then() // Wait for the above animations
                  .shimmer(
                    duration: 2.seconds,
                    delay: 500.ms,
                    color: AppTheme.bluePrimary.withOpacity(0.3),
                  ),
              const SizedBox(height: 10),
              // Label
              Text(
                widget.action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.isDark
                      ? AppTheme.darkText
                      : AppTheme.lightText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

