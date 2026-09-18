import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/icons/lp_icons.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/domain/entities/word_entity.dart';
import 'package:lingua_plus/shared/widgets/app_shell.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';
import 'package:lingua_plus/features/dictionary/dictionary_providers.dart';

/// Full bilingual entry: audio pronunciation (US/UK), meanings,
/// examples, thesaurus.
class WordDetailScreen extends ConsumerStatefulWidget {
  const WordDetailScreen({super.key, required this.word});

  final String word;

  @override
  ConsumerState<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends ConsumerState<WordDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Log the visited word into search history (once per screen instance).
    Future.microtask(() async {
      await ref.read(dictionaryDsProvider).logSearch(widget.word);
      ref.invalidate(historyProvider);
    });
  }

  Future<void> _toggleStar() async {
    await toggleFavoriteWord(ref, widget.word);
    ref.invalidate(wordDetailProvider(widget.word));
  }

  Future<void> _share(WordEntity entity) async {
    final ipa = entity.ipaUs.isNotEmpty ? entity.ipaUs : entity.ipaUk;
    final meaning = _firstFaMeaning(entity);
    final parts = <String>[
      entity.display,
      if (ipa.isNotEmpty) '/$ipa/',
      if (meaning.isNotEmpty) meaning,
    ];
    await Share.share('${parts.join(' — ')} (Lingua+)');
  }

  @override
  Widget build(BuildContext context) {
    final wordAsync = ref.watch(wordDetailProvider(widget.word));
    final isFavorite = wordAsync.value?.isFavorite ?? false;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const LpIcon(LpIcons.chevronRight),
        ),
        title: En(
          widget.word,
          style: AppTypography.en(fontSize: 17, weight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _toggleStar,
            tooltip: isFavorite
                ? AppStrings.removeFromFavorites
                : AppStrings.addToFavorites,
            icon: LpIcon(
              isFavorite ? LpIcons.starFilled : LpIcons.star,
              color: isFavorite ? AppColors.warning : null,
            ),
          ),
          IconButton(
            onPressed: wordAsync.value == null
                ? null
                : () => _share(wordAsync.value!),
            tooltip: AppStrings.share,
            icon: const LpIcon(LpIcons.share),
          ),
        ],
      ),
      body: wordAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _notFound(),
        data: (entity) =>
            entity == null ? _notFound() : _body(entity),
      ),
    );
  }

  Widget _body(WordEntity entity) {
    return ListView(
      padding: pagePadding().copyWith(
        top: AppDimensions.sm,
        bottom: AppDimensions.xxl,
      ),
      children: [
        _headerCard(entity),
        if (entity.meanings.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.xl),
          const SectionHeader(title: AppStrings.meanings),
          for (final meaning in entity.meanings)
            if (meaning.definitions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [PosChip(pos: meaning.pos)]),
                    const SizedBox(height: AppDimensions.xs),
                    for (final definition in meaning.definitions)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.xs,
                        ),
                        child: Text(
                          '• $definition',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
        ],
        if (entity.examples.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.sm),
          const SectionHeader(title: AppStrings.examples),
          for (final example in entity.examples)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    En(
                      example.en,
                      style: AppTypography.en(
                        fontSize: 15.5,
                        color: AppColors.textDarkMode,
                      ),
                    ),
                    if (example.fa.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        example.fa,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
        if (entity.synonyms.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.sm),
          const SectionHeader(title: AppStrings.synonyms),
          _linkChips(entity.synonyms),
        ],
        if (entity.antonyms.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.sm),
          const SectionHeader(title: AppStrings.antonyms),
          _linkChips(entity.antonyms),
        ],
      ],
    );
  }

  Widget _headerCard(WordEntity entity) {
    final hasIpa = entity.ipaUs.isNotEmpty || entity.ipaUk.isNotEmpty;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          En(
            entity.display,
            style: AppTypography.en(fontSize: 28, weight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              PosChip(pos: entity.pos),
              const SizedBox(width: AppDimensions.sm),
              LevelChip(level: entity.level),
            ],
          ),
          if (hasIpa) ...[
            const SizedBox(height: AppDimensions.md),
            IpaRow(
              label: AppStrings.pronunciationUs,
              ipa: entity.ipaUs,
              onSpeak: () => ref
                  .read(speechProvider)
                  .speak(entity.display, lang: 'en-US'),
            ),
            const SizedBox(height: AppDimensions.sm),
            IpaRow(
              label: AppStrings.pronunciationUk,
              ipa: entity.ipaUk,
              onSpeak: () => ref
                  .read(speechProvider)
                  .speak(entity.display, lang: 'en-GB'),
            ),
          ],
          const SizedBox(height: AppDimensions.md),
          // Big audible play button — the entry is always pronounceable,
          // even when an IPA row is missing.
          GradientButton(
            label: AppStrings.pronunciationPlay,
            icon: LpIcons.volumeUp,
            expanded: false,
            onPressed: () => ref
                .read(speechProvider)
                .speak(entity.display, lang: 'en-US'),
          ),
        ],
      ),
    );
  }

  Widget _linkChips(List<String> words) {
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: [
        for (final word in words)
          ActionChip(
            label: En(word, style: AppTypography.en(fontSize: 13)),
            onPressed: () => context
                .push('${Routes.wordDetail}?q=${Uri.encodeComponent(word)}'),
          ),
      ],
    );
  }

  Widget _notFound() => const EmptyState(
        icon: LpIcons.searchOff,
        title: AppStrings.dictionaryNoResults,
        subtitle: AppStrings.dictionaryNoResultsBody,
      );

  static String _firstFaMeaning(WordEntity entity) {
    for (final meaning in entity.meanings) {
      for (final definition in meaning.definitions) {
        if (definition.trim().isNotEmpty) return definition;
      }
    }
    return '';
  }
}
