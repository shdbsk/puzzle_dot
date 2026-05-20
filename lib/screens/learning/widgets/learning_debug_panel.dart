import 'dart:async';

import 'package:flutter/material.dart';

/// 학습 결과 테스트용 debug 패널
///
/// 역할:
/// - 실제 학습 UI와 mock 테스트 UI 분리
/// - 정답/오답/미완료 흐름 수동 확인
/// - kDebugMode 조건은 사용하는 화면에서 판단
///
/// 배포 전 제거 또는 비활성화하기 쉬운 구조
class LearningDebugPanel extends StatelessWidget {
  final Future<void> Function() onCorrect;
  final Future<void> Function() onIncorrect;
  final Future<void> Function() onIncomplete;

  const LearningDebugPanel({
    super.key,
    required this.onCorrect,
    required this.onIncorrect,
    required this.onIncomplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '개발 테스트',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DebugButton(
                label: '정답',
                onPressed: onCorrect,
              ),
              _DebugButton(
                label: '오답',
                onPressed: onIncorrect,
              ),
              _DebugButton(
                label: '미완료',
                onPressed: onIncomplete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebugButton extends StatelessWidget {
  final String label;
  final Future<void> Function() onPressed;

  const _DebugButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => unawaited(onPressed()),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF92400E),
        side: const BorderSide(
          color: Color(0xFFF59E0B),
        ),
      ),
      child: Text(label),
    );
  }
}