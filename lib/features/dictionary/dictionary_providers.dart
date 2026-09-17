import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/domain/entities/word_entity.dart';

/// Live text of the dictionary search field.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results for the current [searchQueryProvider] value
/// (empty query → DS returns an empty list).
final searchResultsProvider = FutureProvider<List<WordEntity>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(dictionaryDsProvider).search(query);
});

/// Full entry for a single word (null → not found).
final wordDetailProvider =
    FutureProvider.family<WordEntity?, String>((ref, word) {
  return ref.watch(dictionaryDsProvider).getWord(word);
});

/// All starred words, newest first.
final favoritesProvider = FutureProvider<List<WordEntity>>((ref) {
  return ref.watch(dictionaryDsProvider).favorites();
});

/// Recent search queries, newest first.
final historyProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(dictionaryDsProvider).recentSearches();
});

/// Deterministic word-of-the-day entry (null → empty database).
final wotdProvider = FutureProvider<WordEntity?>((ref) {
  return ref.watch(dictionaryDsProvider).wordOfTheDay();
});

/// Toggles the favorite state of [word] and refreshes every provider whose
/// data depends on the favorite flag (search results, favorites, WOTD).
/// Note: screen-local providers (e.g. wordDetailProvider(word)) are
/// invalidated by the caller when needed.
Future<void> toggleFavoriteWord(WidgetRef ref, String word) async {
  await ref.read(dictionaryDsProvider).toggleFavorite(word);
  ref.invalidate(searchResultsProvider);
  ref.invalidate(favoritesProvider);
  ref.invalidate(wotdProvider);
}
