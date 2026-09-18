import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/icons/lp_icons.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/features/library/classics.dart';
import 'package:lingua_plus/features/library/library_data.dart';
import 'package:lingua_plus/features/library/library_providers.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';
import 'package:lingua_plus/features/dictionary/dictionary_providers.dart';
import 'package:go_router/go_router.dart';

/// One rendered paragraph inside a classic page.
class _Para {
  const _Para(this.text, {this.isChapterTitle = false});
  final String text;
  final bool isChapterTitle;
}

/// A single page. Bilingual books carry en+fa; classics carry paragraphs.
class _RPage {
  _RPage({this.en, this.fa, required this.paras});
  final String? en; // bilingual English text
  final String? fa; // bilingual Persian text
  final List<_Para> paras; // classic paragraphs
}

final _chapterRe = RegExp(
  r'^\s*(CHAPTER|Chapter|STAVE|PART|ACT|SCENE|LETTER|VOLUME)\s+([IVXLCDM]+|\d+|\w+)',
);

/// Unified reader for both the graded bilingual stories and the
/// Gutenberg classics. Classics support tap-a-word lookup with audio,
/// full-page translation and per-page TTS.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  static const double _minFont = 16;
  static const double _maxFont = 22;
  static const int _snippetLength = 60;
  static const int _pageTargetChars = 1500;

  final PageController _controller = PageController();
  double _fontSize = _minFont;
  int _page = 0;
  bool _restored = false;

  BookMeta? _book;
  ClassicBook? _classic;
  List<_RPage> _pages = const <_RPage>[];
  bool _loadingText = true;

  /// Per-page cached Persian translation (classic mode).
  final Map<int, String> _translations = <int, String>{};
  bool _translating = false;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _resolveBook();
  }

  @override
  void dispose() {
    ref.read(speechProvider).stopSpeaking();
    _controller.dispose();
    super.dispose();
  }

  void _resolveBook() {
    for (final b in kLibraryBooks) {
      if (b.id == widget.bookId) _book = b;
    }
    for (final c in kClassicBooks) {
      if (c.id == widget.bookId) _classic = c;
    }
    if (_book != null) {
      _pages = _book!.pages
          .map((p) => _RPage(en: p.en, fa: p.fa, paras: const <_Para>[]))
          .toList();
      setState(() => _loadingText = false);
      _restoreLastPage();
    } else if (_classic != null) {
      _loadClassic();
    } else {
      setState(() => _loadingText = false);
    }
  }

  Future<void> _loadClassic() async {
    try {
      final raw = await rootBundle.loadString(_classic!.asset);
      final pages = _paginate(raw);
      if (!mounted) return;
      setState(() {
        _pages = pages;
        _loadingText = false;
      });
      _restoreLastPage();
    } catch (_) {
      if (mounted) setState(() => _loadingText = false);
    }
  }

  /// Gutenberg text → chapters → pages (~1.5 KB of text per page).
  List<_RPage> _paginate(String raw) {
    final lines = raw.split('\n');
    final chapters = <List<_Para>>[<_Para>[]]; // front matter first
    var buf = StringBuffer();

    void flushPara({bool isTitle = false}) {
      final t = buf.toString().trim();
      buf = StringBuffer();
      if (t.isNotEmpty) {
        if (isTitle || _chapterRe.hasMatch(t)) {
          chapters.add(<_Para>[]);
          chapters.last.add(_Para(t, isChapterTitle: true));
        } else {
          chapters.last.add(_Para(t));
        }
      }
    }

    var blankRun = true;
    for (final line in lines) {
      final l = line.trim();
      if (l.isEmpty) {
        if (!blankRun) flushPara();
        blankRun = true;
      } else {
        blankRun = false;
        buf.write(l.isEmpty ? '' : '$l ');
      }
    }
    flushPara();

    // Drop empty leading chapter (no front matter case).
    if (chapters.length > 1 && chapters.first.isEmpty) {
      chapters.removeAt(0);
    }

    final pages = <_RPage>[];
    for (final chapter in chapters) {
      var cur = <_Para>[];
      var chars = 0;
      for (final para in chapter) {
        final isBig = para.isChapterTitle || chars >= _pageTargetChars;
        if (cur.isNotEmpty && isBig) {
          pages.add(_RPage(paras: cur));
          cur = <_Para>[];
          chars = 0;
        }
        cur.add(para);
        chars += para.text.length;
      }
      if (cur.isNotEmpty) pages.add(_RPage(paras: cur));
    }
    return pages;
  }

  // ── Reading state / bookmarks ─────────────────────────────────────────

  Future<void> _restoreLastPage() async {
    final saved = await ref.read(lastPageProvider(widget.bookId).future);
    if (!mounted || _restored) return;
    _restored = true;
    if (saved <= 0 || _pages.isEmpty || saved >= _pages.length) return;
    if (_controller.hasClients) {
      _controller.jumpToPage(saved);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) _controller.jumpToPage(saved);
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _page = page;
      _showTranslation = false;
    });
    ref.read(libraryDsProvider).saveReadingState(
          widget.bookId,
          page,
          totalPages: _pages.length,
        );
    ref.invalidate(readingStatesProvider);
  }

  Future<void> _toggleBookmark() async {
    final pageText = _currentPageText();
    final snippet = pageText.length > _snippetLength
        ? pageText.substring(0, _snippetLength)
        : pageText;
    await ref
        .read(libraryDsProvider)
        .toggleBookmark(widget.bookId, _page, snippet);
    ref.invalidate(bookmarksForProvider(widget.bookId));
  }

  String _currentPageText() {
    if (_page >= _pages.length) return '';
    final p = _pages[_page];
    if (p.en != null) return p.en!;
    return p.paras.map((x) => x.text).join(' ');
  }

  void _adjustFont(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(_minFont, _maxFont).toDouble();
    });
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _pages.length) return;
    if (_controller.hasClients) {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ── Page translation (online, free APIs) ──────────────────────────────

  Future<void> _toggleTranslation() async {
    if (_showTranslation) {
      setState(() => _showTranslation = false);
      return;
    }
    if (_translations.containsKey(_page)) {
      setState(() => _showTranslation = true);
      return;
    }
    final text = _currentPageText();
    if (text.trim().isEmpty) return;
    setState(() => _translating = true);
    try {
      final res = await ref
          .read(translatorDsProvider)
          .translate(text, from: 'en', to: 'fa');
      _translations[_page] = res.output;
      if (mounted) setState(() => _showTranslation = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.readerTranslateOffline)),
        );
      }
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  // ── Word popup ────────────────────────────────────────────────────────

  static final _wordTokenRe = RegExp(r"[A-Za-zÀ-ÿ']+", multiLine: true);

  void _onWordTap(String raw) {
    final match = _wordTokenRe.allMatches(raw).toList();
    final word = match.isEmpty
        ? raw.trim()
        : match.first.group(0) ?? raw.trim();
    if (word.isEmpty) return;
    ref.read(speechProvider).stopSpeaking();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.cardDark
          : AppColors.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.rLg),
        ),
      ),
      builder: (_) => _WordPopup(word: word),
    );
  }

  // ── Bookmarks sheet ───────────────────────────────────────────────────

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
                                icon: const LpIcon(LpIcons.trash, size: 20),
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

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stroke = isDark ? AppColors.strokeDark : AppColors.strokeLight;
    final title = _book?.titleFa ?? _classic?.titleFa ?? widget.bookId;

    final bookmarks = ref.watch(bookmarksForProvider(widget.bookId));
    final markedPages =
        bookmarks.valueOrNull?.map((b) => b.page).toSet() ?? const <int>{};
    final isMarked = markedPages.contains(_page);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const LpIcon(LpIcons.chevronRight),
        ),
        centerTitle: true,
        title: Text(title, style: textTheme.titleMedium),
        actions: [
          if (_classic != null)
            IconButton(
              tooltip: _showTranslation
                  ? AppStrings.readerHideTranslation
                  : AppStrings.readerTranslatePage,
              onPressed: _translating ? null : _toggleTranslation,
              icon: _translating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const LpIcon(LpIcons.translator),
            ),
          IconButton(
            tooltip: AppStrings.readerBookmark,
            onPressed: _toggleBookmark,
            color: isMarked ? AppColors.warning : null,
            icon: LpIcon(
              isMarked ? LpIcons.bookmarkFilled : LpIcons.bookmark,
            ),
          ),
          IconButton(
            tooltip: AppStrings.readerBookmarks,
            onPressed: _showBookmarksSheet,
            icon: const LpIcon(LpIcons.clock),
          ),
        ],
      ),
      body: _loadingText
          ? const Center(child: CircularProgressIndicator())
          : _pages.isEmpty
              ? const EmptyState(
                  icon: LpIcons.alert,
                  title: AppStrings.errorGeneric,
                  subtitle: '',
                )
              : PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final bp = _pages[index];
                    final isLast = index == _pages.length - 1;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.lg,
                        AppDimensions.sm,
                        AppDimensions.lg,
                        AppDimensions.sm,
                      ),
                      child: GlassCard(
                        padding:
                            const EdgeInsets.all(AppDimensions.xl),
                        child: _classic == null
                            ? _bilingualPage(bp, isLast, textTheme)
                            : _classicPage(bp, isLast, textTheme),
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
                  '${_page + 1} / ${_pages.isEmpty ? 1 : _pages.length}',
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
        onPressed: () {
          final text = _currentPageText();
          if (text.isNotEmpty) {
            ref.read(speechProvider).speak(text, lang: 'en-US');
          }
        },
        child: const LpIcon(LpIcons.volumeUp, color: Colors.white),
      ),
    );
  }

  Widget _bilingualPage(_RPage bp, bool isLast, TextTheme textTheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          En(
            bp.en ?? '',
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
              bp.fa ?? '',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
          ),
          if (isLast) ...[
            const SizedBox(height: AppDimensions.xl),
            Text(
              AppStrings.readerFinish,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium!.copyWith(color: AppColors.success),
            ),
          ],
        ],
      ),
    );
  }

  Widget _classicPage(_RPage bp, bool isLast, TextTheme textTheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final para in bp.paras) ...[
            if (para.isChapterTitle)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.lg,
                  top: AppDimensions.md,
                ),
                child: Column(
                  children: [
                    En(
                      para.text,
                      textAlign: TextAlign.center,
                      style: AppTypography.en(
                        fontSize: _fontSize + 3,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Container(
                      width: 56,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: _TappableParagraph(
                  text: para.text,
                  fontSize: _fontSize,
                  onWord: _onWordTap,
                ),
              ),
          ],
          if (isLast) ...[
            const SizedBox(height: AppDimensions.lg),
            Text(
              AppStrings.readerFinish,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium!.copyWith(color: AppColors.success),
            ),
          ],
          if (_showTranslation &&
              _translations[_page] != null) ...[
            const SizedBox(height: AppDimensions.lg),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: AppDimensions.lg),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                _translations[_page]!,
                textAlign: TextAlign.start,
                style: textTheme.bodyLarge!.copyWith(height: 1.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// English paragraph where every word is tappable (dictionary popup).
class _TappableParagraph extends StatefulWidget {
  const _TappableParagraph({
    required this.text,
    required this.fontSize,
    required this.onWord,
  });

  final String text;
  final double fontSize;
  final void Function(String word) onWord;

  @override
  State<_TappableParagraph> createState() => _TappableParagraphState();
}

class _TappableParagraphState extends State<_TappableParagraph> {
  final Map<String, TapGestureRecognizer> _recognizers = {};

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _recognizer(String word) {
    final existing = _recognizers[word];
    if (existing != null) return existing;
    final rec = TapGestureRecognizer()
      ..onTap = () => widget.onWord(word);
    _recognizers[word] = rec;
    return rec;
  }

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r"([A-Za-zÀ-ÿ']+|[^A-Za-zÀ-ÿ']+)");

    for (final token in pattern.allMatches(widget.text)) {
      final t = token.group(0)!;
      final isWord = RegExp(r"^[A-Za-zÀ-ÿ']+$").hasMatch(t);
      spans.add(
        TextSpan(
          text: t,
          recognizer: isWord ? _recognizer(t) : null,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: spans,
        style: AppTypography.en(
          fontSize: widget.fontSize,
          weight: FontWeight.w500,
          height: 1.75,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      textAlign: TextAlign.start,
    );
  }
}

/// Bottom sheet shown when a reader word is tapped: meanings + audio.
class _WordPopup extends ConsumerStatefulWidget {
  const _WordPopup({required this.word});

  final String word;

  @override
  ConsumerState<_WordPopup> createState() => _WordPopupState();
}

class _WordPopupState extends ConsumerState<_WordPopup> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final async = ref.watch(wordDetailProvider(widget.word.toLowerCase()));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.lg,
          AppDimensions.sm,
          AppDimensions.lg,
          AppDimensions.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: En(
                    widget.word,
                    style: AppTypography.en(
                      fontSize: 24,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => ref
                      .read(speechProvider)
                      .speak(widget.word, lang: 'en-US'),
                  tooltip: AppStrings.pronunciationPlay,
                  icon: const LpIcon(LpIcons.volumeUp),
                  color: AppColors.primary,
                ),
                IconButton(
                  onPressed: () => ref
                      .read(speechProvider)
                      .speak(widget.word, lang: 'en-GB'),
                  tooltip: AppStrings.pronunciationUk,
                  icon: const LpIcon(LpIcons.volume, size: 22),
                  color: AppColors.info,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppDimensions.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => _notInDict(textTheme),
              data: (entity) {
                if (entity == null) return _notInDict(textTheme);
                final ipa = <Widget>[
                  if (entity.ipaUs.isNotEmpty)
                    IpaRow(
                      label: AppStrings.pronunciationUs,
                      ipa: entity.ipaUs,
                      onSpeak: () => ref
                          .read(speechProvider)
                          .speak(entity.display, lang: 'en-US'),
                    ),
                  if (entity.ipaUk.isNotEmpty)
                    IpaRow(
                      label: AppStrings.pronunciationUk,
                      ipa: entity.ipaUk,
                      onSpeak: () => ref
                          .read(speechProvider)
                          .speak(entity.display, lang: 'en-GB'),
                    ),
                ];
                final meanings = <Widget>[];
                var shown = 0;
                for (final m in entity.meanings) {
                  for (final d in m.definitions) {
                    if (shown >= 3) break;
                    meanings.add(
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppDimensions.xs),
                        child: Text('• $d', style: textTheme.bodyMedium),
                      ),
                    );
                    shown++;
                  }
                  if (shown >= 3) break;
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppDimensions.sm,
                      runSpacing: AppDimensions.sm,
                      children: [
                        PosChip(pos: entity.pos),
                        LevelChip(level: entity.level),
                      ],
                    ),
                    if (ipa.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.sm),
                      ...ipa,
                    ],
                    if (meanings.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.md),
                      ...meanings,
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppDimensions.md),
            GradientButton(
              label: AppStrings.popupSeeFull,
              icon: LpIcons.dictionary,
              onPressed: () {
                Navigator.of(context).pop();
                context.push(
                  '${Routes.wordDetail}?q=${Uri.encodeComponent(widget.word)}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _notInDict(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.dictionaryNoResults,
          style: textTheme.bodyMedium,
        ),
        Text(
          AppStrings.dictionaryNoResultsBody,
          style: textTheme.bodySmall,
        ),
      ],
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
