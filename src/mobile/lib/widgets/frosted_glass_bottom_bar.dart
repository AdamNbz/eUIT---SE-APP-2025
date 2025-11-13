import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FrostedGlassBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<BottomBarItem> items;
  final bool isDark;

  const FrostedGlassBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
    this.isDark = true,
  });

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
              top: BorderSide(
                color: isDark
                    ? AppTheme.darkBorder.withOpacity(0.3)
                    : AppTheme.lightBorder.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  items.length,
                  (index) => _BottomBarItemWidget(
                    item: items[index],
                    isSelected: selectedIndex == index,
                    onTap: () => onItemTapped(index),
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBarItemWidget extends StatelessWidget {
  final BottomBarItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _BottomBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8),
                  decoration: isSelected
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.bluePrimary, AppTheme.blueLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.bluePrimary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    item.icon,
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                    size: isSelected ? 26 : 24,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? AppTheme.darkText : AppTheme.bluePrimary)
                        : isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomBarItem {
  final IconData icon;
  final String label;

  const BottomBarItem({
    required this.icon,
    required this.label,
  });
}

