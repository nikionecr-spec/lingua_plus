import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/data/datasources/local/learning_local_ds.dart';
import 'package:lingua_plus/data/models/flashcard_state.dart';
import 'package:lingua_plus/data/models/word_entry.dart';

/// Snapshot of user progress: XP, streak, badges and counters.
final statsProvider = FutureProvider<LearningStats>(
  (ref) => ref.watch(learningDsProvider).stats(),
);

/// Up to 20 due flashcards joined with their dictionary rows.
final dueCardsProvider = FutureProvider<List<(FlashcardState, WordRow)>>(
  (ref) => ref.watch(learningDsProvider).dueCardRows(limit: 20),
);
