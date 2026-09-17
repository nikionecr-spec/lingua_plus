import 'package:isar/isar.dart';

part 'flashcard_state.g.dart';

/// Leitner-box state for one flashcard (SRS).
@Collection(accessor: 'flashcardStates')
class FlashcardState {
  FlashcardState();

  Id id = Isar.autoIncrement;

  @Index(replace: true, unique: true)
  String word = '';

  /// Leitner box 1..6.
  int box = 1;

  /// Epoch-milliseconds when the card is due again.
  int dueAt = 0;

  int correct = 0;

  int wrong = 0;

  int lastReview = 0;
}

/// Singleton user profile (id == 1): XP, streak and badges.
@Collection(accessor: 'userProfiles')
class UserProfile {
  UserProfile();

  Id id = 1;

  int xp = 0;

  int streak = 0;

  /// Last active day as yyyymmdd int (streak tracking).
  int lastActiveDay = 0;

  List<String> badges = [];
}
