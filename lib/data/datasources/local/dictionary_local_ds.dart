import 'package:isar/isar.dart';

import '../../../domain/entities/word_entity.dart';
import '../../models/favorite_word.dart';
import '../../models/mappers.dart';
import '../../models/word_entry.dart';

/// Local dictionary data source: 6-stage smart search engine, favorites,
/// search history and word-of-the-day.
class DictionaryLocalDs {
  DictionaryLocalDs(this.isar);

  final Isar isar;

  // ── Smart word-form normalization ─────────────────────────────────────

  /// Irregular inflections → base form (small, high-value subset).
  static const Map<String, String> _irregular = {
    'went': 'go', 'gone': 'go', 'goes': 'go', 'going': 'go',
    'was': 'be', 'were': 'be', 'been': 'be', 'being': 'be', 'am': 'be',
    'is': 'be', 'are': 'be',
    'had': 'have', 'has': 'have', 'having': 'have',
    'did': 'do', 'does': 'do', 'done': 'do', 'doing': 'do',
    'made': 'make', 'makes': 'make', 'making': 'make',
    'said': 'say', 'says': 'say', 'saying': 'say',
    'got': 'get', 'gotten': 'get', 'gets': 'get', 'getting': 'get',
    'knew': 'know', 'known': 'know', 'knows': 'know', 'knowing': 'know',
    'took': 'take', 'taken': 'take', 'takes': 'take', 'taking': 'take',
    'saw': 'see', 'seen': 'see', 'sees': 'see', 'seeing': 'see',
    'came': 'come', 'comes': 'come', 'coming': 'come',
    'thought': 'think', 'thinks': 'think', 'thinking': 'think',
    'found': 'find', 'finds': 'find', 'finding': 'find',
    'gave': 'give', 'given': 'give', 'gives': 'give', 'giving': 'give',
    'told': 'tell', 'tells': 'tell', 'telling': 'tell',
    'felt': 'feel', 'feels': 'feel', 'feeling': 'feel',
    'became': 'become', 'becomes': 'become', 'becoming': 'become',
    'left': 'leave', 'leaving': 'leave',
    'put': 'put', 'puts': 'put', 'putting': 'put',
    'meant': 'mean', 'means': 'mean', 'meaning': 'mean',
    'kept': 'keep', 'keeps': 'keep', 'keeping': 'keep',
    'let': 'let', 'lets': 'let', 'letting': 'let',
    'began': 'begin', 'begun': 'begin', 'begins': 'begin',
    'brought': 'bring', 'brings': 'bring', 'bringing': 'bring',
    'ran': 'run', 'runs': 'run', 'running': 'run',
    'wrote': 'write', 'written': 'write', 'writes': 'write',
    'writing': 'write',
    'sat': 'sit', 'sits': 'sit', 'sitting': 'sit',
    'stood': 'stand', 'stands': 'stand', 'standing': 'stand',
    'lost': 'lose', 'loses': 'lose', 'losing': 'lose',
    'paid': 'pay', 'pays': 'pay', 'paying': 'pay',
    'met': 'meet', 'meets': 'meet', 'meeting': 'meet',
    'held': 'hold', 'holds': 'hold', 'holding': 'hold',
    'spoke': 'speak', 'spoken': 'speak', 'speaks': 'speak',
    'speaking': 'speak',
    'lay': 'lie', 'lain': 'lie', 'lies': 'lie', 'lying': 'lie',
    'led': 'lead', 'leads': 'lead', 'leading': 'lead',
    'read': 'read', 'reads': 'read', 'reading': 'read',
    'grew': 'grow', 'grown': 'grow', 'grows': 'grow', 'growing': 'grow',
    'fell': 'fall', 'fallen': 'fall', 'falls': 'fall', 'falling': 'fall',
    'sent': 'send', 'sends': 'send', 'sending': 'send',
    'built': 'build', 'builds': 'build', 'building': 'build',
    'understood': 'understand', 'understands': 'understand',
    'understanding': 'understand',
    'heard': 'hear', 'hears': 'hear', 'hearing': 'hear',
    'caught': 'catch', 'catches': 'catch', 'catching': 'catch',
    'bought': 'buy', 'buys': 'buy', 'buying': 'buy',
    'flew': 'fly', 'flown': 'fly', 'flies': 'fly', 'flying': 'fly',
    'ate': 'eat', 'eaten': 'eat', 'eats': 'eat', 'eating': 'eat',
    'drank': 'drink', 'drunk': 'drink', 'drinks': 'drink',
    'drinking': 'drink',
    'sang': 'sing', 'sung': 'sing', 'sings': 'sing', 'singing': 'sing',
    'swam': 'swim', 'swum': 'swim', 'swims': 'swim', 'swimming': 'swim',
    'slept': 'sleep', 'sleeps': 'sleep', 'sleeping': 'sleep',
    'woke': 'wake', 'woken': 'wake', 'wakes': 'wake', 'waking': 'wake',
    'wore': 'wear', 'worn': 'wear', 'wears': 'wear', 'wearing': 'wear',
    'won': 'win', 'wins': 'win', 'winning': 'win',
    'beat': 'beat', 'beats': 'beat', 'beating': 'beat',
    'hid': 'hide', 'hidden': 'hide', 'hides': 'hide', 'hiding': 'hide',
    'broke': 'break', 'broken': 'break', 'breaks': 'break',
    'breaking': 'break',
    'chose': 'choose', 'chosen': 'choose', 'chooses': 'choose',
    'choosing': 'choose',
    'drove': 'drive', 'driven': 'drive', 'drives': 'drive',
    'driving': 'drive',
    'rode': 'ride', 'ridden': 'ride', 'rides': 'ride', 'riding': 'ride',
    'rose': 'rise', 'risen': 'rise', 'rises': 'rise', 'rising': 'rise',
    'sold': 'sell', 'sells': 'sell', 'selling': 'sell',
    'spent': 'spend', 'spends': 'spend', 'spending': 'spend',
    'taught': 'teach', 'teaches': 'teach', 'teaching': 'teach',
    'threw': 'throw', 'thrown': 'throw', 'throws': 'throw',
    'throwing': 'throw',
    'better': 'good', 'best': 'good', 'worse': 'bad', 'worst': 'bad',
    'men': 'man', 'women': 'woman', 'children': 'child',
    'people': 'person', 'feet': 'foot', 'teeth': 'tooth',
    'mice': 'mouse', 'geese': 'goose', 'oxen': 'ox',
    'wives': 'wife', 'lives': 'life', 'knives': 'knife',
    'leaves': 'leaf', 'wolves': 'wolf', 'shelves': 'shelf',
    'halves': 'half', 'loaves': 'loaf', 'thieves': 'thief',
    'babies': 'baby', 'cities': 'city', 'stories': 'story',
    'families': 'family', 'ladies': 'lady',
  };

