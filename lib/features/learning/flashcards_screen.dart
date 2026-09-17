import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/data/models/word_entry.dart';
import 'package:lingua_plus/features/learning/learning_providers.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';

/// SRS review: flip-card flow over the due deck.
class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  int _index = 0;
  bool _flipped = false;
  bool _busy = false;
  bool _done = false;
  int _xp = 0;

  /// Non-empty Persian meaning groups of a row.
  List<String> _faGroups(WordRow row) => [
        for (final m in row.meanings)
          if (m.definitions.isNotEmpty) m.definitions.join('، '),
      ];

  Future<void> _answer(List<WordRow> rows, int idx, bool correct) async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref
        .read(learningDsProvider)
        .review(rows[idx].word, correct: correct);
    if (!mounted) return;
    final isLast = idx >= rows.length - 1;
    setState(() {
      _xp += correct ? 10 : 2;
      _flipped = false;
      _busy = false;
      if (isLast) {
        _done = true;
      } else {
        _index = idx + 1;
      }
    });
    if (isLast) {
      ref.invalidate(dueCardsProvider);
      ref.invalidate(statsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueAsync = ref.watch(dueCardsProvider);

    Widget body;
    if (_done) {
      body = _completionView(context);
    } else {
      body = dueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: AppStrings.errorGeneric,
          subtitle: 'کارت‌های مرور بارگذاری نشدند.',
        ),
        data: (cards) {
          if (cards.isEmpty) return _emptyView(context);
          final rows = [for (final c in cards) c.$2];
          final idx = _index.clamp(0, rows.length - 1).toInt();
          final row = rows[idx];
          final faGroups = _faGroups(row);
          final firstFa = faGroups.isEmpty ? '—' : faGroups.first;
          final secondFa = faGroups.length > 1 ? faGroups[1] : '';
          final example =
              row.examples.isEmpty ? null : row.examples.first;

          return Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go(Routes.learning),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Expanded(
                      child: GradientProgressBar(
                        value: (idx + 1) / rows.length,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    En(
                      '${idx + 1} / ${rows.length}',
                      style: AppTypography.en(
                        fontSize: 12.5,
                        color: AppColors.mutedDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.lg),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _flipped = !_flipped),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: KeyedSubtree(
                        key: ValueKey<bool>(_flipped),
                        child: _flipped
                            ? _backCard(
                                context, row, firstFa, secondFa, example)
                            : _frontCard(context, row),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _busy ? null : () => _answer(rows, idx, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            AppDimensions.buttonHeight,
                          ),
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.buttonHeight / 2,
                            ),
                          ),
                        ),
                        child: const Text(AppStrings.learningDontKnow),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: GradientButton(
                        label: AppStrings.learningKnow,
                        icon: Icons.check_rounded,
                        expanded: false,
                        onPressed:
                            _busy ? null : () => _answer(rows, idx, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: body),
    );
  }

  Widget _frontCard(BuildContext context, WordRow row) {
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          En(
            row.display.isEmpty ? row.word : row.display,
            style: AppTypography.en(fontSize: 30, weight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          if (row.ipaUs.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.sm),
            En(
              row.ipaUs,
              style: AppTypography.en(fontSize: 15, color: AppColors.info),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppDimensions.lg),
          IconButton(
            onPressed: () => ref
                .read(speechProvider)
                .speak(row.word, lang: 'en-US'),
            icon: const Icon(Icons.volume_up_rounded, size: 28),
            color: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            AppStrings.learningTapToFlip,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _backCard(
    BuildContext context,
    WordRow row,
    String firstFa,
    String secondFa,
    WordExample? example,
  ) {
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            firstFa,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (secondFa.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.sm),
            Text(
              secondFa,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          if (example != null && example.en.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.lg),
            GlassCard(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  En(
                    example.en,
                    style: AppTypography.en(
                      fontSize: 14,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    example.fa,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.lg),
          LevelChip(level: row.level),
        ],
      ),
    );
  }

  Widget _completionView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.rXl),
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(
              AppStrings.learningAllDone,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              '${AppStrings.learningXpGained}: +$_xp',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppDimensions.xxl),
            GradientButton(
              label: AppStrings.back,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go(Routes.learning),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const EmptyState(
            icon: Icons.style_rounded,
            title: 'مروری برای امروز نیست',
            subtitle: 'همه کارت‌های امروز را مرور کردی؛ بعداً سر بزن.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.xxl,
            ),
            child: GradientButton(
              label: AppStrings.back,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go(Routes.learning),
            ),
          ),
        ],
      ),
    );
  }
}
