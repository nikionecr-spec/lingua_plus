import 'package:isar/isar.dart';

import '../../models/favorite_word.dart';
import '../../models/flashcard_state.dart';
import '../../models/word_entry.dart';

/// Leitner-box spaced repetition + XP / streak / badges.
class LearningLocalDs {
  LearningLocalDs(this.isar);

  final Isar isar;

  /// Per-box review intervals in days (box 1..6).
  static const List<int> intervals = [0, 1, 2, 4, 8, 16];

  // ── Flashcards / SRS ──────────────────────────────────────────────────

  /// Cards currently due (or new), sorted by dueAt then rank.
  Future<List<FlashcardState>> dueCards({int limit = 20}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final due = await isar.flashcardStates
        .filter()
        .dueAtLessThan(now)
        .limit(limit)
        .findAll();
    due.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return due;
  }

  /// Due cards enriched with their WordRow (skips orphans).
  Future<List<(FlashcardState, WordRow)>> dueCardRows({int limit = 20}) async {
    final cards = await dueCards(limit: limit);
    final out = <(FlashcardState, WordRow)>[];
    for (final c in cards) {
      final row = await isar.wordRows.where().wordEqualTo(c.word).findFirst();
      if (row != null) out.add((c, row));
    }
    return out;
  }

  /// Reviews one card: Leitner promotion/demotion + due date + XP.
  /// Returns updated state.
  Future<FlashcardState> review(String word, {required bool correct}) async {
    final q = word.toLowerCase();
    final now = DateTime.now().millisecondsSinceEpoch;
    var card =
        await isar.flashcardStates.where().wordEqualTo(q).findFirst();

    card ??= FlashcardState()
      ..word = q
      ..box = 1;

    if (correct) {
      card.box = card.box >= 6 ? 6 : card.box + 1;
      card.correct += 1;
    } else {
      card.box = 1;
      card.wrong += 1;
    }
    card.lastReview = now;
    final days = intervals[card.box - 1];
    card.dueAt = now + days * 86400000;
    await isar.flashcardStates.put(card);

    await addXp(correct ? 10 : 2);
    return card;
  }

  /// Number of cards due right now.
  Future<int> dueCount() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return isar.flashcardStates.filter().dueAtLessThan(now).count();
  }

  /// Words learned = cards with box >= 4 (stable in SRS).
  Future<int> learnedCount() async {
    return isar.flashcardStates.filter().boxGreaterThan(3).count();
  }

  /// Random word pool for quizzes (optionally filtered by CEFR level).
  Future<List<WordRow>> quizPool({int limit = 10, String? level}) async {
    const upper = 1200;
    List<WordRow> pool;
    if (level != null && level.isNotEmpty) {
      final hasLevel = await isar.wordRows
          .filter()
          .levelEqualTo(level)
          .sortByRank()
          .limit(upper)
          .findAll();
      if (hasLevel.length >= limit) {
        pool = hasLevel;
      } else {
        pool = await isar.wordRows
            .where()
            .sortByRank()
            .limit(upper)
            .findAll();
      }
    } else {
      pool = await isar.wordRows.where().sortByRank().limit(upper).findAll();
    }
    pool.shuffle();
    return pool.take(limit).toList();
  }

  // ── XP / streak / badges ──────────────────────────────────────────────

  /// Adds XP and updates the daily streak. Returns the profile.
  Future<UserProfile> addXp(int amount) async {
    final profile =
        await isar.userProfiles.where().idEqualTo(1).findFirst() ??
            UserProfile();

    profile.xp += amount;

    final now = DateTime.now();
    final today = now.year * 10000 + now.month * 100 + now.day;
    if (profile.lastActiveDay != today) {
      final yesterday = now
          .subtract(const Duration(days: 1));
      final y = yesterday.year * 10000 + yesterday.month * 100 + yesterday.day;
      profile.streak = profile.lastActiveDay == y ? profile.streak + 1 : 1;
      profile.lastActiveDay = today;
    }

    await isar.userProfiles.put(profile);
    await syncAchievements();
    return (await profileAsync())!;
  }

  Future<UserProfile?> profileAsync() async {
    return isar.userProfiles.where().idEqualTo(1).findFirst();
  }

  /// Badge rules (id + label pairs kept in UI layer; here only ids).
  static const Map<String, int> badgeXp = {
    'first_step': 10,
    'spark': 100,
    'rising': 500,
    'master': 2000,
  };

  Future<List<String>> syncAchievements() async {
    final profile = await profileAsync() ?? UserProfile();
    final learned = await learnedCount();

    final earned = <String>{...profile.badges};
    badgeXp.forEach((badge, need) {
      if (profile.xp >= need) earned.add(badge);
    });
    if (learned >= 10) earned.add('scholar');
    if (profile.streak >= 3) earned.add('on_fire');
    if (profile.streak >= 7) earned.add('unstoppable');

    if (earned.length != profile.badges.length) {
      profile.badges = earned.toList();
      await isar.userProfiles.put(profile);
    }
    return profile.badges;
  }

  /// Overall stats snapshot for home / learning hub.
  Future<LearningStats> stats() async {
    final profile = await profileAsync() ?? UserProfile();
    final totalWords = await isar.wordRows.count();
    final learned = await learnedCount();
    final due = await dueCount();
    final favCount = await isar.favoriteWords.count();
    return LearningStats(
      xp: profile.xp,
      streak: profile.streak,
      badges: profile.badges,
      totalWords: totalWords,
      learnedWords: learned,
      dueCount: due,
      favorites: favCount,
    );
  }
}

/// Snapshot of user progress.
class LearningStats {
  LearningStats({
    required this.xp,
    required this.streak,
    required this.badges,
    required this.totalWords,
    required this.learnedWords,
    required this.dueCount,
    required this.favorites,
  });

  final int xp;
  final int streak;
  final List<String> badges;
  final int totalWords;
  final int learnedWords;
  final int dueCount;
  final int favorites;
}