  /// Candidates for [raw]: the raw word plus normalized base forms
  /// (plural / verb conjugation / irregular) when applicable.
  static List<String> baseForms(String raw) {
    final w = raw.trim().toLowerCase();
    if (w.isEmpty) return const <String>[];
    final forms = <String>{w};

    void add(String? f) {
      if (f != null && f.isNotEmpty) forms.add(f);
    }

    add(_irregular[w]);

    // Regular plural / 3rd person
    if (w.endsWith('ies') && w.length > 4) add('${w.substring(0, w.length - 3)}y');
    if (w.endsWith('es')) {
      add(w.substring(0, w.length - 2));
      if (w.endsWith('ves')) add('${w.substring(0, w.length - 3)}f');
    }
    if (w.endsWith('s') && !w.endsWith('ss') && w.length > 3) {
      add(w.substring(0, w.length - 1));
    }

    // Verb forms
    if (w.endsWith('ing') && w.length > 5) {
      final stem = w.substring(0, w.length - 3);
      add(stem);
      add('${stem}e');          // making → make
      if (stem.length >= 3 &&
          stem[stem.length - 1] == stem[stem.length - 2]) {
        add(stem.substring(0, stem.length - 1)); // running → run
      }
    }
    if (w.endsWith('ied') && w.length > 4) {
      add('${w.substring(0, w.length - 3)}y'); // carried → carry
    }
    if (w.endsWith('ed') && w.length > 4) {
      final stem = w.substring(0, w.length - 2);
      add(stem);
      add('${stem}e');          // hoped → hope
      if (stem.length >= 3 &&
          stem[stem.length - 1] == stem[stem.length - 2]) {
        add(stem.substring(0, stem.length - 1)); // stopped → stop
      }
      add(w.substring(0, w.length - 1)); // loved → love
    }

    // Comparative / superlative
    if (w.endsWith('er') && w.length > 4) add(w.substring(0, w.length - 2));
    if (w.endsWith('est') && w.length > 5) add(w.substring(0, w.length - 3));

    return forms.toList();
  }

