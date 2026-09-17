import 'package:isar/isar.dart';

part 'favorite_word.g.dart';

/// A word saved by the user (starred).
@Collection(accessor: 'favoriteWords')
class FavoriteWord {
  FavoriteWord();

  Id id = Isar.autoIncrement;

  @Index(replace: true, unique: true)
  String word = '';

  int addedAt = 0;
}

/// One entry of search history (unique per query, refreshed on re-search).
@Collection(accessor: 'searchLogs')
class SearchLog {
  SearchLog();

  Id id = Isar.autoIncrement;

  @Index(replace: true, unique: true)
  String query = '';

  int searchedAt = 0;
}
