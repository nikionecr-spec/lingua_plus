import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers.dart';
import '../../domain/entities/word_entity.dart';

/// Source text typed by the user.
final sourceTextProvider = StateProvider<String>((ref) => '');

/// Source language — null means auto-detect.
final sourceLangProvider = StateProvider<String?>((ref) => null);

/// Target language ('fa' or 'en').
final targetLangProvider = StateProvider<String>((ref) => 'fa');

/// UI state of the translation flow.
class TranslationUiState {
  const TranslationUiState({
    this.status = 'idle', // idle | loading | success | error
    this.result,
    this.error,
  });

  final String status;
  final TranslationResult? result;
  final String? error;

  TranslationUiState copyWith({
    String? status,
    TranslationResult? result,
    String? error,
  }) {
    return TranslationUiState(
      status: status ?? this.status,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

class TranslatorNotifier extends Notifier<TranslationUiState> {
  @override
  TranslationUiState build() => const TranslationUiState();

  Future<void> translateNow() async {
    final text = ref.read(sourceTextProvider).trim();
    if (text.isEmpty) {
      state = const TranslationUiState(
        status: 'error',
        error: AppStrings.translatorEmptyInput,
      );
      return;
    }

    state = const TranslationUiState(status: 'loading');
    try {
      final res = await ref.read(translatorDsProvider).translate(
            text,
            from: ref.read(sourceLangProvider),
            to: ref.read(targetLangProvider),
          );
      state = TranslationUiState(status: 'success', result: res);
    } on Exception {
      state = const TranslationUiState(
        status: 'error',
        error: AppStrings.translatorError,
      );
    }
  }

  void reset() {
    state = const TranslationUiState();
  }
}

final translatorStateProvider =
    NotifierProvider<TranslatorNotifier, TranslationUiState>(
  TranslatorNotifier.new,
);

/// Swaps source/target languages (auto becomes 'en').
void swapLanguages(WidgetRef ref) {
  final src = ref.read(sourceLangProvider);
  final tgt = ref.read(targetLangProvider);
  ref.read(sourceLangProvider.notifier).state =
      src == null ? 'en' : tgt;
  ref.read(targetLangProvider.notifier).state = src ?? 'en';
  ref.read(translatorStateProvider.notifier).reset();
}
