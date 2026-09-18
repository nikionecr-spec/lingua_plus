import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/icons/lp_icons.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/data/models/library_models.dart';
import 'package:lingua_plus/features/library/classics.dart';
import 'package:lingua_plus/features/library/library_data.dart';
import 'package:lingua_plus/features/library/library_providers.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';
import 'package:lingua_plus/shared/widgets/app_shell.dart';

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

/// Library tab: header, level filter chips, "continue reading" rail and
/// cover-art grids for the 59 Gutenberg classics + graded bilinguals.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _filter = 'همه';

  bool _matches(String? level) => _filter == 'همه' || level == _filter;

  @override
  Widget build(BuildContext context) {
    final states =
        ref.watch(readingStatesProvider).valueOrNull ?? const <ReadingState>[];

    // One pass over states: bookId → (page, total) + first 3 continue items.
    final progress = <String, (int, int)>{};
    final continueItems = <(String, int, int)>[]; // (bookId, page, total)
    for (final s in states) {
      if (_bookMeta(s.bookId) == null) continue;
      progress[s.bookId] = (s.page, s.totalPages);
      if (continueItems.length < 3) {
        continueItems.add((s.bookId, s.page, s.totalPages));
      }
    }

    final classics = kClassicBooks.where((b) => _matches(b.level)).toList();
    final readers = kLibraryBooks.where((b) => _matches(b.level)).toList();

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
                  height: 196,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                    ),
                    itemCount: continueItems.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppDimensions.md),
                    itemBuilder: (context, index) {
                      final (bookId, page, total) = continueItems[index];
                      return _ContinueCard(
                        bookId: bookId,
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
                  title: AppStrings.libraryClassicsSection,
                  actionText:
                      '${classics.length} کتاب',
                  onAction: null,
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: pagePadding().copyWith(
                  top: AppDimensions.sm,
                  bottom: AppDimensions.xl,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppDimensions.md,
                  crossAxisSpacing: AppDimensions.md,
                  childAspectRatio: 0.66,
                ),
                itemCount: classics.length,
                itemBuilder: (context, index) {
                  final book = classics[index];
                  final prog = progress[book.id];
                  return _ClassicCoverCard(
                    book: book,
                    page: prog?.$1,
                    total: prog?.$2,
                  );
                },
              ),
              if (readers.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.lg,
                  ),
                  child: SectionHeader(
                    title: AppStrings.libraryReadersSection,
                    actionText: '${readers.length} کتاب',
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: pagePadding().copyWith(
                    top: AppDimensions.sm,
                    bottom: AppDimensions.xxl,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppDimensions.md,
                    crossAxisSpacing: AppDimensions.md,
                    childAspectRatio: 0.66,
                  ),
                  itemCount: readers.length,
                  itemBuilder: (context, index) {
                    final book = readers[index];
                    final prog = progress[book.id];
                    return _ReaderCoverCard(
                      book: book,
                      page: prog?.$1,
                      total: prog?.$2,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _countsByLevel() {
    final counts = <String, int>{'همه': kClassicBooks.length + kLibraryBooks.length};
    for (final l in _levelOrder) {
      counts[l] = kClassicBooks.where((b) => b.level == l).length +
          kLibraryBooks.where((b) => b.level == l).length;
    }
    return counts;
  }

  /// (titleFa, cover, level) for either collection.
  (String, String?, String?)? _bookMeta(String id) {
    for (final c in kClassicBooks) {
      if (c.id == id) return (c.titleFa, c.cover, c.level);
    }
    for (final b in kLibraryBooks) {
      if (b.id == id) return (b.titleFa, b.cover, b.level);
    }
    return null;
  }
}

// ── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.rMd),
          ),
          child: const Center(
            child: LpIcon(LpIcons.library, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.libraryTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                AppStrings.librarySubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Level chips ───────────────────────────────────────────────────────────

class _LevelChips extends StatelessWidget {
  const _LevelChips({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final String selected;
  final Map<String, int> counts;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final levels = ['همه', ..._levelOrder];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final level in levels)
            Padding(
              padding: const EdgeInsets.only(left: AppDimensions.sm),
              child: _LevelChip(
                label: level == 'همه' ? AppStrings.all : level,
                count: counts[level] ?? 0,
                color: level == 'همه' ? AppColors.primary : _colorForLevel(level),
                selected: selected == level,
                onTap: () => onSelected(level),
              ),
            ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.16)
              : (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark
                  : AppColors.cardLight),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : AppColors.strokeLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.faFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? color : null,
              ),
            ),
            const SizedBox(width: 6),
            En(
              '$count',
              style: AppTypography.en(
                fontSize: 11,
                weight: FontWeight.w600,
                color: selected ? color : AppColors.mutedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Continue rail ─────────────────────────────────────────────────────────

class _ContinueCard extends ConsumerWidget {
  const _ContinueCard({
    required this.bookId,
    required this.page,
    required this.total,
  });

  final String bookId;
  final int page;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = _lookup(bookId);
    if (meta == null) return const SizedBox.shrink();
    final (titleFa, _, cover, _, _) = meta;
    final totalPages =
        total > 0 ? total : 100;
    final value = totalPages > 0 ? (page + 1) / totalPages : 0.0;

    return GestureDetector(
      onTap: () => context.push(
        '${Routes.reader}?book=${Uri.encodeComponent(bookId)}',
      ),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppDimensions.rMd),
          border: Border.all(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.rSm),
                child: cover != null
                    ? Image.asset(cover, fit: BoxFit.cover)
                    : const ColoredBox(color: AppColors.night2),
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              titleFa,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            GradientProgressBar(value: value, height: 5),
          ],
        ),
      ),
    );
  }

  (String, String, String?, String, int)? _lookup(String id) {
    for (final c in kClassicBooks) {
      if (c.id == id) {
        return (c.titleFa, c.titleEn, c.cover, c.level, c.sizeKb);
      }
    }
    for (final b in kLibraryBooks) {
      if (b.id == id) {
        return (b.titleFa, b.titleEn, b.cover, b.level, 0);
      }
    }
    return null;
  }
}

// ── Cover cards ───────────────────────────────────────────────────────────

class _ClassicCoverCard extends StatelessWidget {
  const _ClassicCoverCard({
    required this.book,
    this.page,
    this.total,
  });

  final ClassicBook book;
  final int? page;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final progress = (page != null && total != null && total! > 0)
        ? (page! + 1) / total!
        : null;
    return GestureDetector(
      onTap: () => context.push(
        '${Routes.reader}?book=${Uri.encodeComponent(book.id)}',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.rMd),
                  child: Image.asset(book.cover, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _colorForLevel(book.level).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: En(
                      book.level,
                      style: AppTypography.en(
                        fontSize: 11,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            GradientProgressBar(value: progress, height: 4),
          ],
        ],
      ),
    );
  }
}

class _ReaderCoverCard extends StatelessWidget {
  const _ReaderCoverCard({
    required this.book,
    this.page,
    this.total,
  });

  final BookMeta book;
  final int? page;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final progress = (page != null && total != null && total! > 0)
        ? (page! + 1) / total!
        : null;
    return GestureDetector(
      onTap: () => context.push(
        '${Routes.reader}?book=${Uri.encodeComponent(book.id)}',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.rMd),
                  child: book.cover != null
                      ? Image.asset(book.cover!, fit: BoxFit.cover)
                      : const ColoredBox(color: AppColors.night2),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _colorForLevel(book.level).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: En(
                      book.level,
                      style: AppTypography.en(
                        fontSize: 11,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            GradientProgressBar(value: progress, height: 4),
          ],
        ],
      ),
    );
  }
}
