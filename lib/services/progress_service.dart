import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzle_dot/core/constants/prefs_keys.dart';
import 'package:puzzle_dot/data/curriculum_data.dart';
import 'package:puzzle_dot/models/curriculum_item.dart';
import 'package:puzzle_dot/services/streak_service.dart';
import 'package:puzzle_dot/services/xp_service.dart';

class ProgressService {
  ProgressService._();

  static Future<bool> markCompleted(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = PrefsKeys.doneKey(itemId);
    final alreadyDone = prefs.getBool(key) ?? false;

    if (alreadyDone) return false;

    await prefs.setBool(key, true);
    await StreakService.recordActivityAndGetStreak();
    await XpService.addXp();

    return true;
  }

  static Future<bool> isCompleted(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefsKeys.doneKey(itemId)) ?? false;
  }

  static Future<Set<String>> getCompletedIds(
    List<CurriculumItem> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    return items
        .where((item) => prefs.getBool(PrefsKeys.doneKey(item.id)) ?? false)
        .map((item) => item.id)
        .toSet();
  }

  static Future<Map<String, double>> getLevelProgressMap() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, double>{};

    for (final entry in curriculumData.entries) {
      final levelId = entry.key;
      final items = entry.value;

      if (items.isEmpty) {
        result[levelId] = 0.0;
        continue;
      }

      final completedCount = items
          .where((item) => prefs.getBool(PrefsKeys.doneKey(item.id)) ?? false)
          .length;

      result[levelId] = completedCount / items.length;
    }

    return result;
  }

  static Future<int> getTotalCompletedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final allItems = curriculumData.values.expand((items) => items);

    return allItems
        .where((item) => prefs.getBool(PrefsKeys.doneKey(item.id)) ?? false)
        .length;
  }

  static int getTotalItemCount() {
    return curriculumData.values.fold<int>(
      0,
      (sum, items) => sum + items.length,
    );
  }
}