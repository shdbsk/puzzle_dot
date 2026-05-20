import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puzzle_dot/data/curriculum/home_learning_levels.dart';
import 'package:puzzle_dot/models/home_learning_level.dart';
import 'package:puzzle_dot/screens/misc/chat_screen.dart';
import 'package:puzzle_dot/screens/curriculum/curriculum_selection_screen.dart';
import 'package:puzzle_dot/screens/practice/practice_screen.dart';
import 'package:puzzle_dot/screens/misc/settings_screen.dart';
import 'package:puzzle_dot/widgets/navigation/app_drawer.dart';
import 'package:puzzle_dot/screens/home/widgets/home_action_card.dart';
import 'package:puzzle_dot/screens/home/widgets/home_level_card.dart';
import 'package:puzzle_dot/screens/home/widgets/home_stat_card.dart';
import 'package:puzzle_dot/services/progress_service.dart';
import 'package:puzzle_dot/services/progress/level_unlock_service.dart';
import 'package:puzzle_dot/services/streak_service.dart';
import 'package:puzzle_dot/services/tts/app_tts_service.dart';
import 'package:puzzle_dot/services/tts_manager.dart';
import 'package:puzzle_dot/services/xp_service.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late int _selectedIndex;
  Map<String, double> _progressMap = {};
  int _dailyStreak = 0;
  int _totalXp = 0;


  @override
  void initState() {
    super.initState();

    /// Drawer에서 Chat/Settings 탭으로 직접 진입할 때 사용
    ///
    /// 잘못된 index가 들어와도 앱이 깨지지 않도록 0~3 범위로 제한
    _selectedIndex = widget.initialIndex.clamp(0, 3).toInt();

    unawaited(_loadDashboardData());
  }

  /// 홈 대시보드 데이터 로드
  ///
  /// UI는 저장소 구현체를 직접 알지 않고 서비스 결과만 사용
  Future<void> _loadDashboardData() async {
    final results = await Future.wait<Object>([
      ProgressService.getLevelProgressMap(),
      StreakService.getStreak(),
      XpService.getTotalXp(),
    ]);

    if (!mounted) return;

    setState(() {
      _progressMap = results[0] as Map<String, double>;
      _dailyStreak = results[1] as int;
      _totalXp = results[2] as int;
    });
  }

  /// 탭 이동 전 진행 중인 음성 정리
  ///
  /// 화면 이동 시 TTS 겹침 방지
  void _stopScreenAudio() {
    unawaited(TtsManager.instance.stopAll());
    unawaited(AppTtsService().stop());
  }

  /// 하단 네비게이션 탭 변경
  ///
  /// Practice 탭은 선택된 순간에만 생성
  void _onTapNav(int index) {
    _stopScreenAudio();

    setState(() => _selectedIndex = index);

    if (index == 0) {
      unawaited(_loadDashboardData());
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _goHome() {
    _onTapNav(0);
  }

  void _openChat() {
    _onTapNav(2);
  }

  void _openSettings() {
    _onTapNav(3);
  }

  Future<void> _openLevel(HomeLearningLevel level) async {
    _stopScreenAudio();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CurriculumSelectionScreen(
          levelId: level.id,
          levelTitle: level.title,
        ),
      ),
    );

    if (!mounted) return;
    await _loadDashboardData();
  }


  /// 선택된 탭만 생성
  ///
  /// IndexedStack 사용 시 Practice가 앱 시작부터 생성되어 권한 TTS가 실행됨
  Widget _buildSelectedTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();

      case 1:
        return PracticeScreen(onHome: _goHome);

      case 2:
        return ChatScreen(onBackPressed: _goHome);

      case 3:
        return SettingsScreen(
          onBackPressed: _goHome,
          isActive: true,
        );

      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final visibleLevels = homeLearningLevels;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: HomeStatCard(
                    label: '연속 학습일',
                    value: '$_dailyStreak일',
                    icon: Icons.local_fire_department_outlined,
                    iconColor: const Color(0xFFF97316),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HomeStatCard(
                    label: '누적 경험치',
                    value: '$_totalXp XP',
                    icon: Icons.bolt_outlined,
                    iconColor: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              '이어서 학습하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            for (final level in visibleLevels) ...[
              HomeLevelCard(
                level: level,
                progress: _progressMap[level.id] ?? 0,
                isUnlocked: LevelUnlockService.isUnlocked(
                  level: level,
                  progressMap: _progressMap,
                ),
                onTap: () => _openLevel(level),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECF4FF), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.menu_book,
                  size: 28,
                  color: Color(0xFF1D4ED8),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '커리큘럼 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '통합기획서 기준 학습 단계에 맞춰 점자를 차근차근 익혀보세요.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: HomeActionCard(
                    title: '챗봇',
                    subtitle: '상담 화면으로 이동',
                    icon: Icons.chat_bubble_outline,
                    iconColor: const Color(0xFF00AEEF),
                    onTap: _openChat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HomeActionCard(
                    title: '설정',
                    subtitle: '환경 설정',
                    icon: Icons.settings_outlined,
                    iconColor: const Color(0xFF6366F1),
                    onTap: _openSettings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const navItems = [
      NavigationDestination(
        icon: Icon(Icons.school_outlined),
        label: 'Learn',
      ),
      NavigationDestination(
        icon: Icon(Icons.camera_alt_outlined),
        label: 'Practice',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        label: 'Chat',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];

    const titles = ['PuzzleDot', '카메라 학습', 'PuzzleBot', '설정'];
    const subtitles = [
      '학습 대시보드',
      '카메라로 점자 연습',
      'PuzzleBot과 대화',
      '프로필 및 설정',
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: '메뉴 열기',
                    child: GestureDetector(
                      onTap: _openDrawer,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titles[_selectedIndex],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitles[_selectedIndex],
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFDBEAFE),
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildSelectedTab(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: NavigationBar(
          height: 72,
          backgroundColor: Colors.white,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onTapNav,
          destinations: navItems,
        ),
      ),
    );
  }
}