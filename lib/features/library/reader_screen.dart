import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/data/models/library_models.dart';
import 'package:lingua_plus/features/library/library_data.dart';
import 'package:lingua_plus/features/library/library_providers.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';

/// Bilingual reader: English page (LTR) + Persian translation (RTL),
/// with TTS, page bookmarks, font-size controls and resume support.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  static const double _minFont = 16;
  static const double _maxFont = 20;
  static const int _snippetLength = 60;

  final PageController _controller = PageController();
  double _fontSize = _minFont;
  int _page = 0;
  bool _restored = false;

  BookMeta get _book {
    for (final book in kLibraryBooks) {
      if (book.id == widget.bookId) return book;
    }
    return kLibraryBooks.first;
  }

  @override
  void initState() {
    super.initState();
    _restoreLastPage();
  }

  @override
  void dispose() {
    ref.read(speechProvider).stopSpeaking();
    _controller.dispose();
    super.dispose();
  }

  /// Jump to the saved position once (0-based page index).
  Future<void> _restoreLastPage() async {
    final saved = await ref.read(lastPageProvider(widget.bookId).future);
    if (!mounted || _restored) return;
    _restored = true;
    if (saved <= 0 || saved >= _book.pages.length) return;
    if (_controller.hasClients) {
      _controller.jumpToPage(saved);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) _controller.jumpToPage(saved);
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    ref
        .read(libraryDsProvider)
        .saveReadingState(widget.bookId, page, totalPages: _book.pages.length);
    ref.invalidate(readingStatesProvider);
  }

  Future<void> _toggleBookmark() async {
    final pageText = _book.pages[_page].en;
    final snippet = pageText.length > _snippetLength
        ? pageText.substring(0, _snippetLength)
        : pageText;
    await ref
        .read(libraryDsProvider)
        .toggleBookmark(widget.bookId, _page, snippet);
    ref.invalidate(bookmarksForProvider(widget.bookId));
  }

  void _adjustFont(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(_minFont, _maxFont).toDouble();
    });
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _book.pages.length) return;
    if (_controller.hasClients) {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showBookmarksSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.rLg),
        ),
      ),
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final bookmarks =
              ref.watch(bookmarksForProvider(widget.bookId)).valueOrNull ??
                  const <Bookmark>[];
          final textTheme = Theme.of(context).textTheme;
          return SafeArea(
            top: false,
            child: bookmarks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppDimensions.xxl),
                    child: Text(
                      AppStrings.readerNoBookmarks,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppDimensions.sm),
                        child: Text(
                          AppStrings.readerBookmarks,
                          style: textTheme.titleMedium,
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.lg,
                            0,
                            AppDimensions.lg,
                            AppDimensions.lg,
                          ),
                          itemCount: bookmarks.length,
                          itemBuilder: (context, index) {
                            final bm = bookmarks[index];
                            return ListTile(
                              onTap: () {
                                Navigator.of(sheetContext).pop();
                                _goToPage(bm.page);
                              },
                              leading: En(
                                '${bm.page + 1}',
                                style: AppTypography.en(
                                  fontSize: 14,
                                  weight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: En(
                                bm.snippet,
                                style: AppTypography.en(fontSize: 13.5),
                              ),
                              subtitle: Text(
                                'صفحه ${bm.page + 1}',
                                style: textTheme.labelSmall,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                ),
                                onPressed: () {
                                  ref
                                      .read(libraryDsProvider)
                                      .removeBookmark(bm.id);
                                  ref.invalidate(
                                    bookmarksForProvider(widget.bookId),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stroke = isDark ? AppColors.strokeDark : AppColors.strokeLight;
    final bookmarks = ref.watch(bookmarksForProvider(widget.bookId));
    final markedPages =
        bookmarks.valueOrNull?.map((b) => b.page).toSet() ?? const <int>{};
    final isMarked = markedPages.contains(_page);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(_book.titleFa, style: textTheme.titleMedium),
        actions: [
          IconButton(
            tooltip: AppStrings.readerBookmark,
            onPressed: _toggleBookmark,
            color: isMarked ? AppColors.warning : null,
            icon: Icon(
              isMarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
          ),
          IconButton(
            tooltip: AppStrings.readerBookmarks,
            onPressed: _showBookmarksSheet,
            icon: const Icon(Icons.bookmarks_outlined),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: _book.pages.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final bp = _book.pages[index];
          final isLast = index == _book.pages.length - 1;
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg,
              AppDimensions.sm,
              AppDimensions.lg,
              AppDimensions.sm,
            ),
            child: GlassCard(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          En(
                            bp.en,
                            textAlign: TextAlign.center,
                            style: AppTypography.en(
                              fontSize: _fontSize,
                              weight: FontWeight.w500,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          const Divider(height: 1, thickness: 1),
                          const SizedBox(height: AppDimensions.xl),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              bp.fa,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge,
                            ),
                          ),
                          if (isLast) ...[
                            const SizedBox(height: AppDimensions.xl),
                            Text(
                              AppStrings.readerFinish,
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium!
                                  .copyWith(color: AppColors.success),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: stroke)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.sm,
            ),
            child: Row(
              children: [
                _FontButton(
                  label: 'A-',
                  isDark: isDark,
                  enabled: _fontSize > _minFont,
                  onTap: () => _adjustFont(-1),
                ),
                const Spacer(),
                En(
                  '${_page + 1} / ${_book.pages.length}',
                  style: AppTypography.en(
                    fontSize: 13,
                    weight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                _FontButton(
                  label: 'A+',
                  isDark: isDark,
                  enabled: _fontSize < _maxFont,
                  onTap: () => _adjustFont(1),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'reader_tts',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => ref
            .read(speechProvider)
            .speak(_book.pages[_page].en, lang: 'en-US'),
        child: const Icon(Icons.volume_up_rounded),
      ),
    );
  }
}

/// Small A- / A+ stepper pill for the reader font size.
class _FontButton extends StatelessWidget {
  const _FontButton({
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.enabled,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color tone = enabled
        ? AppColors.primary
        : (isDark ? AppColors.mutedDark : AppColors.mutedLight);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppDimensions.rSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.rSm),
          border: Border.all(color: tone.withValues(alpha: 0.55)),
        ),
        child: En(
          label,
          style: AppTypography.en(
            fontSize: 13,
            weight: FontWeight.w700,
            color: tone,
          ),
        ),
      ),
    );
  }
}
