import 'package:puzzle_dot/models/home_learning_level.dart';

/// 홈 화면 레벨 표시 데이터
///
/// 역할:
/// - 홈에 표시할 커리큘럼 단계 순서 관리
/// - 화면 파일에서 단계 목록 직접 관리 방지
/// - 통합기획서 기준 단계 변경 시 이 파일 중심으로 수정
const List<HomeLearningLevel> homeLearningLevels = [
  HomeLearningLevel(
    id: 'ENT_1',
    title: '입문 1',
    subtitle: '점자의 기본 구조 익히기',
    group: HomeLevelGroup.intro,
  ),
  HomeLearningLevel(
    id: 'BAS_1',
    title: '초급 1',
    subtitle: '기본 자음 학습',
    group: HomeLevelGroup.beginner,
  ),
  HomeLearningLevel(
    id: 'BAS_2',
    title: '초급 2',
    subtitle: '기본 모음 학습',
    group: HomeLevelGroup.beginner,
  ),
  HomeLearningLevel(
    id: 'INT_1',
    title: '중급 1',
    subtitle: '된소리와 복합 모음 학습',
    group: HomeLevelGroup.intermediate,
  ),
  HomeLearningLevel(
    id: 'INT_2',
    title: '중급 2',
    subtitle: '받침 학습',
    group: HomeLevelGroup.intermediate,
  ),
  HomeLearningLevel(
    id: 'ADV_1',
    title: '고급 1',
    subtitle: '겹받침 학습',
    group: HomeLevelGroup.advanced,
  ),
  HomeLearningLevel(
    id: 'ADV_2',
    title: '고급 2',
    subtitle: '숫자와 혼합 연습',
    group: HomeLevelGroup.advanced,
  ),
];