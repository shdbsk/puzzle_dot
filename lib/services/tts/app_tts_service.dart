import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:puzzle_dot/services/interfaces/i_tts_service.dart';
import 'package:puzzle_dot/services/tts/tts_config.dart';

/// 앱 기본 TTS 서비스
///
/// 역할:
/// - TTS 설정값 통일
/// - 중복 발화 방지
/// - 화면 이동 시 stop 처리
/// - interrupt=false 시 이전 음성 종료 후 다음 음성 실행
///
/// 화면은 FlutterTts 직접 생성하지 않고 이 서비스 사용
class AppTtsService implements ITtsService {
  AppTtsService._();

  static final AppTtsService _instance = AppTtsService._();

  factory AppTtsService() => _instance;

  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;
  Completer<void>? _currentSpeech;
  Future<void> _speechChain = Future<void>.value();

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    await _tts.setLanguage(TtsConfig.language);
    await _tts.setSpeechRate(TtsConfig.speechRate);
    await _tts.setVolume(TtsConfig.volume);
    await _tts.setPitch(TtsConfig.pitch);
    await _tts.awaitSpeakCompletion(true);

    _tts.setCompletionHandler(_completeCurrentSpeech);
    _tts.setCancelHandler(_completeCurrentSpeech);
    _tts.setErrorHandler((_) => _completeCurrentSpeech());

    _initialized = true;
  }

  @override
  Future<void> speak(
    String text, {
    bool interrupt = true,
  }) {
    final message = text.trim();
    if (message.isEmpty) return Future<void>.value();

    if (interrupt) {
      _speechChain = _speakNow(message);
      return _speechChain;
    }

    _speechChain = _speechChain.then((_) => _speakNow(message));
    return _speechChain;
  }

  Future<void> _speakNow(String message) async {
    await _ensureInitialized();
    await stop();

    final speech = Completer<void>();
    _currentSpeech = speech;

    try {
      await _tts.speak(message);

      await speech.future.timeout(
        TtsConfig.fallbackCompletionWait,
        onTimeout: () {},
      );
    } finally {
      if (identical(_currentSpeech, speech)) {
        _currentSpeech = null;
      }
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      /// 플랫폼 TTS 엔진 상태에 따라 stop 실패 가능
      ///
      /// 화면 전환이 막히면 안 되므로 무시
    }

    _completeCurrentSpeech();
  }

  void _completeCurrentSpeech() {
    final speech = _currentSpeech;

    if (speech != null && !speech.isCompleted) {
      speech.complete();
    }

    _currentSpeech = null;
  }

  /// Singleton 서비스라 실제 dispose는 하지 않음
  ///
  /// 기존 화면 코드와 호환을 위해 메서드만 유지
  void dispose() {}
}