import 'dart:async';

import 'package:flutter/material.dart';

/// 완료 화면 상단 액션 바
///
/// 현재 문제 다시하기 버튼만 담당
/// 실제 다시하기 이동 로직은 상위 화면에서 주입
class CompletionTopBar extends StatelessWidget {
  final Future<void> Function() onRetry;

  const CompletionTopBar({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: '현재 문제 다시하기',
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => unawaited(onRetry()),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.refresh,
              size: 22,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ),
    );
  }
}