  /// Levenshtein edit distance, capped at [max] for speed.
  static int _editDistance(String a, String b, {int max = 3}) {
    if ((a.length - b.length).abs() > max) return max + 1;
    final prev = List<int>.generate(b.length + 1, (i) => i);
    final cur = List<int>.filled(b.length + 1, 0);
    for (var i = 1; i <= a.length; i++) {
      cur[0] = i;
      var rowMin = cur[0];
      for (var j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        cur[j] = [
          prev[j] + 1,        // deletion
          cur[j - 1] + 1,     // insertion
          prev[j - 1] + cost, // substitution
        ].reduce((x, y) => x < y ? x : y);
        if (cur[j] < rowMin) rowMin = cur[j];
      }
      if (rowMin > max) return max + 1;
      for (var j = 0; j <= b.length; j++) {
        prev[j] = cur[j];
      }
    }
    return prev[b.length];
  }

  // ── Search ────────────────────────────────────────────────────────────

  /// Multi-stage SMART search:
  /// 1. exact match (indexed)
  /// 2. prefix match (indexed, ranked)
  /// 3. normalized base forms (ran → run, books → book …)
  /// 4. substring match (filter scan)
  /// 5. Persian full-text substring over [WordRow.searchText]
  /// 6. fuzzy fallback (Levenshtein ≤ 2) for typo tolerance
  /// Results are deduped by id, ranked and capped to [limit].
  Future<List<WordRow>> searchRaw(String query, {int limit = 60}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return <WordRow>[];

    final out = <int, WordRow>{};

    void addAll(List<WordRow> rows) {
      for (final r in rows) {
        if (!out.containsKey(r.id)) {
          out[r.id] = r;
        }
      }
    }

    // 1) exact
    addAll(await isar.wordRows
        .where()
        .wordEqualTo(q)
        .limit(limit)
        .findAll());

    // 2) prefix (indexed) — most common path
    if (out.length < limit) {
      addAll(await isar.wordRows
          .where()
          .wordStartsWith(q)
          .sortByRank()
          .limit(limit)
          .findAll());
    }

    // 3) smart base forms: "ran" → "go"? no — ran→run, books→book
    if (out.length < limit) {
      for (final form in baseForms(q)) {
        if (form == q) continue;
        addAll(await isar.wordRows
            .where()
            .wordEqualTo(form)
            .limit(6)
            .findAll());
      }
    }

    // 4) contains (filter scan)
    if (out.length < limit) {
      addAll(await isar.wordRows
          .filter()
          .wordContains(q, caseSensitive: false)
          .sortByRank()
          .limit(limit)
          .findAll());
    }

    // 5) Persian / full-text substring
    if (out.length < limit) {
      final hasPersian = RegExp(r'[\u0600-\u06FF]').hasMatch(q);
      if (hasPersian) {
        addAll(await isar.wordRows
            .filter()
            .searchTextContains(q, caseSensitive: false)
            .sortByRank()
            .limit(limit)
            .findAll());
      }
    }

    // 6) fuzzy typo tolerance — try base forms first, then plain q
    if (out.isEmpty) {
      final candidates = <String>{q, ...baseForms(q)};
      for (final c in candidates) {
        final fuzzy = await _fuzzy(c, limit: limit);
        addAll(fuzzy);
        if (out.isNotEmpty) break;
      }
    }

    final rows = out.values.toList()..sort(byRank);
    return rows.take(limit).toList();
  }

