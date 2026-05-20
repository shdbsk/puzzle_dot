import 'package:flutter/material.dart';

/// 학습 진행률 헤더
///
/// 역할:
/// - 현재 학습 순서 표시
/// - 전체 학습 개수 대비 진행률 표시
/// - 접근성 label 제공
///
/// 진행률 계산 정책 변경 시 이 위젯만 수정
class LearningProgressHeader extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const LearningProgressHeader({
    super.key,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final current = currentIndex + 1;
    final progressValue = totalCount == 0 ? 0.0 : currentIndex / totalCount;

    return Semantics(
      label: '학습 진행률 $current / $totalCount',
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 10,
                color: const Color(0xFF00AEEF),
                backgroundColor: const Color(0xFFDCEBFA),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$currentIndex/$totalCount 완료',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
  }
}