import 'package:isar/isar.dart';

part 'library_models.g.dart';

/// A bookmark inside a book (page-level).
@Collection(accessor: 'bookmarks')
class Bookmark {
  Bookmark();

  Id id = Isar.autoIncrement;

  @Index()
  String bookId = '';

  int page = 0;

  String snippet = '';

  int createdAt = 0;
}

/// Last reading position of a book (one per book).
@Collection(accessor: 'readingStates')
class ReadingState {
  ReadingState();

  Id id = Isar.autoIncrement;

  @Index(replace: true, unique: true)
  String bookId = '';

  int page = 0;

  int totalPages = 0;

  int updatedAt = 0;
}
