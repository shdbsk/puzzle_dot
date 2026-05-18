import 'package:flutter/material.dart';
import 'package:puzzle_dot/screens/chat_screen.dart';
import 'package:puzzle_dot/screens/curriculum_selection_screen.dart';
import 'package:puzzle_dot/screens/practice_screen.dart';
import 'package:puzzle_dot/screens/settings_screen.dart';
import 'package:puzzle_dot/screens/widgets/app_drawer.dart';
import 'package:puzzle_dot/services/progress_service.dart';
import 'package:puzzle_dot/services/streak_service.dart';
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
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _levels = [
    {'id': 'ENT_1', 'title': '입문 1', 'subtitle': '점 위치 번호 익히기'},
    {'id': 'BAS_1', 'title': '초급 1', 'subtitle': '자음 익히기'},
    {'id': 'BAS_2', 'title': '초급 2', 'subtitle': '모음 익히기'},
    {'id': 'INT_1', 'title': '중급 1', 'subtitle': '된소리와 복합 모음'},
    {'id': 'INT_2', 'title': '중급 2', 'subtitle': '받침 익히기'},
    {'id': 'ADV_1', 'title': '고급 1', 'subtitle': '겹받침 익히기'},
    {'id': 'ADV_2', 'title': '고급 2', 'subtitle': '숫자 익히기'},
  ];

  Map<String, double> _progressMap = {};
  int _streakDays = 0;
  int _totalXp = 0;
  int _completedCount = 0;
  int _totalItemCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final progressMap = await ProgressService.getLevelProgressMap();
    final streakDays = await StreakService.getStreak();
    final totalXp = await XpService.getTotalXp();
    final completedCount = await ProgressService.getTotalCompletedCount();
    final totalItemCount = ProgressService.getTotalItemCount();

    if (!mounted) return;

    setState(() {
      _progressMap = progressMap;
      _streakDays = streakDays;
      _totalXp = totalXp;
      _completedCount = completedCount;
      _totalItemCount = totalItemCount;
    });
  }

  bool _isUnlocked(String levelId) {
    switch (levelId) {
      case 'ENT_1':
        return true;
      case 'BAS_1':
      case 'BAS_2':
        return (_progressMap['ENT_1'] ?? 0) >= 1.0;
      case 'INT_1':
      case 'INT_2':
        final beginnerAverage =
            ((_progressMap['BAS_1'] ?? 0) + (_progressMap['BAS_2'] ?? 0)) / 2;
        return beginnerAverage >= 0.5;
      case 'ADV_1':
      case 'ADV_2':
        final intermediateAverage =
            ((_progressMap['INT_1'] ?? 0) + (_progressMap['INT_2'] ?? 0)) / 2;
        return intermediateAverage >= 0.5;
      default:
        return false;
    }
  }

  void _onTapNav(int index) {
    TtsManager.instance.stopAll();

    setState(() => _selectedIndex = index);

    if (index == 0) {
      _loadDashboardData();
    }
  }

  Widget _buildLevelCard(Map<String, String> level) {
    final id = level['id']!;
    final title = level['title']!;
    final subtitle = level['subtitle']!;
    final progress = _progressMap[id] ?? 0.0;
    final progressPercent = (progress * 100).round();
    final unlocked = _isUnlocked(id);

    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label: unlocked
          ? '$title, $subtitle, 진행률 $progressPercent퍼센트, 선택하려면 두 번 탭하세요.'
          : '$title, $subtitle, 잠금됨',
      child: GestureDetector(
        onTap: unlocked
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CurriculumSelectionScreen(
                      levelId: id,
                      levelTitle: title,
                    ),
                  ),
                ).then((_) => _loadDashboardData())
            : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 132),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    unlocked ? Icons.check_circle : Icons.lock,
                    size: 18,
                    color: unlocked
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF94A3B8),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: unlocked ? progress : 0,
                  minHeight: 10,
                  color: unlocked
                      ? const Color(0xFF00AEEF)
                      : const Color(0xFFD1D5DB),
                  backgroundColor: const Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    unlocked ? '$progressPercent% 완료' : '잠금됨',
                    style: TextStyle(
                      fontSize: 12,
                      color: unlocked
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    unlocked ? Icons.arrow_forward_ios : Icons.lock,
                    size: 14,
                    color: unlocked
                        ? const Color(0xFF00AEEF)
                        : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final progressText =
        _totalItemCount == 0 ? '0/0 완료' : '$_completedCount/$_totalItemCount 완료';

    final progressPercent = _totalItemCount == 0
        ? 0
        : ((_completedCount / _totalItemCount) * 100).round();

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              label:
                  '커리큘럼 선택. 전체 $_totalItemCount개 중 $_completedCount개 완료. 진행률 $progressPercent퍼센트.',
              child: Container(
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '점 위치부터 숫자까지 단계별로 학습해 보세요.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        progressText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1D4ED8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              title: '챗봇',
                              subtitle: '질문하기',
                              icon: Icons.chat_bubble_outline,
                              iconColor: const Color(0xFF00AEEF),
                              onTap: () => setState(() => _selectedIndex = 2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              title: '설정',
                              subtitle: '환경 설정',
                              icon: Icons.settings_outlined,
                              iconColor: const Color(0xFF6366F1),
                              onTap: () => setState(() => _selectedIndex = 3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _StatMiniCard(
                    label: '연속 학습일',
                    value: '$_streakDays일',
                    semanticsLabel: '연속 학습일 $_streakDays일',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatMiniCard(
                    label: '누적 경험치',
                    value: '$_totalXp XP',
                    semanticsLabel: '누적 경험치 $_totalXp XP',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              '학습 단계',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final level in _levels) ...[
              _buildLevelCard(level),
              const SizedBox(height: 14),
            ],
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

    final titles = ['PuzzleDot', '카메라 학습', 'PuzzleBot', '설정'];
    final subtitles = [
      '학습 대시보드',
      '카메라로 점자 연습',
      'PuzzleBot과 대화',
      '프로필 및 설정',
    ];

    final tabs = [
      _buildHomeTab(),
      const PracticeScreen(),
      ChatScreen(onBackPressed: () => setState(() => _selectedIndex = 0)),
      SettingsScreen(
        onBackPressed: () => setState(() => _selectedIndex = 0),
        isActive: _selectedIndex == 3,
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: '메뉴 열기',
                    child: GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        padding: const EdgeInsets.all(12),
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
                    child: Semantics(
                      header: true,
                      label: '${titles[_selectedIndex]}, ${subtitles[_selectedIndex]}',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titles[_selectedIndex],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
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
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFDBEAFE),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=12',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: tabs,
              ),
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 84),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final String semanticsLabel;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: Container(
        constraints: const BoxConstraints(minHeight: 92),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}