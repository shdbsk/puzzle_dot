import 'package:flutter/material.dart';

/// 학습 이미지 분석 버튼
///
/// 역할:
/// - 분석 시작 버튼 표시
/// - 분석 중 로딩 상태 표시
///
/// 이미지 선택/분석 로직은 화면/controller가 담당
class AnalyzeButton extends StatelessWidget {
  final bool isAnalyzing;
  final Future<void> Function() onPressed;

  const AnalyzeButton({
    super.key,
    required this.isAnalyzing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isAnalyzing ? null : onPressed,
        icon: isAnalyzing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1D4ED8),
                ),
              )
            : const Icon(Icons.image_outlined),
        label: Text(
          isAnalyzing ? '분석 중...' : '테스트 이미지 업로드',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1D4ED8),
          disabledBackgroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF1D4ED8),
          side: const BorderSide(
            color: Color(0xFFBFD7F7),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}