import 'package:isar/isar.dart';

import '../../../domain/entities/word_entity.dart';
import '../../models/favorite_word.dart';
import '../../models/mappers.dart';
import '../../models/word_entry.dart';

/// Local dictionary data source: 4-stage search engine, favorites,
/// search history and word-of-the-day.
class DictionaryLocalDs {
  DictionaryLocalDs(this.isar);

  final Isar isar;

  // ── Search ────────────────────────────────────────────────────────────

  /// Multi-stage search:
  /// 1. exact match (indexed, lowercase)
  /// 2. prefix match (indexed where-clause, ranked)
  /// 3. substring match (filter)
  /// 4. Persian substring match over denormalized [WordRow.searchText]
  /// Results are deduped by id and capped to [limit].
  Future<List<WordRow>> searchRaw(String query, {int limit = 60}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return <WordRow>[];

    final out = <int, WordRow>{};

    // 1) exact
    final exact = await isar.wordRows
        .where()
        .wordEqualTo(q)
        .limit(limit)
        .findAll();
    for (final r in exact) {
      out[r.id] = r;
    }

    // 2) prefix (indexed) — most common path.
    // Stored words are lowercase and `q` is lowercased, so the default
    // case-sensitive index scan is correct here.
    if (out.length < limit) {
      final prefix = await isar.wordRows
          .where()
          .wordStartsWith(q)
          .sortByRank()
          .limit(limit)
          .findAll();
      for (final r in prefix) {
        out[r.id] = r;
      }
    }

    // 3) contains (filter scan)
    if (out.length < limit) {
      final contains = await isar.wordRows
          .filter()
          .wordContains(q, caseSensitive: false)
          .sortByRank()
          .limit(limit)
          .findAll();
      for (final r in contains) {
        out[r.id] = r;
      }
    }

    // 4) Persian / full-text substring
    if (out.length < limit) {
      final persian = await isar.wordRows
          .filter()
          .searchTextContains(q, caseSensitive: false)
          .sortByRank()
          .limit(limit)
          .findAll();
      for (final r in persian) {
        out[r.id] = r;
      }
    }

    final rows = out.values.toList()..sort(byRank);
    return rows.take(limit).toList();
  }

  /// Search returning UI entities (favorites resolved).
  Future<List<WordEntity>> search(String query, {int limit = 60}) async {
    final rows = await searchRaw(query, limit: limit);
    final favs = await favoriteWordsSet();
    return rows
        .map((r) => wordEntityFromRow(r, isFavorite: favs.contains(r.word)))
        .toList();
  }

  /// Exact single word lookup.
  Future<WordEntity?> getWord(String word) async {
    final q = word.trim().toLowerCase();
    if (q.isEmpty) return null;
    final row = await isar.wordRows.where().wordEqualTo(q).findFirst();
    if (row == null) return null;
    final fav = await isFavorite(row.word);
    return wordEntityFromRow(row, isFavorite: fav);
  }

  /// Word of the day — deterministic per calendar day over top-ranked words.
  Future<WordEntity?> wordOfTheDay() async {
    final total = await isar.wordRows.count();
    if (total == 0) return null;
    final daySeed = DateTime.now().toUtc().difference(
          DateTime.utc(2024, 1, 1),
        ).inDays;
    final pool = await isar.wordRows
        .where()
        .sortByRank()
        .limit(total < 3000 ? total : 3000)
        .findAll();
    if (pool.isEmpty) return null;
    final row = pool[daySeed % pool.length];
    final fav = await isFavorite(row.word);
    return wordEntityFromRow(row, isFavorite: fav);
  }

  // ── Favorites ─────────────────────────────────────────────────────────

  Future<Set<String>> favoriteWordsSet() async {
    final list = await isar.favoriteWords.where().findAll();
    return list.map((f) => f.word).toSet();
  }

  Future<bool> isFavorite(String word) async {
    final q = word.toLowerCase();
    final hit = await isar.favoriteWords.where().wordEqualTo(q).findFirst();
    return hit != null;
  }

  /// Toggles favorite state; returns the NEW state (true = now favorite).
  Future<bool> toggleFavorite(String word) async {
    final q = word.toLowerCase();
    final hit =
        await isar.favoriteWords.where().wordEqualTo(q).findFirst();
    if (hit != null) {
      await isar.favoriteWords.delete(hit.id);
      return false;
    }
    final fav = FavoriteWord()
      ..word = q
      ..addedAt = DateTime.now().millisecondsSinceEpoch;
    await isar.favoriteWords.put(fav);
    return true;
  }

  Future<List<WordEntity>> favorites() async {
    final favs =
        await isar.favoriteWords.where().sortByAddedAtDesc().findAll();
    if (favs.isEmpty) return <WordEntity>[];
    final out = <WordEntity>[];
    for (final f in favs) {
      final row =
          await isar.wordRows.where().wordEqualTo(f.word).findFirst();
      if (row != null) {
        out.add(wordEntityFromRow(row, isFavorite: true));
      }
    }
    return out;
  }

  // ── Search history ────────────────────────────────────────────────────

  Future<void> logSearch(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;
    final log = SearchLog()
      ..query = q
      ..searchedAt = DateTime.now().millisecondsSinceEpoch;
    await isar.searchLogs.put(log);
  }

  Future<List<String>> recentSearches({int limit = 12}) async {
    final logs =
        await isar.searchLogs.where().sortBySearchedAtDesc().findAll();
    return logs.take(limit).map((l) => l.query).toList();
  }

  Future<void> clearHistory() async {
    await isar.searchLogs.where().deleteAll();
  }

  // ── helpers ───────────────────────────────────────────────────────────

  static int byRank(WordRow a, WordRow b) {
    if (a.rank == b.rank) return a.word.compareTo(b.word);
    return a.rank.compareTo(b.rank);
  }
}
