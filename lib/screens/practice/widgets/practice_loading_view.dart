import 'package:flutter/material.dart';

/// Practice 카메라 준비 중 화면
///
/// 역할:
/// - 카메라 권한/초기화 확인 중 상태 표시
/// - 로딩 UI만 담당
///
/// 권한 확인과 카메라 초기화는 PracticeController가 담당
class PracticeLoadingView extends StatelessWidget {
  const PracticeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('practice_loading'),
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Semantics(
          label: '카메라 준비 중',
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 18),
              Text(
                '카메라를 준비하고 있습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}