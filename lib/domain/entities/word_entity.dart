import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_entity.freezed.dart';

/// One meaning group (part of speech + definitions).
@freezed
class WordMeaningData with _$WordMeaningData {
  const factory WordMeaningData({
    @Default('noun') String pos,
    @Default(<String>[]) List<String> definitions,
  }) = _WordMeaningData;
}

/// One bilingual example.
@freezed
class WordExampleData with _$WordExampleData {
  const factory WordExampleData({
    @Default('') String en,
    @Default('') String fa,
  }) = _WordExampleData;
}

/// Immutable dictionary entry exposed to the UI layer.
@freezed
class WordEntity with _$WordEntity {
  const factory WordEntity({
    @Default('') String word,
    @Default('') String display,
    @Default('noun') String pos,
    @Default(<WordMeaningData>[]) List<WordMeaningData> meanings,
    @Default(<WordExampleData>[]) List<WordExampleData> examples,
    @Default(<String>[]) List<String> synonyms,
    @Default(<String>[]) List<String> antonyms,
    @Default('') String ipaUs,
    @Default('') String ipaUk,
    @Default('') String level,
    @Default(999999) int rank,
    @Default(false) bool isFavorite,
  }) = _WordEntity;
}

/// Result of an online translation.
@freezed
class TranslationResult with _$TranslationResult {
  const factory TranslationResult({
    @Default('') String input,
    @Default('') String output,
    @Default('en') String fromLang,
    @Default('fa') String toLang,
    @Default('') String provider,
  }) = _TranslationResult;
}
