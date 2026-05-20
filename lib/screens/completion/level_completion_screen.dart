import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puzzle_dot/models/curriculum_item.dart';
import 'package:puzzle_dot/screens/completion/widgets/completion_actions.dart';
import 'package:puzzle_dot/screens/completion/widgets/completion_card.dart';
import 'package:puzzle_dot/screens/completion/widgets/completion_stat_card.dart';
import 'package:puzzle_dot/screens/completion/widgets/completion_top_bar.dart';
import 'package:puzzle_dot/screens/learning/active_learning_screen.dart';
import 'package:puzzle_dot/services/learning_navigation_service.dart';
import 'package:puzzle_dot/services/streak_service.dart';
import 'package:puzzle_dot/services/tts/app_tts_service.dart';
import 'package:puzzle_dot/services/tts/tts_script_provider.dart';
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
  bool _isLeavingScreen = false;
  bool _isActionBusy = false;
  int _streak = 0;
  int _totalXp = 0;

  bool get _hasNext {
    return LearningNavigationService.hasNext(
      items: widget.allItems,
      currentIndex: widget.currentIndex,
    );
  }

  CurriculumItem? get _currentItem {
    return LearningNavigationService.getCurrentItem(
      items: widget.allItems,
      currentIndex: widget.currentIndex,
    );
  }

  String get _completedItemLabel {
    return TtsScriptProvider.spokenItemName(widget.itemName);
  }

  @override
  void initState() {
    super.initState();

    /// 완료 화면 진입 후 통계 로드와 TTS 실행
    ///
    /// 이전 학습 화면에서 완료 TTS를 말하지 않음
    /// 완료 화면이 그려진 뒤 현재 화면이 음성 안내 담당
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadStatsAndSpeakAfterRouteSettled());
    });
  }

  @override
  void dispose() {
    /// 다른 화면으로 이동 중인 dispose에서는 stop 중복 호출 방지
    ///
    /// 다음 학습 화면 진입 직후 TTS가 끊기는 현상 완화
    if (!_isLeavingScreen) {
      unawaited(_tts.stop());
    }

    super.dispose();
  }

  /// 완료 화면 진입 직후 TTS 시작 지연
  ///
  /// 이전 학습 화면 dispose/stop과 완료 화면 speak가 겹치지 않게 함
  Future<void> _loadStatsAndSpeakAfterRouteSettled() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted || _isLeavingScreen) return;

    await _loadStatsAndSpeak();
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

    final message = TtsScriptProvider.completion(
      itemName: widget.itemName,
      xpEarned: widget.xpEarned,
    );

    await _tts.speak(message);

    if (!mounted) return;

    setState(() => _isSpeaking = false);
  }

  Future<void> _stopSpeaking() async {
    await _tts.stop();

    if (!mounted) return;

    setState(() => _isSpeaking = false);
  }

  Future<void> _goHome() async {
    if (_isActionBusy) return;

    setState(() => _isActionBusy = true);

    await _stopSpeaking();

    if (!mounted) return;

    _isLeavingScreen = true;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _goNext() async {
    if (_isActionBusy) return;

    setState(() => _isActionBusy = true);

    await _stopSpeaking();

    final nextItem = LearningNavigationService.getNextItem(
      items: widget.allItems,
      currentIndex: widget.currentIndex,
    );

    final nextIndex = LearningNavigationService.getNextIndex(
      items: widget.allItems,
      currentIndex: widget.currentIndex,
    );

    final allItems = widget.allItems;

    if (nextItem == null || nextIndex == null || allItems == null) {
      if (mounted) {
        setState(() => _isActionBusy = false);
      }
      return;
    }

    if (!mounted) return;

    _isLeavingScreen = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveLearningScreen(
          item: nextItem,
          levelId: widget.levelId,
          levelName: widget.levelName,
          allItems: allItems,
          currentIndex: nextIndex,
        ),
      ),
    );
  }

  Future<void> _retryCurrentItem() async {
    if (_isActionBusy) return;

    setState(() => _isActionBusy = true);

    await _stopSpeaking();

    final currentItem = _currentItem;
    final currentIndex = widget.currentIndex;
    final allItems = widget.allItems;

    if (currentItem == null || currentIndex == null || allItems == null) {
      if (!mounted) return;

      _isLeavingScreen = true;
      Navigator.pop(context);
      return;
    }

    if (!mounted) return;

    _isLeavingScreen = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveLearningScreen(
          item: currentItem,
          levelId: widget.levelId,
          levelName: widget.levelName,
          allItems: allItems,
          currentIndex: currentIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, __) {
        unawaited(_tts.stop());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F6FF),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CompletionTopBar(
                  onRetry: _retryCurrentItem,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CompletionCard(
                          completedItemLabel: _completedItemLabel,
                          isSpeaking: _isSpeaking,
                          onReplay: _speak,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CompletionStatCard(
                                label: 'Daily Streak',
                                value: '$_streak Days',
                                caption: '연속 학습일',
                                icon: Icons.local_fire_department,
                                iconColor: Color(0xFFF97316),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CompletionStatCard(
                                label: 'XP Earned',
                                value: '+${widget.xpEarned} XP',
                                caption: '누적 $_totalXp XP',
                                icon: Icons.star_rounded,
                                iconColor: Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CompletionActions(
                  hasNext: _hasNext,
                  isBusy: _isActionBusy,
                  onHome: _goHome,
                  onNext: _goNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}