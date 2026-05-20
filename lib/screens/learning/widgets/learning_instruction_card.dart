import 'package:flutter/material.dart';

/// 학습 안내 카드
///
/// 역할:
/// - 학습 이미지 업로드 전 안내 표시
/// - UI 문구와 스타일만 담당
///
/// 분석 로직과 TTS 실행은 화면/controller가 담당
class LearningInstructionCard extends StatelessWidget {
  const LearningInstructionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF1D6FA8),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '점자판에 위 문자를 만든 후 이미지를 업로드하세요.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1D4ED8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}