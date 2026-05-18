class PrefsKeys {
  PrefsKeys._();

  static const String donePrefix = 'done_';
  static const String streakLastDate = 'streak_last_date';
  static const String streakCount = 'streak_count';
  static const String totalXp = 'total_xp';
  static const String cameraGuidePrefix = 'camera_guide_seen_';
  static const String isFirstLaunch = 'is_first_launch';

  static String doneKey(String id) => '$donePrefix$id';

  static String cameraGuideKey(String levelId) =>
      '$cameraGuidePrefix$levelId';
}