import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/icons/lp_icons.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/data/models/library_models.dart';
import 'package:lingua_plus/features/dictionary/dictionary_providers.dart';
import 'package:lingua_plus/features/library/classics.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';
import 'package:lingua_plus/features/library/library_providers.dart';
import 'package:lingua_plus/features/library/library_data.dart';

/// Home dashboard: greeting, live stats, WOTD, quick actions and
/// continue-reading. The learning module was removed in v1.2.0.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favCount = ref.watch(favoritesProvider).value?.length ?? 0;
    final states =
        ref.watch(readingStatesProvider).valueOrNull ?? const <ReadingState>[];

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
                    icon: const LpIcon(LpIcons.settings, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: LpIcons.dictionary,
                      label: AppStrings.homeStatsWords,
                      value: '۹,۹۷۷',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: StatCard(
                      icon: LpIcons.library,
                      label: AppStrings.homeStatsBooks,
                      value: '${kClassicBooks.length + 14}',
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: StatCard(
                      icon: LpIcons.starFilled,
                      label: AppStrings.homeStatsFavorites,
                      value: '$favCount',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xl),
              _wordOfTheDay(context, ref),
              const SizedBox(height: AppDimensions.xl),
              const SectionHeader(title: AppStrings.homeQuickActions),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: LpIcons.dictionary,
                      label: AppStrings.navDictionary,
                      onTap: () => context.go(Routes.dictionary),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: _QuickAction(
                      icon: LpIcons.library,
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
                      icon: LpIcons.translator,
                      label: AppStrings.navTranslator,
                      onTap: () => context.go(Routes.translator),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: _QuickAction(
                      icon: LpIcons.star,
                      label: AppStrings.favoritesTitle,
                      onTap: () => context.push(Routes.favorites),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xl),
              _continueReading(context, ref, states),
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
                child: const Center(
                  child: LpIcon(
                    LpIcons.sparkle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.homeWordOfDay,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    En(
                      wotd.display.isEmpty ? wotd.word : wotd.display,
                      style: AppTypography.en(
                        fontSize: 16,
                        weight: FontWeight.w700,
                      ),
                    ),
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
                icon: const LpIcon(LpIcons.volumeUp, size: 22),
                color: AppColors.primary,
                visualDensity: VisualDensity.compact,
              ),
              const LpIcon(LpIcons.chevronLeft,
                  size: 20, color: AppColors.mutedDark),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _continueReading(
    BuildContext context,
    WidgetRef ref,
    List<ReadingState> states,
  ) {
    if (states.isEmpty) return const SizedBox.shrink();
    final state = states.first;
    BookMeta? meta;
    for (final b in kLibraryBooks) {
      if (b.id == state.bookId) meta = b;
    }
    ClassicBook? classic;
    for (final c in kClassicBooks) {
      if (c.id == state.bookId) classic = c;
    }
    final titleFa = meta?.titleFa ?? classic?.titleFa;
    final titleEn = meta?.titleEn ?? classic?.titleEn;
    final cover = meta?.cover ?? classic?.cover;
    if (titleFa == null || titleEn == null) return const SizedBox.shrink();
    final total = state.totalPages > 0 ? state.totalPages : 100;
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
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.rSm),
                child: cover != null
                    ? Image.asset(cover, width: 44, height: 62, fit: BoxFit.cover)
                    : const SizedBox(width: 44, height: 62),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleFa,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    En(
                      titleEn,
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
              const LpIcon(LpIcons.chevronLeft,
                  size: 20, color: AppColors.mutedDark),
            ],
          ),
        ),
      ],
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

  final LpIconData icon;
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
            child: Center(child: LpIcon(icon, color: Colors.white, size: 22)),
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
