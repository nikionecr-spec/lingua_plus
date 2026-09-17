import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/local/dictionary_local_ds.dart';
import '../data/datasources/local/learning_local_ds.dart';
import '../data/datasources/local/library_local_ds.dart';
import '../data/datasources/remote/translator_remote_ds.dart';
import '../shared/services/speech_service.dart';

/// ── Core overridable providers (values injected in main bootstrap) ──────

final isarProvider = Provider<Isar>(
  (ref) => throw UnimplementedError('isarProvider must be overridden'),
);

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final appRouterProvider = Provider<GoRouter>(
  (ref) => throw UnimplementedError('appRouterProvider must be overridden'),
);

/// ── Data sources ─────────────────────────────────────────────────────────

final dictionaryDsProvider = Provider<DictionaryLocalDs>(
  (ref) => DictionaryLocalDs(ref.watch(isarProvider)),
);

final learningDsProvider = Provider<LearningLocalDs>(
  (ref) => LearningLocalDs(ref.watch(isarProvider)),
);

final libraryDsProvider = Provider<LibraryLocalDs>(
  (ref) => LibraryLocalDs(ref.watch(isarProvider)),
);

final translatorDsProvider = Provider<TranslatorRemoteDs>(
  (ref) => TranslatorRemoteDs(),
);

/// ── Speech (TTS + STT) ───────────────────────────────────────────────────

final speechProvider = Provider<SpeechService>((ref) => SpeechService());

/// ── Theme ────────────────────────────────────────────────────────────────

/// Persists ThemeMode index in SharedPreferences (0 system, 1 light, 2 dark).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final sp = ref.watch(sharedPrefsProvider);
    final idx = sp.getInt('themeMode') ?? 0;
    return (idx >= 0 && idx < ThemeMode.values.length)
        ? ThemeMode.values[idx]
        : ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPrefsProvider).setInt('themeMode', mode.index);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
