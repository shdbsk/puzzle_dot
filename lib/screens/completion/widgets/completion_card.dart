import 'dart:async';

import 'package:flutter/material.dart';

/// 완료 화면 정답 카드
///
/// 정답 표시 / 완료 항목 / 다시 듣기 상태만 담당
/// TTS 문장 생성과 실행은 상위 화면에서 담당
class CompletionCard extends StatelessWidget {
  final String completedItemLabel;
  final bool isSpeaking;
  final Future<void> Function() onReplay;

  const CompletionCard({
    super.key,
    required this.completedItemLabel,
    required this.isSpeaking,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
              boxShadow: [
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
          if (completedItemLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '완료한 학습: $completedItemLabel',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (isSpeaking)
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
              onPressed: () => unawaited(onReplay()),
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
    );
  }
}