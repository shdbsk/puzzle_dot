import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzle_dot/core/constants/prefs_keys.dart';

class StreakService {
  StreakService._();

  static Future<int> recordActivityAndGetStreak() async {
    final prefs = await SharedPreferences.getInstance();

    final today = _todayString();
    final lastDate = prefs.getString(PrefsKeys.streakLastDate);
    var streak = prefs.getInt(PrefsKeys.streakCount) ?? 0;

    if (lastDate == null) {
      streak = 1;
    } else if (lastDate == today) {
      return streak;
    } else {
      final last = DateTime.parse(lastDate);
      final current = DateTime.parse(today);
      final diff = current.difference(last).inDays;

      streak = diff == 1 ? streak + 1 : 1;
    }

    await prefs.setString(PrefsKeys.streakLastDate, today);
    await prefs.setInt(PrefsKeys.streakCount, streak);

    return streak;
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();

    final lastDate = prefs.getString(PrefsKeys.streakLastDate);
    if (lastDate == null) return 0;

    final today = DateTime.parse(_todayString());
    final last = DateTime.parse(lastDate);
    final diff = today.difference(last).inDays;

    if (diff > 1) return 0;

    return prefs.getInt(PrefsKeys.streakCount) ?? 0;
  }

  static String _todayString() {
    final now = DateTime.now();

    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}