import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/data/models/library_models.dart';
import 'package:lingua_plus/features/library/library_data.dart';
import 'package:lingua_plus/features/library/library_providers.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';

/// Brand colors per CEFR level badge.
const _levelColors = <String, Color>{
  'A1': Color(0xFF2DD4BF),
  'A2': Color(0xFF38BDF8),
  'B1': Color(0xFF8B5CF6),
  'B2': Color(0xFFF472B6),
  'C1': Color(0xFFFBBF24),
};

const _levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1'];

Color _colorForLevel(String level) =>
    _levelColors[level] ?? const Color(0xFF8B5CF6);

/// Library tab: header, level filter chips, "continue reading" rail and a
/// cover-art grid of all graded bilingual books with per-book progress.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _filter = 'همه';

  @override
  Widget build(BuildContext context) {
    final states =
        ref.watch(readingStatesProvider).valueOrNull ?? const <ReadingState>[];

    // One pass over states: bookId → progress (0..1) and the first
    // three known books for the "continue reading" rail.
    final progress = <String, double>{};
    final continueItems = <(BookMeta, int, int)>[]; // (book, page, total)
    for (final s in states) {
      final book = _bookById(s.bookId);
      final total = s.totalPages > 0 ? s.totalPages : (book?.pages.length ?? 0);
      if (book == null || total == 0) continue;
      progress[s.bookId] = s.page / total;
      if (continueItems.length < 3) {
        continueItems.add((book, s.page, total));
      }
    }

    final filtered = _filter == 'همه'
        ? kLibraryBooks
        : kLibraryBooks.where((b) => b.level == _filter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.lg,
                ),
                child: _Header(),
              ),
              const SizedBox(height: AppDimensions.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.lg,
                ),
                child: _LevelChips(
                  selected: _filter,
                  counts: _countsByLevel(),
                  onSelected: (l) => setState(() => _filter = l),
                ),
              ),
              if (continueItems.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.xl),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                  child: SectionHeader(title: AppStrings.libraryContinue),
                ),
                SizedBox(
                  height: 178,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                    ),
                    itemCount: continueItems.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppDimensions.md),
                    itemBuilder: (context, index) {
                      final (book, page, total) = continueItems[index];
                      return _ContinueCard(
                        book: book,
                        page: page,
                        total: total,
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                child: SectionHeader(
                  title: _filter == 'همه' ? 'همه کتاب‌ها' : 'سطح $_filter',
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.lg,
                  AppDimensions.md,
                  AppDimensions.lg,
                  AppDimensions.xl,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppDimensions.md,
                  crossAxisSpacing: AppDimensions.md,
                  childAspectRatio: 0.66,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final book = filtered[index];
                  return _BookCard(
                    book: book,
                    progress: progress[book.id] ?? 0,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _countsByLevel() {
    final counts = <String, int>{};
    for (final b in kLibraryBooks) {
      counts[b.level] = (counts[b.level] ?? 0) + 1;
    }
    return counts;
  }

  BookMeta? _bookById(String id) {
    for (final book in kLibraryBooks) {
      if (book.id == id) return book;
    }
    return null;
  }
}

/// Horizontal row of level filter chips (همه / A1 / A2 / B1 / B2 / C1).
class _LevelChips extends StatelessWidget {
  const _LevelChips({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final String selected;
  final Map<String, int> counts;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = ['همه', ..._levelOrder];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        itemBuilder: (context, i) {
          final label = labels[i];
          final isSelected = label == selected;
          final color = label == 'همه' ? null : _colorForLevel(label);
          final count = label == 'همه'
              ? kLibraryBooks.length
              : (counts[label] ?? 0);
          return GestureDetector(
            onTap: () => onSelected(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected
                    ? null
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (color ?? AppColors.mutedDark).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (color != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    count > 0 && label != 'همه' ? '$label · $count' : label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.mutedDark
                                  : AppColors.mutedLight,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
      ),
    );
  }
}

/// Top header: gradient emoji tile + title + subtitle.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.rMd),
          ),
          child: const Center(
            child: Text('📚', style: TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.libraryTitle, style: textTheme.headlineSmall),
              Text(AppStrings.librarySubtitle, style: textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// Horizontal "continue reading" card with a mini cover + progress bar.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.book,
    required this.page,
    required this.total,
  });

  final BookMeta book;
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    return SizedBox(
      width: 176,
      child: GlassCard(
        onTap: () => context.push('${Routes.reader}?book=${book.id}'),
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _CoverImage(book: book, radius: AppDimensions.rSm)),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.titleFa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  _LevelBadge(level: book.level, compact: true),
                  const Spacer(),
                  GradientProgressBar(
                    value: total > 0 ? page / total : 0,
                    height: 6,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'صفحه ${page + 1} از $total',
                    style: AppTypography.en(
                      fontSize: 10,
                      weight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cover image with graceful emoji fallback when the asset is missing.
class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.book, this.radius = AppDimensions.rMd});

  final BookMeta book;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cover = book.cover;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (cover != null)
            Image.asset(
              cover,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _CoverFallback(book: book),
            )
          else
            _CoverFallback(book: book),
        ],
      ),
    );
  }
}

/// Gradient + emoji fallback used when a cover asset is unavailable.
class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.book});

  final BookMeta book;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      alignment: Alignment.center,
      child: Text(book.emoji, style: const TextStyle(fontSize: 40)),
    );
  }
}

/// Small colored CEFR badge.
class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, this.compact = false});

  final String level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _colorForLevel(level);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        level,
        style: AppTypography.en(
          fontSize: compact ? 9.5 : 11.5,
          weight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Grid tile for one book: cover art, level badge, titles, progress.
class _BookCard extends StatelessWidget {
  const _BookCard({required this.book, required this.progress});

  final BookMeta book;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    return GlassCard(
      onTap: () => context.push('${Routes.reader}?book=${book.id}'),
      padding: const EdgeInsets.all(AppDimensions.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CoverImage(book: book),
                // Bottom scrim so text stays readable over art.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 64,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: _LevelBadge(level: book.level, compact: true),
                ),
                if (progress > 0)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: GradientProgressBar(value: progress, height: 5),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.titleFa,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: En(
                        book.titleEn,
                        style: AppTypography.en(
                          fontSize: 10.5,
                          weight: FontWeight.w500,
                          color: muted,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      '${book.pages.length}ص',
                      style: AppTypography.en(
                        fontSize: 10,
                        weight: FontWeight.w600,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
