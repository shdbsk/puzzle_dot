import 'package:flutter/material.dart';

/// 커리큘럼 진행률 헤더
///
/// 역할:
/// - 레벨 진행률 표시
/// - 완료 개수/전체 개수 표시
/// - 다시 듣기 버튼 표시
/// - 접근성 label 제공
///
/// TTS 실행 로직은 화면에서 주입
class CurriculumProgressHeader extends StatelessWidget {
  final String levelTitle;
  final int completedCount;
  final int totalCount;
  final double progressRatio;
  final bool isSpeaking;
  final Future<void> Function() onReplay;

  const CurriculumProgressHeader({
    super.key,
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
                onPressed: () => onReplay(),
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
                    borderRadius: BorderRadius.circular(16),
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