import 'package:puzzle_dot/data/tts/tts_pronunciation_map.dart';

/// TTS 발음 변환 서비스
///
/// 역할:
/// - 점 번호를 자연스러운 TTS 문구로 변환
/// - 자음/쌍자음/받침/겹받침 발음 변환
/// - 화면 표시 문구와 음성 문구 분리
class TtsPronunciationService {
  TtsPronunciationService._();

  static String normalize(String value) {
    var result = value.trim();
    if (result.isEmpty) return result;

    final exact = TtsPronunciationMap.exactItemNames[result];
    if (exact != null) return exact;

    result = _replaceDotPatterns(result);
    result = _replaceByLength(result, TtsPronunciationMap.numberReadings);
    result = _replaceByLength(result, TtsPronunciationMap.phraseReplacements);
    result = _replaceByLength(result, TtsPronunciationMap.symbolReplacements);
    result = _normalizeSpacing(result);

    return result;
  }

  static String itemName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    return TtsPronunciationMap.exactItemNames[trimmed] ?? normalize(trimmed);
  }

  static String _replaceDotPatterns(String value) {
    var result = value;

    result = _replaceAndDotPattern(result);
    result = _replaceMiddleDotPattern(result);
    result = _replaceJoinedDotPattern(result);
    result = _replaceSingleDotPattern(result);

    return result;
  }

  static String _replaceAndDotPattern(String value) {
    return value.replaceAllMapped(
      RegExp(r'([1-6])번과\s*([1-6])번\s*점'),
      (match) {
        final first = _dotName(match.group(1)!);
        final second = _dotName(match.group(2)!);
        return '$first과 $second점';
      },
    );
  }

  static String _replaceMiddleDotPattern(String value) {
    return value.replaceAllMapped(
      RegExp(r'([1-6](?:·[1-6])+)번\s*점'),
      (match) {
        final dots = match.group(1)!.split('·');
        return _dotListPhrase(dots);
      },
    );
  }

  static String _replaceJoinedDotPattern(String value) {
    return value.replaceAllMapped(
      RegExp(r'([1-6]{2,6})번\s*점'),
      (match) {
        final dots = match.group(1)!.split('');
        return _dotListPhrase(dots);
      },
    );
  }

  static String _replaceSingleDotPattern(String value) {
    return value.replaceAllMapped(
      RegExp(r'([1-6])번\s*점'),
      (match) {
        final dot = match.group(1)!;
        return '${_dotName(dot)} 점';
      },
    );
  }

  static String _dotListPhrase(List<String> dots) {
    final names = dots.map(_dotName).toList();
    if (names.isEmpty) return '';

    if (names.length == 1) {
      return '${names.first} 점';
    }

    final prefix = names.take(names.length - 1).join(', ');
    final last = names.last;
    return '$prefix, $last 점';
  }

  static String _dotName(String dot) {
    return TtsPronunciationMap.dotNames[dot] ?? '$dot번';
  }

  static String _replaceByLength(String value, Map<String, String> replacements) {
    var result = value;
    final keys = replacements.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final key in keys) {
      result = result.replaceAll(key, replacements[key]!);
    }

    return result;
  }

  static String _normalizeSpacing(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' ,', ',')
        .trim();
  }
}