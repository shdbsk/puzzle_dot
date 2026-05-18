import 'package:flutter/material.dart';
import 'package:puzzle_dot/models/curriculum_item.dart';
import 'package:puzzle_dot/screens/active_learning_screen.dart';
import 'package:puzzle_dot/services/app_tts_service.dart';
import 'package:puzzle_dot/services/streak_service.dart';
import 'package:puzzle_dot/services/xp_service.dart';

class LevelCompletionScreen extends StatefulWidget {
  final String levelId;
  final String levelName;
  final String itemName;
  final List<CurriculumItem>? allItems;
  final int? currentIndex;
  final int xpEarned;

  const LevelCompletionScreen({
    super.key,
    this.levelId = '',
    this.levelName = '',
    this.itemName = '',
    this.allItems,
    this.currentIndex,
    this.xpEarned = XpService.xpPerItem,
  });

  @override
  State<LevelCompletionScreen> createState() => _LevelCompletionScreenState();
}

class _LevelCompletionScreenState extends State<LevelCompletionScreen> {
  final AppTtsService _tts = AppTtsService();

  bool _isSpeaking = false;
  int _streak = 0;
  int _totalXp = 0;

  bool get _hasNext {
    final items = widget.allItems;
    final index = widget.currentIndex;

    return items != null && index != null && index + 1 < items.length;
  }

  CurriculumItem? get _currentItem {
    final items = widget.allItems;
    final index = widget.currentIndex;

    if (items == null || index == null) return null;
    if (index < 0 || index >= items.length) return null;

    return items[index];
  }

  @override
  void initState() {
    super.initState();
    _loadStatsAndSpeak();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadStatsAndSpeak() async {
    final streak = await StreakService.getStreak();
    final totalXp = await XpService.getTotalXp();

    if (!mounted) return;

    setState(() {
      _streak = streak;
      _totalXp = totalXp;
    });

    await _speak();
  }

  Future<void> _speak() async {
    if (_isSpeaking) return;

    setState(() => _isSpeaking = true);

    final xpMessage = widget.xpEarned > 0
        ? '경험치 ${widget.xpEarned}점을 획득했습니다.'
        : '이미 완료한 학습이라 추가 경험치는 없습니다.';

    final itemMessage = widget.itemName.isEmpty
        ? '학습을 완료했습니다.'
        : '${widget.itemName} 학습을 완료했습니다.';

    await _tts.speak('정답입니다! $itemMessage $xpMessage');
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    setState(() => _isSpeaking = false);
  }

  Future<void> _stopTts() async {
    await _tts.stop();

    if (!mounted) return;

    setState(() => _isSpeaking = false);
  }

  Future<void> _goNext() async {
    await _stopTts();

    final items = widget.allItems;
    final index = widget.currentIndex;

    if (items == null || index == null || index + 1 >= items.length) {
      await _goHome();
      return;
    }

    if (!mounted) return;

    final nextIndex = index + 1;
    final nextItem = items[nextIndex];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveLearningScreen(
          item: nextItem,
          levelId: widget.levelId,
          levelName: widget.levelName,
          allItems: items,
          currentIndex: nextIndex,
        ),
      ),
    );
  }

  Future<void> _retry() async {
    await _stopTts();

    final items = widget.allItems;
    final index = widget.currentIndex;
    final currentItem = _currentItem;

    if (items == null || index == null || currentItem == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveLearningScreen(
          item: currentItem,
          levelId: widget.levelId,
          levelName: widget.levelName,
          allItems: items,
          currentIndex: index,
        ),
      ),
    );
  }

  Future<void> _goHome() async {
    await _stopTts();

    if (!mounted) return;

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final nextButtonLabel = _hasNext ? '다음 문제' : '홈으로';

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, __) {
        _tts.stop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F6FF),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 22,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Semantics(
                    button: true,
                    label: '현재 문제 다시하기',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _retry,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 32,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3322C55E),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '정답입니다!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF15803D),
                        ),
                      ),
                      if (widget.itemName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '완료한 학습: ${widget.itemName}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (_isSpeaking)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.volume_up,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '음성 안내 중...',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      else
                        TextButton.icon(
                          onPressed: _speak,
                          icon: const Icon(
                            Icons.replay,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                          label: const Text(
                            '다시 듣기',
                            style: TextStyle(color: Color(0xFF2563EB)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Daily Streak',
                        value: '$_streak Days',
                        caption: '연속 학습일',
                        icon: Icons.local_fire_department,
                        iconColor: const Color(0xFFF97316),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'XP Earned',
                        value: '+${widget.xpEarned} XP',
                        caption: '누적 $_totalXp XP',
                        icon: Icons.star_rounded,
                        iconColor: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineBtn(
                        label: '다시하기',
                        onPressed: _retry,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _GradientBtn(
                        label: nextButtonLabel,
                        onPressed: _hasNext ? _goNext : _goHome,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _OutlineBtn(
                  label: '홈으로 가기',
                  onPressed: _goHome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value, $caption',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientBtn({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22006CC3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineBtn({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: 58,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: Color(0xFF2563EB),
              width: 1.8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            backgroundColor: Colors.white,
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ),
    );
  }
}