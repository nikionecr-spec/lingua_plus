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

/// Library tab: header, "continue reading" rail (first 3 states) and a
/// grid of all bilingual books with per-book progress.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                child: SectionHeader(title: 'همه کتاب‌ها'),
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
                  childAspectRatio: 0.78,
                ),
                itemCount: kLibraryBooks.length,
                itemBuilder: (context, index) {
                  final book = kLibraryBooks[index];
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

  BookMeta? _bookById(String id) {
    for (final book in kLibraryBooks) {
      if (book.id == id) return book;
    }
    return null;
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

/// Horizontal "continue reading" card with a progress bar.
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: AppDimensions.sm),
            Text(
              book.titleFa,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            En(
              book.titleEn,
              style: AppTypography.en(
                fontSize: 10.5,
                weight: FontWeight.w500,
                color: muted,
              ),
            ),
            const Spacer(),
            GradientProgressBar(
              value: total > 0 ? page / total : 0,
              height: 6,
            ),
            const SizedBox(height: 6),
            Text(
              'صفحه ${page + 1} از $total',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid tile for one book: emoji, titles, page count, progress.
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
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        children: [
          Text(book.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppDimensions.sm),
          Text(
            book.titleFa,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          En(
            book.titleEn,
            textAlign: TextAlign.center,
            style: AppTypography.en(
              fontSize: 11,
              weight: FontWeight.w500,
              color: muted,
            ),
          ),
          const Spacer(),
          Text(
            '${book.pages.length} صفحه',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: AppDimensions.sm),
          GradientProgressBar(value: progress, height: 6),
        ],
      ),
    );
  }
}
