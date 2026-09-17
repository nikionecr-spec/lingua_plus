import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/data/models/library_models.dart';

/// All reading states, most-recent first — powers "continue reading"
/// and the per-book progress bars on the library grid.
final readingStatesProvider = FutureProvider<List<ReadingState>>(
  (ref) => ref.watch(libraryDsProvider).readingStates(),
);

/// Last saved page (0-based index) of one book.
final lastPageProvider = FutureProvider.family<int, String>(
  (ref, bookId) => ref.watch(libraryDsProvider).lastPage(bookId),
);

/// All bookmarks of one book (newest first).
final bookmarksForProvider = FutureProvider.family<List<Bookmark>, String>(
  (ref, bookId) => ref.watch(libraryDsProvider).bookmarksFor(bookId),
);
