import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puzzle_dot/services/curriculum/curriculum_service.dart';
import 'package:puzzle_dot/models/curriculum_item.dart';
import 'package:puzzle_dot/screens/learning/active_learning_screen.dart';
import 'package:puzzle_dot/screens/curriculum/widgets/curriculum_card.dart';
import 'package:puzzle_dot/screens/curriculum/widgets/curriculum_progress_header.dart';
import 'package:puzzle_dot/screens/curriculum/widgets/empty_curriculum_view.dart';
import 'package:puzzle_dot/services/progress_service.dart';
import 'package:puzzle_dot/services/tts/app_tts_service.dart';
import 'package:puzzle_dot/services/tts/tts_script_provider.dart';

class CurriculumSelectionScreen extends StatefulWidget {
  final String levelId;
  final String levelTitle;

  const CurriculumSelectionScreen({
    super.key,
    required this.levelId,
    required this.levelTitle,
  });

  @override
  State<CurriculumSelectionScreen> createState() =>
      _CurriculumSelectionScreenState();
}

class _CurriculumSelectionScreenState extends State<CurriculumSelectionScreen> {
  final AppTtsService _tts = AppTtsService();

  Set<String> _completedIds = {};
  bool _isSpeaking = false;

  List<CurriculumItem> get _items {
    return CurriculumService.getItemsByLevel(widget.levelId);
  }

  /// 커리큘럼 선택 안내 문장
  ///
  /// 문장 조립은 TtsScriptProvider가 담당
  String get _guideMessage {
    return TtsScriptProvider.curriculumSelection(widget.levelTitle);
  }

  @override
  void initState() {
    super.initState();

    unawaited(_loadProgress());

    /// 화면 진입 후 안내 TTS 실행
    ///
    /// 문장 내용은 TtsScriptProvider에서 관리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_speakGuide());
    });
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final completed = await ProgressService.getCompletedIds(_items);

    if (!mounted) return;

    setState(() {
      _completedIds = completed;
    });
  }

  Future<void> _speakGuide() async {
    if (_isSpeaking) return;

    setState(() => _isSpeaking = true);

    await _tts.speak(_guideMessage);

    if (!mounted) return;

    setState(() => _isSpeaking = false);
  }

  Future<void> _openLearningItem(CurriculumItem item, int index) async {
    await _tts.stop();

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveLearningScreen(
          item: item,
          levelId: widget.levelId,
          levelName: widget.levelTitle,
          allItems: _items,
          currentIndex: index,
        ),
      ),
    );

    if (!mounted) return;

    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final completedCount = _completedIds.length;
    final ratio = items.isEmpty ? 0.0 : completedCount / items.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.levelTitle),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          Semantics(
            button: true,
            label: '학습 단계 안내 다시 듣기',
            child: IconButton(
              onPressed: () => unawaited(_speakGuide()),
              icon: Icon(_isSpeaking ? Icons.volume_up : Icons.replay),
              tooltip: '다시 듣기',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            CurriculumProgressHeader(
              levelTitle: widget.levelTitle,
              completedCount: completedCount,
              totalCount: items.length,
              progressRatio: ratio,
              isSpeaking: _isSpeaking,
              onReplay: _speakGuide,
            ),
            Expanded(
              child: items.isEmpty
                  ? const EmptyCurriculumView()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.92,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isCompleted = _completedIds.contains(item.id);

                        return CurriculumCard(
                          item: item,
                          index: index,
                          totalCount: items.length,
                          isCompleted: isCompleted,
                          onTap: () => _openLearningItem(item, index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}