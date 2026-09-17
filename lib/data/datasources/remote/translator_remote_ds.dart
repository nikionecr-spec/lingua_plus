import 'package:dio/dio.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/entities/word_entity.dart';

/// Online translator over FREE, key-less APIs:
///   1. MyMemory (primary)      — GET /get?q=..&langpair=en|fa
///   2. LibreTranslate mirrors  — POST /translate (fallback chain)
/// Persian/English detection is a local heuristic (no round-trip).
class TranslatorRemoteDs {
  TranslatorRemoteDs({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 12),
                headers: {'User-Agent': 'LinguaPlus/1.0'},
              ),
            );

  final Dio dio;

  static const List<String> libreMirrors = [
    'https://translate.argosopentech.com',
    'https://libretranslate.de',
  ];

  /// Lightweight script-based language detection (fa vs en).
  /// Persian/Arabic Unicode block (0600–06FF) → 'fa', otherwise 'en'.
  String detectLanguage(String text) {
    final faRegex = RegExp(r'[\u0600-\u06FF]');
    return faRegex.hasMatch(text) ? 'fa' : 'en';
  }

  /// Translates [text] from [from] (null = auto-detect) to [to].
  Future<TranslationResult> translate(
    String text, {
    String? from,
    String to = 'fa',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const TranslationException('empty input');
    }
    final src = from ?? detectLanguage(trimmed);
    if (src == to) {
      // Same language → echo back with a note-free passthrough.
      return TranslationResult(
        input: trimmed,
        output: trimmed,
        fromLang: src,
        toLang: to,
        provider: 'identity',
      );
    }

    // 1) MyMemory
    try {
      return await _myMemory(trimmed, src, to);
    } on AppException {
      // fall through
    } catch (_) {
      // fall through
    }

    // 2) LibreTranslate mirrors
    for (final base in libreMirrors) {
      try {
        return await _libre(base, trimmed, src, to);
      } on AppException {
        continue;
      } catch (_) {
        continue;
      }
    }

    throw const TranslationException(
      'همه سرویس‌های ترجمه در دسترس نیستند',
    );
  }

  Future<TranslationResult> _myMemory(
    String text,
    String src,
    String to,
  ) async {
    final res = await dio.get<Map<String, dynamic>>(
      'https://api.mymemory.translated.net/get',
      queryParameters: {
        'q': text,
        'langpair': '$src|$to',
      },
    );
    final data = res.data;
    if (data == null) {
      throw const NetworkException('empty response');
    }
    final status = data['responseStatus'];
    final translated =
        data['responseData']?['translatedText']?.toString() ?? '';
    if (status == 200 && translated.isNotEmpty) {
      // MyMemory may echo warnings like "MYMEMORY WARNING:" — strip them.
      final clean = translated.contains('MYMEMORY WARNING')
          ? translated.split('%').last.trim()
          : translated;
      return TranslationResult(
        input: text,
        output: clean,
        fromLang: src,
        toLang: to,
        provider: 'MyMemory',
      );
    }
    throw const TranslationException('mymemory bad status');
  }

  Future<TranslationResult> _libre(
    String base,
    String text,
    String src,
    String to,
  ) async {
    final res = await dio.post<Map<String, dynamic>>(
      '$base/translate',
      data: {
        'q': text,
        'source': src,
        'target': to,
        'format': 'text',
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final translated = res.data?['translatedText']?.toString() ?? '';
    if (translated.isEmpty) {
      throw const TranslationException('libre empty');
    }
    return TranslationResult(
      input: text,
      output: translated,
      fromLang: src,
      toLang: to,
      provider: 'LibreTranslate',
    );
  }
}
