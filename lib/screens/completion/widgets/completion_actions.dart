import 'dart:async';

import 'package:flutter/material.dart';

/// 완료 화면 하단 액션 영역
///
/// 홈 이동 / 다음 단계 이동 버튼만 담당
/// 실제 이동 로직은 상위 화면에서 주입
class CompletionActions extends StatelessWidget {
  final bool hasNext;
  final bool isBusy;
  final Future<void> Function() onHome;
  final Future<void> Function() onNext;

  const CompletionActions({
    super.key,
    required this.hasNext,
    required this.isBusy,
    required this.onHome,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final canMoveNext = hasNext && !isBusy;

    return Row(
      children: [
        Expanded(
          child: _OutlineActionButton(
            label: '홈으로',
            onPressed: isBusy ? null : () => unawaited(onHome()),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _GradientActionButton(
            label: hasNext ? '다음 단계' : '다음 단계 없음',
            onPressed: canMoveNext ? () => unawaited(onNext()) : null,
          ),
        ),
      ],
    );
  }
}

/// 완료 화면 주요 액션 버튼
///
/// disabled 상태에서도 같은 크기 유지
class _GradientActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _GradientActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(28),
          boxShadow: enabled
              ? const [
                  BoxShadow(
                    color: Color(0x22006CC3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: enabled ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

/// 완료 화면 보조 액션 버튼
///
/// 홈 이동처럼 보조 성격의 액션에 사용
class _OutlineActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _OutlineActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: SizedBox(
        height: 58,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: enabled ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
              width: 1.8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            backgroundColor: Colors.white,
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: enabled ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}