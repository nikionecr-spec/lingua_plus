import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/features/dictionary/dictionary_providers.dart';
import 'package:lingua_plus/features/learning/learning_providers.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';

/// Badge id → (icon, Persian label).
const Map<String, (IconData, String)> kBadgeMeta = {
  'first_step': (Icons.emoji_emotions_rounded, 'اولین قدم'),
  'spark': (Icons.star_rounded, 'جرقه'),
  'rising': (Icons.trending_up_rounded, 'شتاب'),
  'master': (Icons.military_tech_rounded, 'استاد'),
  'scholar': (Icons.auto_stories_rounded, 'دانا'),
  'on_fire': (Icons.local_fire_department_rounded, 'آتشین'),
  'unstoppable': (Icons.rocket_launch_rounded, 'متوقف‌نشدنی'),
};

/// Learning hub: stats, word of the day, review banner, quiz and badges.
class LearningHubScreen extends ConsumerWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider).value;
    final dueCount = ref.watch(dueCardsProvider).value?.length ?? 0;
    final earned = stats?.badges ?? const <String>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.lg,
            AppDimensions.lg,
            AppDimensions.lg,
            AppDimensions.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.learningTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push(Routes.settings),
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.bolt_rounded,
                      label: AppStrings.homeStatsXp,
                      value: '${stats?.xp ?? 0}',
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_fire_department_rounded,
                      label: AppStrings.homeStatsStreak,
                      value: '${stats?.streak ?? 0}',
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: StatCard(
                      icon: Icons.school_rounded,
                      label: AppStrings.homeStatsLearned,
                      value: '${stats?.learnedWords ?? 0}',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xl),
              _wordOfTheDay(context, ref),
              const SizedBox(height: AppDimensions.xl),
              GlassCard(
                onTap: () => context.push(Routes.flashcards),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.rMd),
                      ),
                      child: const Icon(Icons.style_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.learningStartReview,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$dueCount ${AppStrings.learningDue}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded,
                        color: AppColors.mutedDark),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              GlassCard(
                onTap: () => context.push(Routes.quiz),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.rMd),
                      ),
                      child: const Icon(Icons.quiz_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.learningQuiz,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '۱۰ سؤال چهارگزینه‌ای',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded,
                        color: AppColors.mutedDark),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              const SectionHeader(title: AppStrings.learningBadges),
              Wrap(
                spacing: AppDimensions.sm,
                runSpacing: AppDimensions.sm,
                children: [
                  for (final entry in kBadgeMeta.entries)
                    _BadgeChip(
                      icon: entry.value.$1,
                      label: entry.value.$2,
                      earned: earned.contains(entry.key),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wordOfTheDay(BuildContext context, WidgetRef ref) {
    final wotdAsync = ref.watch(wotdProvider);
    return wotdAsync.when(
      data: (wotd) {
        if (wotd == null) return const SizedBox.shrink();
        final faMeaning =
            (wotd.meanings.isNotEmpty &&
                    wotd.meanings.first.definitions.isNotEmpty)
                ? wotd.meanings.first.definitions.first
                : '—';
        return GlassCard(
          onTap: () => context.push(
            '${Routes.wordDetail}?q=${Uri.encodeComponent(wotd.word)}',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: AppStrings.homeWordOfDay),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: En(
                                wotd.display.isEmpty
                                    ? wotd.word
                                    : wotd.display,
                                style: AppTypography.en(
                                  fontSize: 22,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            LevelChip(level: wotd.level),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Text(
                          faMeaning,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(speechProvider)
                        .speak(wotd.word, lang: 'en-US'),
                    icon: const Icon(Icons.volume_up_rounded),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

/// One badge pill: highlighted when earned, greyed when locked.
class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.earned,
  });

  final IconData icon;
  final String label;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lockedColor =
        isDark ? AppColors.mutedDark : AppColors.mutedLight;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: earned
            ? AppColors.primary.withValues(alpha: 0.14)
            : lockedColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: earned
              ? AppColors.primary.withValues(alpha: 0.45)
              : (isDark ? AppColors.strokeDark : AppColors.strokeLight),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: earned ? AppColors.warning : lockedColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: earned
                      ? (isDark
                          ? AppColors.textDarkMode
                          : AppColors.textLightMode)
                      : lockedColor,
                  fontWeight: earned ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}
