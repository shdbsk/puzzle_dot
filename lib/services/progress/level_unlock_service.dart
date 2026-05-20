import 'package:puzzle_dot/models/home_learning_level.dart';

/// 홈 레벨 잠금 판단 서비스
///
/// 역할:
/// - 레벨 잠금/해제 조건 계산
/// - HomeScreen이 진행률 계산 규칙을 직접 알지 않게 분리
/// - 잠금 정책 변경 시 이 파일만 수정
class LevelUnlockService {
  LevelUnlockService._();

  static bool isUnlocked({
    required HomeLearningLevel level,
    required Map<String, double> progressMap,
  }) {
    switch (level.group) {
      case HomeLevelGroup.intro:
        return true;

      case HomeLevelGroup.beginner:
        return (progressMap['ENT_1'] ?? 0) >= 1.0;

      case HomeLevelGroup.intermediate:
        return _averageProgress(
              progressMap,
              const ['BAS_1', 'BAS_2'],
            ) >=
            0.5;

      case HomeLevelGroup.advanced:
        return _averageProgress(
              progressMap,
              const ['INT_1', 'INT_2'],
            ) >=
            0.5;
    }
  }

  static double _averageProgress(
    Map<String, double> progressMap,
    List<String> levelIds,
  ) {
    if (levelIds.isEmpty) return 0;

    final total = levelIds.fold<double>(
      0,
      (sum, id) => sum + (progressMap[id] ?? 0),
    );

    return total / levelIds.length;
  }
}