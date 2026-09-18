import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/icons/lp_icons.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/shared/widgets/app_shell.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';
import 'package:lingua_plus/features/dictionary/dictionary_providers.dart';

/// Starred words list. Unstarring disappears instantly because
/// [toggleFavoriteWord] already invalidates [favoritesProvider].
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const LpIcon(LpIcons.chevronRight),
        ),
        title: const Text(AppStrings.favoritesTitle),
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _emptyState,
        data: (favorites) {
          if (favorites.isEmpty) return _emptyState;
          return ListView.separated(
            padding: pagePadding().copyWith(
              top: AppDimensions.sm,
              bottom: AppDimensions.xxl,
            ),
            itemCount: favorites.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.sm),
            itemBuilder: (context, index) {
              final entity = favorites[index];
              return WordTile(
                entity: entity,
                onTap: () => context.push(
                  '${Routes.wordDetail}?q=${Uri.encodeComponent(entity.word)}',
                ),
                onStar: () => toggleFavoriteWord(ref, entity.word),
                onSpeak: () => ref
                    .read(speechProvider)
                    .speak(entity.display, lang: 'en-US'),
              );
            },
          );
        },
      ),
    );
  }

  Widget get _emptyState => const EmptyState(
        icon: LpIcons.star,
        title: AppStrings.favoritesEmpty,
        subtitle: AppStrings.favoritesEmptyBody,
      );
}