  /// Fuzzy match: short-list scan ordered by rank with edit distance ≤ 2.
  Future<List<WordRow>> _fuzzy(String q, {int limit = 60}) async {
    final pool = await isar.wordRows
        .where()
        .sortByRank()
        .limit(4000)
        .findAll();
    final scored = <(WordRow, int)>[];
    for (final r in pool) {
      final d = _editDistance(q, r.word, max: 2);
      if (d <= 2) scored.add((r, d));
    }
    scored.sort((a, b) {
      final byDist = a.$2.compareTo(b.$2);
      if (byDist != 0) return byDist;
      return byRank(a.$1, b.$1);
    });
    return scored.take(limit).map((s) => s.$1).toList();
  }

  /// Type-ahead suggestions (words only, ranked): exact, prefix,
  /// base forms then fuzzy — used for the suggestion strip under the
  /// search field and for "did you mean".
  Future<List<String>> suggest(String query, {int limit = 8}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const <String>[];

    final result = <String>[];
    void pushUnique(Iterable<WordRow> rows) {
      for (final r in rows) {
        if (result.length >= limit) return;
        if (!result.contains(r.word)) result.add(r.word);
      }
    }

    pushUnique(await isar.wordRows
        .where()
        .wordStartsWith(q)
        .sortByRank()
        .limit(limit)
        .findAll());
    for (final form in baseForms(q)) {
      if (form != q) {
        pushUnique(await isar.wordRows
            .where()
            .wordEqualTo(form)
            .limit(limit)
            .findAll());
      }
    }
    if (result.length < limit) {
      pushUnique(await isar.wordRows
          .filter()
          .wordContains(q, caseSensitive: false)
          .sortByRank()
          .limit(limit)
          .findAll());
    }
    if (result.isEmpty) {
      for (final form in baseForms(q)) {
        if (result.isNotEmpty) break;
        pushUnique(await _fuzzy(form, limit: limit));
      }
    }
    return result;
  }

  /// Search returning UI entities (favorites resolved).
  Future<List<WordEntity>> search(String query, {int limit = 60}) async {
    final rows = await searchRaw(query, limit: limit);
    final favs = await favoriteWordsSet();
    return rows
        .map((r) => wordEntityFromRow(r, isFavorite: favs.contains(r.word)))
        .toList();
  }

  /// Exact single word lookup (also tries normalized base forms).
  Future<WordEntity?> getWord(String word) async {
    for (final form in baseForms(word)) {
      final q = form.trim().toLowerCase();
      if (q.isEmpty) continue;
      final row = await isar.wordRows.where().wordEqualTo(q).findFirst();
      if (row != null) {
        final fav = await isFavorite(row.word);
        return wordEntityFromRow(row, isFavorite: fav);
      }
    }
    return null;
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
    return isar.writeTxn(() async {
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
    });
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
    // Keep history deduped: replace an existing identical entry.
    await isar.writeTxn(() async {
      final existing = await isar.searchLogs
          .filter()
          .queryEqualTo(q)
          .findFirst();
      if (existing != null) {
        existing.searchedAt = DateTime.now().millisecondsSinceEpoch;
        await isar.searchLogs.put(existing);
        return;
      }
      final log = SearchLog()
        ..query = q
        ..searchedAt = DateTime.now().millisecondsSinceEpoch;
      await isar.searchLogs.put(log);
    });
  }

  Future<List<String>> recentSearches({int limit = 12}) async {
    final logs =
        await isar.searchLogs.where().sortBySearchedAtDesc().findAll();
    return logs.take(limit).map((l) => l.query).toList();
  }

  Future<void> clearHistory() async {
    await isar.writeTxn(() => isar.searchLogs.where().deleteAll());
  }

  // ── helpers ───────────────────────────────────────────────────────────

  static int byRank(WordRow a, WordRow b) {
    if (a.rank == b.rank) return a.word.compareTo(b.word);
    return a.rank.compareTo(b.rank);
  }
}
