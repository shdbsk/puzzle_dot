import 'package:flutter/material.dart';
import 'package:puzzle_dot/models/curriculum_item.dart';

/// 학습 목표 카드
///
/// 역할:
/// - 현재 학습 항목 표시
/// - 설명 문구 표시
/// - 접근성 label 제공
///
/// 학습 흐름과 분석 로직을 알지 않음
class LearningGoalCard extends StatelessWidget {
  final CurriculumItem item;

  const LearningGoalCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${item.character} 학습 목표',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0E000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              '학습 목표',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF1D6FA8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.character,
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}