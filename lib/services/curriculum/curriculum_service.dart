import 'package:puzzle_dot/data/curriculum/curriculum_data.dart';
import 'package:puzzle_dot/models/curriculum_item.dart';

/// 커리큘럼 데이터 조회 서비스
///
/// 역할:
/// - levelId 기준 학습 항목 조회
/// - 전체 학습 항목 조회
/// - 화면과 저장 로직이 curriculumData 구조를 직접 알지 않게 분리
class CurriculumService {
  CurriculumService._();

  static List<CurriculumItem> getItemsByLevel(String levelId) {
    return List.unmodifiable(curriculumData[levelId] ?? const []);
  }

  static Map<String, List<CurriculumItem>> getLevelMap() {
    return Map.unmodifiable(curriculumData);
  }

  static Iterable<CurriculumItem> getAllItems() {
    return curriculumData.values.expand((items) => items);
  }

  static int getTotalItemCount() {
    return curriculumData.values.fold<int>(
      0,
      (sum, items) => sum + items.length,
    );
  }

  static bool hasLevel(String levelId) {
    return curriculumData.containsKey(levelId);
  }
}