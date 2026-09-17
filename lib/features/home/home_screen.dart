import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/data/models/library_models.dart';
import 'package:lingua_plus/features/dictionary/dictionary_providers.dart';
import 'package:lingua_plus/features/learning/learning_providers.dart';
import 'package:lingua_plus/features/library/library_data.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';

/// Home dashboard: greeting, stats, WOTD, daily challenge, quick
/// actions and continue-reading.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider).value;
    final dueCount = ref.watch(dueCardsProvider).value?.length ?? 0;
    // Simple daily-challenge approximation: fills up as the deck drains.
    final challenge = dueCount >= 20 ? 0.0 : (20 - dueCount) / 20;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.homeGreeting,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.homeSubtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.16),
                    AppColors.accent.withValues(alpha: 0.10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.rMd),
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Text(
                            AppStrings.homeDailyChallenge,
                            style:
                                Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      AppStrings.homeDailyChallengeBody,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    GradientProgressBar(value: challenge, height: 8),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              const SectionHeader(title: AppStrings.homeQuickActions),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.menu_book_rounded,
                      label: AppStrings.navDictionary,
                      onTap: () => context.go(Routes.dictionary),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.auto_stories_rounded,
                      label: AppStrings.navLibrary,
                      onTap: () => context.go(Routes.library),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.translate_rounded,
                      label: AppStrings.navTranslator,
                      onTap: () => context.go(Routes.translator),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.psychology_rounded,
                      label: AppStrings.navLearning,
                      onTap: () => context.go(Routes.learning),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xl),
              _continueReading(context, ref),
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
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.rMd),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    En(
                      wotd.display.isEmpty ? wotd.word : wotd.display,
                      style: AppTypography.en(
                        fontSize: 16,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      faMeaning,
                      maxLines: 1,
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
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                color: AppColors.primary,
                visualDensity: VisualDensity.compact,
              ),
              const Icon(Icons.chevron_left_rounded,
                  color: AppColors.mutedDark),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _continueReading(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<ReadingState>>(
      future: ref.read(libraryDsProvider).readingStates(),
      builder: (context, snap) {
        final states = snap.data;
        if (states == null || states.isEmpty) return const SizedBox.shrink();
        final state = states.first;
        BookMeta? meta;
        for (final b in kLibraryBooks) {
          if (b.id == state.bookId) {
            meta = b;
            break;
          }
        }
        if (meta == null) return const SizedBox.shrink();
        final total =
            state.totalPages > 0 ? state.totalPages : meta.pages.length;
        final value = total > 0 ? (state.page + 1) / total : 0.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: AppStrings.homeContinueReading),
            GlassCard(
              onTap: () => context.push(
                '${Routes.reader}?book=${Uri.encodeComponent(state.bookId)}',
              ),
              child: Row(
                children: [
                  Text(meta.emoji,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.titleFa,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        En(
                          meta.titleEn,
                          style: AppTypography.en(
                            fontSize: 12,
                            color: AppColors.mutedDark,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        GradientProgressBar(value: value, height: 6),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_left_rounded,
                      color: AppColors.mutedDark),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One 2x2 quick-action tile.
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppDimensions.rSm),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
