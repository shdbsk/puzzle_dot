import 'package:flutter/material.dart';
import 'package:puzzle_dot/data/curriculum_data.dart';
import 'package:puzzle_dot/models/curriculum_item.dart';
import 'package:puzzle_dot/screens/active_learning_screen.dart';
import 'package:puzzle_dot/services/app_tts_service.dart';
import 'package:puzzle_dot/services/progress_service.dart';

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
    return curriculumData[widget.levelId] ?? [];
  }

  String get _guideMessage {
    return '${widget.levelTitle} 학습 단계입니다. 학습할 항목을 선택하세요.';
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakGuide();
    });
  }

  @override
  void dispose() {
    _tts.stop();
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
    await Future.delayed(const Duration(milliseconds: 1600));

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
              onPressed: _speakGuide,
              icon: Icon(_isSpeaking ? Icons.volume_up : Icons.replay),
              tooltip: '다시 듣기',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ProgressHeader(
              levelTitle: widget.levelTitle,
              completedCount: completedCount,
              totalCount: items.length,
              progressRatio: ratio,
              isSpeaking: _isSpeaking,
              onReplay: _speakGuide,
            ),
            Expanded(
              child: items.isEmpty
                  ? const _EmptyCurriculumView()
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

                        return _CurriculumCard(
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

class _ProgressHeader extends StatelessWidget {
  final String levelTitle;
  final int completedCount;
  final int totalCount;
  final double progressRatio;
  final bool isSpeaking;
  final VoidCallback onReplay;

  const _ProgressHeader({
    required this.levelTitle,
    required this.completedCount,
    required this.totalCount,
    required this.progressRatio,
    required this.isSpeaking,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '$levelTitle, 전체 $totalCount개 중 $completedCount개 완료, 진행률 ${(progressRatio * 100).round()}퍼센트',
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$completedCount/$totalCount 완료',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Text(
                  '${(progressRatio * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressRatio,
                minHeight: 9,
                color: const Color(0xFF00AEEF),
                backgroundColor: const Color(0xFFE2E8F0),
              ),
            ),
            const SizedBox(height: 14),
            Semantics(
              button: true,
              label: '학습 단계 안내 다시 듣기',
              child: OutlinedButton.icon(
                onPressed: onReplay,
                icon: Icon(isSpeaking ? Icons.volume_up : Icons.replay),
                label: Text(isSpeaking ? '음성 안내 중...' : '다시 듣기'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(
                    color: Color(0xFFBFD7F7),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurriculumCard extends StatelessWidget {
  final CurriculumItem item;
  final int index;
  final int totalCount;
  final bool isCompleted;
  final VoidCallback onTap;

  const _CurriculumCard({
    required this.item,
    required this.index,
    required this.totalCount,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reading = item.reading.isEmpty ? item.description : item.reading;

    return Semantics(
      button: true,
      label:
          '${index + 1}번째 학습, ${item.character}, $reading, ${isCompleted ? '완료됨' : '미완료'}',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFE2E8F0),
                width: 1.4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      '${index + 1}/$totalCount',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.arrow_forward_ios,
                      size: isCompleted ? 20 : 16,
                      color: isCompleted
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const Spacer(),
                Center(
                  child: Text(
                    item.character,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: item.character.length > 3 ? 26 : 38,
                      fontWeight: FontWeight.w900,
                      color: isCompleted
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  reading,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  isCompleted ? '완료' : '학습하기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
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

class _EmptyCurriculumView extends StatelessWidget {
  const _EmptyCurriculumView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '등록된 학습 항목이 없습니다.',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}