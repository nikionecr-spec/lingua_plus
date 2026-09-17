// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WordMeaningData {
  String get pos => throw _privateConstructorUsedError;
  List<String> get definitions => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WordMeaningDataCopyWith<WordMeaningData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordMeaningDataCopyWith<$Res> {
  factory $WordMeaningDataCopyWith(
          WordMeaningData value, $Res Function(WordMeaningData) then) =
      _$WordMeaningDataCopyWithImpl<$Res, WordMeaningData>;
  @useResult
  $Res call({String pos, List<String> definitions});
}

/// @nodoc
class _$WordMeaningDataCopyWithImpl<$Res, $Val extends WordMeaningData>
    implements $WordMeaningDataCopyWith<$Res> {
  _$WordMeaningDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pos = null,
    Object? definitions = null,
  }) {
    return _then(_value.copyWith(
      pos: null == pos
          ? _value.pos
          : pos // ignore: cast_nullable_to_non_nullable
              as String,
      definitions: null == definitions
          ? _value.definitions
          : definitions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WordMeaningDataImplCopyWith<$Res>
    implements $WordMeaningDataCopyWith<$Res> {
  factory _$$WordMeaningDataImplCopyWith(_$WordMeaningDataImpl value,
          $Res Function(_$WordMeaningDataImpl) then) =
      __$$WordMeaningDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String pos, List<String> definitions});
}

/// @nodoc
class __$$WordMeaningDataImplCopyWithImpl<$Res>
    extends _$WordMeaningDataCopyWithImpl<$Res, _$WordMeaningDataImpl>
    implements _$$WordMeaningDataImplCopyWith<$Res> {
  __$$WordMeaningDataImplCopyWithImpl(
      _$WordMeaningDataImpl _value, $Res Function(_$WordMeaningDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pos = null,
    Object? definitions = null,
  }) {
    return _then(_$WordMeaningDataImpl(
      pos: null == pos
          ? _value.pos
          : pos // ignore: cast_nullable_to_non_nullable
              as String,
      definitions: null == definitions
          ? _value._definitions
          : definitions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$WordMeaningDataImpl implements _WordMeaningData {
  const _$WordMeaningDataImpl(
      {this.pos = 'noun', final List<String> definitions = const <String>[]})
      : _definitions = definitions;

  @override
  @JsonKey()
  final String pos;
  final List<String> _definitions;
  @override
  @JsonKey()
  List<String> get definitions {
    if (_definitions is EqualUnmodifiableListView) return _definitions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_definitions);
  }

  @override
  String toString() {
    return 'WordMeaningData(pos: $pos, definitions: $definitions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordMeaningDataImpl &&
            (identical(other.pos, pos) || other.pos == pos) &&
            const DeepCollectionEquality()
                .equals(other._definitions, _definitions));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, pos, const DeepCollectionEquality().hash(_definitions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WordMeaningDataImplCopyWith<_$WordMeaningDataImpl> get copyWith =>
      __$$WordMeaningDataImplCopyWithImpl<_$WordMeaningDataImpl>(
          this, _$identity);
}

abstract class _WordMeaningData implements WordMeaningData {
  const factory _WordMeaningData(
      {final String pos,
      final List<String> definitions}) = _$WordMeaningDataImpl;

  @override
  String get pos;
  @override
  List<String> get definitions;
  @override
  @JsonKey(ignore: true)
  _$$WordMeaningDataImplCopyWith<_$WordMeaningDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WordExampleData {
  String get en => throw _privateConstructorUsedError;
  String get fa => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WordExampleDataCopyWith<WordExampleData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordExampleDataCopyWith<$Res> {
  factory $WordExampleDataCopyWith(
          WordExampleData value, $Res Function(WordExampleData) then) =
      _$WordExampleDataCopyWithImpl<$Res, WordExampleData>;
  @useResult
  $Res call({String en, String fa});
}

/// @nodoc
class _$WordExampleDataCopyWithImpl<$Res, $Val extends WordExampleData>
    implements $WordExampleDataCopyWith<$Res> {
  _$WordExampleDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? en = null,
    Object? fa = null,
  }) {
    return _then(_value.copyWith(
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      fa: null == fa
          ? _value.fa
          : fa // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WordExampleDataImplCopyWith<$Res>
    implements $WordExampleDataCopyWith<$Res> {
  factory _$$WordExampleDataImplCopyWith(_$WordExampleDataImpl value,
          $Res Function(_$WordExampleDataImpl) then) =
      __$$WordExampleDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String en, String fa});
}

/// @nodoc
class __$$WordExampleDataImplCopyWithImpl<$Res>
    extends _$WordExampleDataCopyWithImpl<$Res, _$WordExampleDataImpl>
    implements _$$WordExampleDataImplCopyWith<$Res> {
  __$$WordExampleDataImplCopyWithImpl(
      _$WordExampleDataImpl _value, $Res Function(_$WordExampleDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? en = null,
    Object? fa = null,
  }) {
    return _then(_$WordExampleDataImpl(
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      fa: null == fa
          ? _value.fa
          : fa // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$WordExampleDataImpl implements _WordExampleData {
  const _$WordExampleDataImpl({this.en = '', this.fa = ''});

  @override
  @JsonKey()
  final String en;
  @override
  @JsonKey()
  final String fa;

  @override
  String toString() {
    return 'WordExampleData(en: $en, fa: $fa)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordExampleDataImpl &&
            (identical(other.en, en) || other.en == en) &&
            (identical(other.fa, fa) || other.fa == fa));
  }

  @override
  int get hashCode => Object.hash(runtimeType, en, fa);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WordExampleDataImplCopyWith<_$WordExampleDataImpl> get copyWith =>
      __$$WordExampleDataImplCopyWithImpl<_$WordExampleDataImpl>(
          this, _$identity);
}

abstract class _WordExampleData implements WordExampleData {
  const factory _WordExampleData({final String en, final String fa}) =
      _$WordExampleDataImpl;

  @override
  String get en;
  @override
  String get fa;
  @override
  @JsonKey(ignore: true)
  _$$WordExampleDataImplCopyWith<_$WordExampleDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WordEntity {
  String get word => throw _privateConstructorUsedError;
  String get display => throw _privateConstructorUsedError;
  String get pos => throw _privateConstructorUsedError;
  List<WordMeaningData> get meanings => throw _privateConstructorUsedError;
  List<WordExampleData> get examples => throw _privateConstructorUsedError;
  List<String> get synonyms => throw _privateConstructorUsedError;
  List<String> get antonyms => throw _privateConstructorUsedError;
  String get ipaUs => throw _privateConstructorUsedError;
  String get ipaUk => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WordEntityCopyWith<WordEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordEntityCopyWith<$Res> {
  factory $WordEntityCopyWith(
          WordEntity value, $Res Function(WordEntity) then) =
      _$WordEntityCopyWithImpl<$Res, WordEntity>;
  @useResult
  $Res call(
      {String word,
      String display,
      String pos,
      List<WordMeaningData> meanings,
      List<WordExampleData> examples,
      List<String> synonyms,
      List<String> antonyms,
      String ipaUs,
      String ipaUk,
      String level,
      int rank,
      bool isFavorite});
}

/// @nodoc
class _$WordEntityCopyWithImpl<$Res, $Val extends WordEntity>
    implements $WordEntityCopyWith<$Res> {
  _$WordEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? display = null,
    Object? pos = null,
    Object? meanings = null,
    Object? examples = null,
    Object? synonyms = null,
    Object? antonyms = null,
    Object? ipaUs = null,
    Object? ipaUk = null,
    Object? level = null,
    Object? rank = null,
    Object? isFavorite = null,
  }) {
    return _then(_value.copyWith(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      display: null == display
          ? _value.display
          : display // ignore: cast_nullable_to_non_nullable
              as String,
      pos: null == pos
          ? _value.pos
          : pos // ignore: cast_nullable_to_non_nullable
              as String,
      meanings: null == meanings
          ? _value.meanings
          : meanings // ignore: cast_nullable_to_non_nullable
              as List<WordMeaningData>,
      examples: null == examples
          ? _value.examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<WordExampleData>,
      synonyms: null == synonyms
          ? _value.synonyms
          : synonyms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      antonyms: null == antonyms
          ? _value.antonyms
          : antonyms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      ipaUs: null == ipaUs
          ? _value.ipaUs
          : ipaUs // ignore: cast_nullable_to_non_nullable
              as String,
      ipaUk: null == ipaUk
          ? _value.ipaUk
          : ipaUk // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WordEntityImplCopyWith<$Res>
    implements $WordEntityCopyWith<$Res> {
  factory _$$WordEntityImplCopyWith(
          _$WordEntityImpl value, $Res Function(_$WordEntityImpl) then) =
      __$$WordEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String word,
      String display,
      String pos,
      List<WordMeaningData> meanings,
      List<WordExampleData> examples,
      List<String> synonyms,
      List<String> antonyms,
      String ipaUs,
      String ipaUk,
      String level,
      int rank,
      bool isFavorite});
}

/// @nodoc
class __$$WordEntityImplCopyWithImpl<$Res>
    extends _$WordEntityCopyWithImpl<$Res, _$WordEntityImpl>
    implements _$$WordEntityImplCopyWith<$Res> {
  __$$WordEntityImplCopyWithImpl(
      _$WordEntityImpl _value, $Res Function(_$WordEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? display = null,
    Object? pos = null,
    Object? meanings = null,
    Object? examples = null,
    Object? synonyms = null,
    Object? antonyms = null,
    Object? ipaUs = null,
    Object? ipaUk = null,
    Object? level = null,
    Object? rank = null,
    Object? isFavorite = null,
  }) {
    return _then(_$WordEntityImpl(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      display: null == display
          ? _value.display
          : display // ignore: cast_nullable_to_non_nullable
              as String,
      pos: null == pos
          ? _value.pos
          : pos // ignore: cast_nullable_to_non_nullable
              as String,
      meanings: null == meanings
          ? _value._meanings
          : meanings // ignore: cast_nullable_to_non_nullable
              as List<WordMeaningData>,
      examples: null == examples
          ? _value._examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<WordExampleData>,
      synonyms: null == synonyms
          ? _value._synonyms
          : synonyms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      antonyms: null == antonyms
          ? _value._antonyms
          : antonyms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      ipaUs: null == ipaUs
          ? _value.ipaUs
          : ipaUs // ignore: cast_nullable_to_non_nullable
              as String,
      ipaUk: null == ipaUk
          ? _value.ipaUk
          : ipaUk // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$WordEntityImpl implements _WordEntity {
  const _$WordEntityImpl(
      {this.word = '',
      this.display = '',
      this.pos = 'noun',
      final List<WordMeaningData> meanings = const <WordMeaningData>[],
      final List<WordExampleData> examples = const <WordExampleData>[],
      final List<String> synonyms = const <String>[],
      final List<String> antonyms = const <String>[],
      this.ipaUs = '',
      this.ipaUk = '',
      this.level = '',
      this.rank = 999999,
      this.isFavorite = false})
      : _meanings = meanings,
        _examples = examples,
        _synonyms = synonyms,
        _antonyms = antonyms;

  @override
  @JsonKey()
  final String word;
  @override
  @JsonKey()
  final String display;
  @override
  @JsonKey()
  final String pos;
  final List<WordMeaningData> _meanings;
  @override
  @JsonKey()
  List<WordMeaningData> get meanings {
    if (_meanings is EqualUnmodifiableListView) return _meanings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meanings);
  }

  final List<WordExampleData> _examples;
  @override
  @JsonKey()
  List<WordExampleData> get examples {
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_examples);
  }

  final List<String> _synonyms;
  @override
  @JsonKey()
  List<String> get synonyms {
    if (_synonyms is EqualUnmodifiableListView) return _synonyms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_synonyms);
  }

  final List<String> _antonyms;
  @override
  @JsonKey()
  List<String> get antonyms {
    if (_antonyms is EqualUnmodifiableListView) return _antonyms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_antonyms);
  }

  @override
  @JsonKey()
  final String ipaUs;
  @override
  @JsonKey()
  final String ipaUk;
  @override
  @JsonKey()
  final String level;
  @override
  @JsonKey()
  final int rank;
  @override
  @JsonKey()
  final bool isFavorite;

  @override
  String toString() {
    return 'WordEntity(word: $word, display: $display, pos: $pos, meanings: $meanings, examples: $examples, synonyms: $synonyms, antonyms: $antonyms, ipaUs: $ipaUs, ipaUk: $ipaUk, level: $level, rank: $rank, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordEntityImpl &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.display, display) || other.display == display) &&
            (identical(other.pos, pos) || other.pos == pos) &&
            const DeepCollectionEquality().equals(other._meanings, _meanings) &&
            const DeepCollectionEquality().equals(other._examples, _examples) &&
            const DeepCollectionEquality().equals(other._synonyms, _synonyms) &&
            const DeepCollectionEquality().equals(other._antonyms, _antonyms) &&
            (identical(other.ipaUs, ipaUs) || other.ipaUs == ipaUs) &&
            (identical(other.ipaUk, ipaUk) || other.ipaUk == ipaUk) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      word,
      display,
      pos,
      const DeepCollectionEquality().hash(_meanings),
      const DeepCollectionEquality().hash(_examples),
      const DeepCollectionEquality().hash(_synonyms),
      const DeepCollectionEquality().hash(_antonyms),
      ipaUs,
      ipaUk,
      level,
      rank,
      isFavorite);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WordEntityImplCopyWith<_$WordEntityImpl> get copyWith =>
      __$$WordEntityImplCopyWithImpl<_$WordEntityImpl>(this, _$identity);
}

abstract class _WordEntity implements WordEntity {
  const factory _WordEntity(
      {final String word,
      final String display,
      final String pos,
      final List<WordMeaningData> meanings,
      final List<WordExampleData> examples,
      final List<String> synonyms,
      final List<String> antonyms,
      final String ipaUs,
      final String ipaUk,
      final String level,
      final int rank,
      final bool isFavorite}) = _$WordEntityImpl;

  @override
  String get word;
  @override
  String get display;
  @override
  String get pos;
  @override
  List<WordMeaningData> get meanings;
  @override
  List<WordExampleData> get examples;
  @override
  List<String> get synonyms;
  @override
  List<String> get antonyms;
  @override
  String get ipaUs;
  @override
  String get ipaUk;
  @override
  String get level;
  @override
  int get rank;
  @override
  bool get isFavorite;
  @override
  @JsonKey(ignore: true)
  _$$WordEntityImplCopyWith<_$WordEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TranslationResult {
  String get input => throw _privateConstructorUsedError;
  String get output => throw _privateConstructorUsedError;
  String get fromLang => throw _privateConstructorUsedError;
  String get toLang => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TranslationResultCopyWith<TranslationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationResultCopyWith<$Res> {
  factory $TranslationResultCopyWith(
          TranslationResult value, $Res Function(TranslationResult) then) =
      _$TranslationResultCopyWithImpl<$Res, TranslationResult>;
  @useResult
  $Res call(
      {String input,
      String output,
      String fromLang,
      String toLang,
      String provider});
}

/// @nodoc
class _$TranslationResultCopyWithImpl<$Res, $Val extends TranslationResult>
    implements $TranslationResultCopyWith<$Res> {
  _$TranslationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? output = null,
    Object? fromLang = null,
    Object? toLang = null,
    Object? provider = null,
  }) {
    return _then(_value.copyWith(
      input: null == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as String,
      output: null == output
          ? _value.output
          : output // ignore: cast_nullable_to_non_nullable
              as String,
      fromLang: null == fromLang
          ? _value.fromLang
          : fromLang // ignore: cast_nullable_to_non_nullable
              as String,
      toLang: null == toLang
          ? _value.toLang
          : toLang // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TranslationResultImplCopyWith<$Res>
    implements $TranslationResultCopyWith<$Res> {
  factory _$$TranslationResultImplCopyWith(_$TranslationResultImpl value,
          $Res Function(_$TranslationResultImpl) then) =
      __$$TranslationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String input,
      String output,
      String fromLang,
      String toLang,
      String provider});
}

/// @nodoc
class __$$TranslationResultImplCopyWithImpl<$Res>
    extends _$TranslationResultCopyWithImpl<$Res, _$TranslationResultImpl>
    implements _$$TranslationResultImplCopyWith<$Res> {
  __$$TranslationResultImplCopyWithImpl(_$TranslationResultImpl _value,
      $Res Function(_$TranslationResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? output = null,
    Object? fromLang = null,
    Object? toLang = null,
    Object? provider = null,
  }) {
    return _then(_$TranslationResultImpl(
      input: null == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as String,
      output: null == output
          ? _value.output
          : output // ignore: cast_nullable_to_non_nullable
              as String,
      fromLang: null == fromLang
          ? _value.fromLang
          : fromLang // ignore: cast_nullable_to_non_nullable
              as String,
      toLang: null == toLang
          ? _value.toLang
          : toLang // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TranslationResultImpl implements _TranslationResult {
  const _$TranslationResultImpl(
      {this.input = '',
      this.output = '',
      this.fromLang = 'en',
      this.toLang = 'fa',
      this.provider = ''});

  @override
  @JsonKey()
  final String input;
  @override
  @JsonKey()
  final String output;
  @override
  @JsonKey()
  final String fromLang;
  @override
  @JsonKey()
  final String toLang;
  @override
  @JsonKey()
  final String provider;

  @override
  String toString() {
    return 'TranslationResult(input: $input, output: $output, fromLang: $fromLang, toLang: $toLang, provider: $provider)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationResultImpl &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.output, output) || other.output == output) &&
            (identical(other.fromLang, fromLang) ||
                other.fromLang == fromLang) &&
            (identical(other.toLang, toLang) || other.toLang == toLang) &&
            (identical(other.provider, provider) ||
                other.provider == provider));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, input, output, fromLang, toLang, provider);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationResultImplCopyWith<_$TranslationResultImpl> get copyWith =>
      __$$TranslationResultImplCopyWithImpl<_$TranslationResultImpl>(
          this, _$identity);
}

abstract class _TranslationResult implements TranslationResult {
  const factory _TranslationResult(
      {final String input,
      final String output,
      final String fromLang,
      final String toLang,
      final String provider}) = _$TranslationResultImpl;

  @override
  String get input;
  @override
  String get output;
  @override
  String get fromLang;
  @override
  String get toLang;
  @override
  String get provider;
  @override
  @JsonKey(ignore: true)
  _$$TranslationResultImplCopyWith<_$TranslationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
