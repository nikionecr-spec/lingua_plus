import 'package:isar/isar.dart';

import '../../models/library_models.dart';

/// Reading positions + bookmarks for the bilingual library.
class LibraryLocalDs {
  LibraryLocalDs(this.isar);

  final Isar isar;

  // ── Reading state ─────────────────────────────────────────────────────

  Future<int> lastPage(String bookId, {int fallback = 0}) async {
    final state =
        await isar.readingStates.where().bookIdEqualTo(bookId).findFirst();
    return state?.page ?? fallback;
  }

  Future<void> saveReadingState(
    String bookId,
    int page, {
    int totalPages = 0,
  }) async {
    final state =
        await isar.readingStates.where().bookIdEqualTo(bookId).findFirst() ??
            ReadingState()
              ..bookId = bookId;
    state
      ..page = page
      ..totalPages = totalPages
      ..updatedAt = DateTime.now().millisecondsSinceEpoch;
    await isar.readingStates.put(state);
  }

  /// All reading states, most-recent first (for "continue reading").
  Future<List<ReadingState>> readingStates() async {
    return isar.readingStates.where().sortByUpdatedAtDesc().findAll();
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────

  Future<void> addBookmark(String bookId, int page, String snippet) async {
    final existing = await bookmarksFor(bookId);
    final hit = existing.where((b) => b.page == page).toList();
    if (hit.isNotEmpty) return; // one bookmark per page

    final bm = Bookmark()
      ..bookId = bookId
      ..page = page
      ..snippet = snippet
      ..createdAt = DateTime.now().millisecondsSinceEpoch;
    await isar.bookmarks.put(bm);
  }

  Future<void> removeBookmark(int id) => isar.bookmarks.delete(id);

  Future<List<Bookmark>> bookmarksFor(String bookId) async {
    return isar.bookmarks
        .filter()
        .bookIdEqualTo(bookId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// True when the page was bookmarked, false when it was un-bookmarked.
  Future<bool> toggleBookmark(String bookId, int page, String snippet) async {
    final existing = await bookmarksFor(bookId);
    final hit = existing.where((b) => b.page == page).toList();
    if (hit.isNotEmpty) {
      await isar.bookmarks.delete(hit.first.id);
      return false;
    }
    await addBookmark(bookId, page, snippet);
    return true;
  }

  Future<List<int>> bookmarkedPages(String bookId) async {
    final list = await bookmarksFor(bookId);
    return list.map((b) => b.page).toList();
  }
}
