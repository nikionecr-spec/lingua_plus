import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/domain/entities/word_entity.dart';
import 'package:lingua_plus/shared/widgets/app_shell.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';
import 'package:lingua_plus/features/dictionary/dictionary_providers.dart';

/// Dictionary branch screen: gradient search header + WOTD / results body.
class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyQuery(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
    ref.invalidate(searchResultsProvider);
  }

  void _searchFromChip(String query) {
    _controller.text = query;
    _applyQuery(query);
  }

  Future<void> _submitQuery(String value) async {
    await ref.read(dictionaryDsProvider).logSearch(value);
    ref.invalidate(historyProvider);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _header(isDark),
          Expanded(
            child: query.trim().isEmpty ? _idleBody() : _resultsBody(),
          ),
        ],
      ),
    );
  }

  // ── Gradient header with title, actions and the search field ────────────

  Widget _header(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.rXl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        0,
        AppDimensions.lg,
        AppDimensions.lg,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.dictionaryTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(Routes.favorites),
                  tooltip: AppStrings.favoritesTitle,
                  icon: const Icon(Icons.star_rounded, color: Colors.white),
                ),
                IconButton(
                  onPressed: () => context.push(Routes.settings),
                  tooltip: AppStrings.settingsTitle,
                  icon:
                      const Icon(Icons.settings_outlined, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: _applyQuery,
              onSubmitted: _submitQuery,
              decoration: InputDecoration(
                hintText: AppStrings.dictionaryHint,
                filled: true,
                fillColor: isDark ? AppColors.night2 : AppColors.cardLight,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Idle body: WOTD card + recent searches + hint empty-state ───────────

  Widget _idleBody() {
    final wotdAsync = ref.watch(wotdProvider);
    final historyAsync = ref.watch(historyProvider);
    return ListView(
      padding: pagePadding().copyWith(
        top: AppDimensions.md,
        bottom: AppDimensions.xxl,
      ),
      children: [
        wotdAsync.when(
          data: (wotd) =>
              wotd == null ? const SizedBox.shrink() : _wotdCard(wotd),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        historyAsync.when(
          data: (items) =>
              items.isEmpty ? const SizedBox.shrink() : _recentSection(items),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: AppDimensions.lg),
        const EmptyState(
          icon: Icons.travel_explore_rounded,
          title: AppStrings.dictionaryEmptyTitle,
          subtitle: AppStrings.dictionaryEmptyBody,
        ),
      ],
    );
  }

  Widget _wotdCard(WordEntity wotd) {
    final firstFa = _firstFaMeaning(wotd);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.lg),
      child: GlassCard(
        onTap: () => context
            .push('${Routes.wordDetail}?q=${Uri.encodeComponent(wotd.word)}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.homeWordOfDay,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  En(
                    wotd.display,
                    style: AppTypography.en(
                      fontSize: 22,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  LevelChip(level: wotd.level),
                  if (firstFa.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      firstFa,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(speechProvider).speak(wotd.word),
              icon: const Icon(Icons.volume_up_rounded),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentSection(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: AppStrings.dictionaryRecent),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: [
              for (final query in items)
                ActionChip(
                  label: En(query, style: AppTypography.en(fontSize: 13)),
                  onPressed: () => _searchFromChip(query),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Results body ────────────────────────────────────────────────────────

  Widget _resultsBody() {
    final resultsAsync = ref.watch(searchResultsProvider);
    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _noResults(),
      data: (results) {
        if (results.isEmpty) return _noResults();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.lg,
                AppDimensions.md,
                AppDimensions.lg,
                AppDimensions.sm,
              ),
              child: Text(
                '${results.length} نتیجه',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: pagePadding().copyWith(bottom: AppDimensions.xxl),
                itemCount: results.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.sm),
                itemBuilder: (context, index) {
                  final entity = results[index];
                  return WordTile(
                    entity: entity,
                    onTap: () => context.push(
                      '${Routes.wordDetail}?q=${Uri.encodeComponent(entity.word)}',
                    ),
                    onStar: () => toggleFavoriteWord(ref, entity.word),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _noResults() => const EmptyState(
        icon: Icons.search_off_rounded,
        title: AppStrings.dictionaryNoResults,
        subtitle: AppStrings.dictionaryNoResultsBody,
      );

  // ── helpers ─────────────────────────────────────────────────────────────

  static String _firstFaMeaning(WordEntity entity) {
    for (final meaning in entity.meanings) {
      for (final definition in meaning.definitions) {
        if (definition.trim().isNotEmpty) return definition;
      }
    }
    return '';
  }
}
