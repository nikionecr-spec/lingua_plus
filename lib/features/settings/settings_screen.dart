import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/icons/lp_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/ui_kit.dart';

/// App settings: theme mode, data cleanup, about. Full-screen route
/// (outside the bottom-nav shell).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _confirmClearHistory() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.settingsClearHistory),
        content: const Text('مطمئنی؟ این کار برگشت‌پذیر نیست.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      await ref.read(dictionaryDsProvider).clearHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.settingsHistoryCleared)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const LpIcon(LpIcons.chevronRight),
        ),
        title: const Text(AppStrings.settingsTitle),
      ),
      body: ListView(
        padding: pagePadding() +
            const EdgeInsets.only(bottom: AppDimensions.xxl),
        children: [
          const SectionHeader(title: AppStrings.settingsTheme),
          Row(
            children: [
              Expanded(
                child: _ThemeOption(
                  icon: LpIcons.autoTheme,
                  label: AppStrings.settingsThemeSystem,
                  selected: themeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.system),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _ThemeOption(
                  icon: LpIcons.sun,
                  label: AppStrings.settingsThemeLight,
                  selected: themeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _ThemeOption(
                  icon: LpIcons.moon,
                  label: AppStrings.settingsThemeDark,
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.dark),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.xl),
          const SectionHeader(title: AppStrings.settingsData),
          GlassCard(
            onTap: _confirmClearHistory,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppDimensions.rSm),
                  ),
                  child: const Center(
                    child: LpIcon(
                      LpIcons.trash,
                      color: AppColors.danger,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Text(
                    AppStrings.settingsClearHistory,
                    style: textTheme.titleSmall,
                  ),
                ),
                const LpIcon(
                  LpIcons.chevronLeft,
                  size: 20,
                  color: AppColors.mutedDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.xl),
          const SectionHeader(title: AppStrings.settingsAbout),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppDimensions.rLg),
                  ),
                  child: const Center(
                    child: En(
                      'L+',
                      style: TextStyle(
                        fontFamily: AppTypography.enFamily,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                const En(
                  AppStrings.appName,
                  style: TextStyle(
                    fontFamily: AppTypography.enFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.appTagline,
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  AppStrings.settingsVersion,
                  style: textTheme.labelSmall,
                ),
                const Divider(height: AppDimensions.xl),
                Text(
                  AppStrings.settingsSources,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final LpIconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.md,
      ),
      color: selected
          ? AppColors.primary.withValues(alpha: 0.12)
          : null,
      borderColor: selected ? AppColors.primary : null,
      child: Column(
        children: [
          LpIcon(
            icon,
            size: 26,
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: selected ? AppColors.primary : null,
                ),
          ),
        ],
      ),
    );
  }
}
