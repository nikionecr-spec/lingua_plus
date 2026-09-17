import '../../domain/entities/word_entity.dart';
import 'word_entry.dart';

/// JSON → [WordRow] (dictionary.json seed/kaikki import format).
WordRow wordRowFromJson(Map<String, dynamic> j) {
  final meanings = <WordMeaning>[];
  for (final m in (j['meanings'] as List<dynamic>? ?? <dynamic>[])) {
    final mm = m as Map<String, dynamic>;
    final group = WordMeaning()
      ..pos = (mm['pos'] as String? ?? 'noun')
      ..definitions = ((mm['definitions'] as List<dynamic>? ?? <dynamic>[]))
          .map((e) => e.toString())
          .toList();
    meanings.add(group);
  }

  final examples = <WordExample>[];
  for (final e in (j['examples'] as List<dynamic>? ?? <dynamic>[])) {
    final ee = e as Map<String, dynamic>;
    final ex = WordExample()
      ..en = (ee['en'] as String? ?? '')
      ..fa = (ee['fa'] as String? ?? '');
    examples.add(ex);
  }

  final row = WordRow()
    ..word = (j['word'] as String? ?? '').toLowerCase()
    ..display = (j['display'] as String? ?? j['word'] as String? ?? '')
    ..pos = (j['pos'] as String? ?? 'noun')
    ..meanings = meanings
    ..examples = examples
    ..synonyms = ((j['synonyms'] as List<dynamic>? ?? <dynamic>[]))
        .map((e) => e.toString())
        .toList()
    ..antonyms = ((j['antonyms'] as List<dynamic>? ?? <dynamic>[]))
        .map((e) => e.toString())
        .toList()
    ..ipaUs = (j['ipaUs'] as String? ?? '')
    ..ipaUk = (j['ipaUk'] as String? ?? '')
    ..level = (j['level'] as String? ?? '')
    ..rank = (j['rank'] as int? ?? 999999)
    ..source = (j['source'] as String? ?? 'seed');

  final sb = StringBuffer(row.word);
  for (final m in meanings) {
    for (final d in m.definitions) {
      sb.write(' | ');
      sb.write(d);
    }
  }
  for (final s in row.synonyms) {
    sb.write(' | ');
    sb.write(s);
  }
  row.searchText = sb.toString().toLowerCase();
  return row;
}

/// [WordRow] → [WordEntity] for the UI layer.
WordEntity wordEntityFromRow(WordRow row, {bool isFavorite = false}) {
  return WordEntity(
    word: row.word,
    display: row.display,
    pos: row.pos,
    meanings: row.meanings
        .map(
          (m) => WordMeaningData(pos: m.pos, definitions: m.definitions),
        )
        .toList(),
    examples: row.examples
        .map((e) => WordExampleData(en: e.en, fa: e.fa))
        .toList(),
    synonyms: row.synonyms.toList(),
    antonyms: row.antonyms.toList(),
    ipaUs: row.ipaUs,
    ipaUk: row.ipaUk,
    level: row.level,
    rank: row.rank,
    isFavorite: isFavorite,
  );
}
