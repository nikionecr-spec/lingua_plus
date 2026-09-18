import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/mappers.dart';
import '../../models/word_entry.dart';
import '../../models/favorite_word.dart';
import '../../models/library_models.dart';

/// Opens the single Isar instance used by the whole app and seeds the
/// bundled dictionary on first launch.
class IsarDatabase {
  IsarDatabase._();

  static const List<CollectionSchema<dynamic>> schemas = [
    WordRowSchema,
    FavoriteWordSchema,
    SearchLogSchema,
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

  /// Bundled-dictionary version. Bump whenever assets/data/dictionary.json
  /// changes materially, so existing installs re-seed on first launch.
  static const int kDictionarySeedVersion = 3;

  /// Seeds [jsonText] (dictionary.json format) into an empty database, or
  /// re-seeds when the stored seed version differs from [version].
  /// Returns the number of inserted rows (0 when already up to date).
  static Future<int> seedDictionary(
    Isar isar,
    String jsonText,
    SharedPreferences sp, {
    int version = kDictionarySeedVersion,
  }) async {
    final stored = sp.getInt('dictSeedVersion') ?? 0;
    final count = await isar.wordRows.count();
    if (count > 0 && stored == version) return 0; // up to date

    if (count > 0) {
      // Older bundled dictionary: replace it wholesale, keep user data.
      await isar.writeTxn(() => isar.wordRows.clear());
    }

    final list = jsonDecode(jsonText) as List<dynamic>;
    final rows = <WordRow>[];
    for (final item in list) {
      rows.add(wordRowFromJson(item as Map<String, dynamic>));
    }

    // ⚠️ Isar 3.x requires an explicit write transaction for EVERY write.
    // Previously putAll ran outside writeTxn → IsarError → the whole seed
    // failed silently and the dictionary stayed empty on every device.
    const chunk = 500;
    for (var i = 0; i < rows.length; i += chunk) {
      final end = (i + chunk < rows.length) ? i + chunk : rows.length;
      final chunkRows = rows.sublist(i, end);
      await isar.writeTxn(() async {
        await isar.wordRows.putAll(chunkRows);
      });
    }
    await sp.setInt('dictSeedVersion', version);
    return rows.length;
  }
}
