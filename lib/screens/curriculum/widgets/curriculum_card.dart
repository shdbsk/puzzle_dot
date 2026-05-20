import 'package:flutter/material.dart';
import 'package:puzzle_dot/models/curriculum_item.dart';

/// 커리큘럼 항목 카드
///
/// 역할:
/// - 학습 항목 표시
/// - 완료 상태 표시
/// - 카드 선택 이벤트 전달
/// - 접근성 label 제공
///
/// 학습 화면 이동 로직은 상위 화면이 담당
class CurriculumCard extends StatelessWidget {
  final CurriculumItem item;
  final int index;
  final int totalCount;
  final bool isCompleted;
  final VoidCallback onTap;

  const CurriculumCard({
    super.key,
    required this.item,
    required this.index,
    required this.totalCount,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleOrder = index + 1;

    return Semantics(
      button: true,
      label:
          '$visibleOrder번째 학습 ${item.character}, ${isCompleted ? '완료됨' : '미완료'}',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StepBadge(order: visibleOrder),
                    const Spacer(),
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isCompleted
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.character,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.35,
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

class _StepBadge extends StatelessWidget {
  final int order;

  const _StepBadge({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$order',
        style: const TextStyle(
          color: Color(0xFF2563EB),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}