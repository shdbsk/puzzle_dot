import 'package:flutter/material.dart';

/// 빈 커리큘럼 안내 화면
///
/// 역할:
/// - 학습 항목이 없는 상태 표시
/// - 사용자에게 현재 상태 안내
///
/// 데이터 로드와 라우팅은 상위 화면이 담당
class EmptyCurriculumView extends StatelessWidget {
  const EmptyCurriculumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: '등록된 학습 항목이 없습니다',
        child: Text(
          '등록된 학습 항목이 없습니다.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}