import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Single app-wide speech facade: TTS (flutter_tts) + STT (speech_to_text).
/// All failures degrade gracefully (methods never throw).
class SpeechService {
  SpeechService() {
    _setupTts();
  }

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _sttReady = false;

  Future<void> _setupTts() async {
    try {
      await _tts.setSharedInstance(true);
      _tts.setCompletionHandler(() {});
      _tts.setErrorHandler((msg) {});
    } catch (_) {
      // TTS unavailable — speak() calls will no-op gracefully.
    }
  }

  /// Speaks [text] with the given BCP-47 language (en-US / en-GB / fa-IR).
  Future<void> speak(String text, {String lang = 'en-US'}) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.setLanguage(lang);
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Initializes STT. Returns false when permission denied / unavailable.
  Future<bool> initStt() async {
    if (_sttReady) return true;
    try {
      _sttReady = await _stt.initialize(
        onError: (error) {},
        onStatus: (status) {},
      );
    } catch (_) {
      _sttReady = false;
    }
    return _sttReady;
  }

  /// Starts listening. Final recognized text goes into [onResult].
  Future<bool> listen({
    required String localeId,
    required void Function(String text) onResult,
  }) async {
    if (!await initStt()) return false;
    try {
      await _stt.listen(
        localeId: localeId,
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(partialResults: true),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopListening() async {
    if (!_sttReady) return;
    try {
      await _stt.stop();
    } catch (_) {}
  }
}
