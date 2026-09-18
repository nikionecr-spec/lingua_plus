import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/icons/lp_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Root shell: gradient background + body + custom bottom navigation
/// with 4 destinations (home, dictionary, library, translator).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: 6,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                      child: _NavDestination(
                        icon: _navIcons[i][0],
                        activeIcon: _navIcons[i][1],
                        label: _navLabels[i],
                        selected: navigationShell.currentIndex == i,
                        muted: muted,
                        onTap: () => navigationShell.goBranch(
                          i,
                          initialLocation:
                              i == navigationShell.currentIndex,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const List<List<LpIconData>> _navIcons = [
    [LpIcons.home, LpIcons.home],
    [LpIcons.dictionary, LpIcons.dictionary],
    [LpIcons.library, LpIcons.library],
    [LpIcons.translator, LpIcons.translator],
  ];

  static const List<String> _navLabels = [
    AppStrings.navHome,
    AppStrings.navDictionary,
    AppStrings.navLibrary,
    AppStrings.navTranslator,
  ];
}

/// One custom bottom-nav destination with an animated pill highlight.
class _NavDestination extends StatelessWidget {
  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.muted,
    required this.onTap,
  });

  final LpIconData icon;
  final LpIconData activeIcon;
  final String label;
  final bool selected;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.rMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: LpIcon(
                selected ? activeIcon : icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily:
                    Theme.of(context).textTheme.bodySmall?.fontFamily,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// App-wide backdrop: base color + soft blue/violet radial glows.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.night : AppColors.day,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF101737), AppColors.night]
                : const [Color(0xFFEDF0FE), AppColors.day],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Standard horizontal page padding helper.
EdgeInsets pagePadding() =>
    const EdgeInsets.symmetric(horizontal: AppDimensions.lg);
