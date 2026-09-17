import 'package:isar/isar.dart';

part 'word_entry.g.dart';

/// Embedded meaning group: one part-of-speech with its definitions.
@embedded
class WordMeaning {
  WordMeaning();

  String pos = 'noun';
  List<String> definitions = [];
}

/// Embedded bilingual example.
@embedded
class WordExample {
  WordExample();

  String en = '';
  String fa = '';
}

/// A dictionary entry (Isar collection). Stored `word` is lowercase for
/// case-insensitive indexing; [display] keeps the original casing.
@Collection(accessor: 'wordRows')
class WordRow {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String word = '';

  String display = '';

  /// Primary part of speech (quick chip in lists).
  String pos = 'noun';

  List<WordMeaning> meanings = [];

  List<WordExample> examples = [];

  List<String> synonyms = [];

  List<String> antonyms = [];

  String ipaUs = '';

  String ipaUk = '';

  /// CEFR level A1..C2 (empty when unknown).
  String level = '';

  /// Frequency rank (lower = more common; 999999 = unknown).
  int rank = 999999;

  /// 'seed' (bundled) or 'kaikki' (imported full Wiktionary dump).
  String source = 'seed';

  /// Denormalized search text: word + Persian definitions + synonyms,
  /// lowercased — powers Persian substring search (stage 4).
  String searchText = '';
}
