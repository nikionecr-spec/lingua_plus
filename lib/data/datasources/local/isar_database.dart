import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

import '../../models/mappers.dart';
import '../../models/word_entry.dart';
import '../../models/favorite_word.dart';
import '../../models/flashcard_state.dart';
import '../../models/library_models.dart';

/// Opens the single Isar instance used by the whole app and seeds the
/// bundled dictionary on first launch.
class IsarDatabase {
  IsarDatabase._();

  static const List<CollectionSchema<dynamic>> schemas = [
    WordRowSchema,
    FavoriteWordSchema,
    SearchLogSchema,
    FlashcardStateSchema,
    UserProfileSchema,
    BookmarkSchema,
    ReadingStateSchema,
  ];

  /// Opens Isar in the app documents directory.
  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      schemas,
      directory: dir.path,
      name: 'lingua_plus',
      inspector: false,
    );
  }

  /// Seeds [jsonText] (dictionary.json format) into an empty database.
  /// Returns the number of inserted rows (0 when already seeded).
  static Future<int> seedDictionary(Isar isar, String jsonText) async {
    final count = await isar.wordRows.count();
    if (count > 0) return 0; // already seeded

    final list = jsonDecode(jsonText) as List<dynamic>;
    final rows = <WordRow>[];
    for (final item in list) {
      rows.add(wordRowFromJson(item as Map<String, dynamic>));
    }

    const chunk = 500;
    for (var i = 0; i < rows.length; i += chunk) {
      final end = (i + chunk < rows.length) ? i + chunk : rows.length;
      await isar.wordRows.putAll(rows.sublist(i, end));
    }
    return rows.length;
  }
}
