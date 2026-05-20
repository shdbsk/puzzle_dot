import 'package:flutter/material.dart';
import 'package:puzzle_dot/models/home_learning_level.dart';

/// 홈 레벨 카드
///
/// 역할:
/// - 레벨 제목/설명 표시
/// - 잠금 상태 표시
/// - 진행률 표시
/// - 선택 이벤트 전달
///
/// 잠금 조건과 화면 이동은 HomeScreen이 담당
class HomeLevelCard extends StatelessWidget {
  final HomeLearningLevel level;
  final double progress;
  final bool isUnlocked;
  final VoidCallback onTap;

  const HomeLevelCard({
    super.key,
    required this.level,
    required this.progress,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress * 100).round();

    return Semantics(
      button: isUnlocked,
      label: '${level.title} ${isUnlocked ? '진행률 $progressPercent퍼센트' : '잠금됨'}',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: isUnlocked ? onTap : null,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
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
                        level.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Icon(
                      isUnlocked ? Icons.check_circle : Icons.lock,
                      size: 18,
                      color: isUnlocked
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  level.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: isUnlocked ? progress : 0,
                    minHeight: 10,
                    color: isUnlocked
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
                      isUnlocked ? '$progressPercent% 완료' : '잠금됨',
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnlocked
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      isUnlocked ? Icons.arrow_forward_ios : Icons.lock,
                      size: 14,
                      color: isUnlocked
                          ? const Color(0xFF00AEEF)
                          : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}