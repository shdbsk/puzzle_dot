import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzle_dot/core/constants/prefs_keys.dart';

class XpService {
  XpService._();

  static const int xpPerItem = 150;

  static Future<int> addXp({int amount = xpPerItem}) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(PrefsKeys.totalXp) ?? 0;
    final updated = current + amount;

    await prefs.setInt(PrefsKeys.totalXp, updated);
    return updated;
  }

  static Future<int> getTotalXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefsKeys.totalXp) ?? 0;
  }
}