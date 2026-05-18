import 'package:flutter/material.dart';
import 'package:puzzle_dot/services/app_tts_service.dart';
import 'package:puzzle_dot/services/permission_service.dart';

class CameraPermissionView extends StatefulWidget {
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const CameraPermissionView({
    super.key,
    required this.onRetry,
    required this.onHome,
  });

  @override
  State<CameraPermissionView> createState() => _CameraPermissionViewState();
}

class _CameraPermissionViewState extends State<CameraPermissionView> {
  final AppTtsService _tts = AppTtsService();

  static const String _message =
      '카메라 권한이 필요합니다. 설정에서 카메라 권한을 허용해주세요.';

  @override
  void initState() {
    super.initState();
    _tts.speak(_message);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _openSettings() async {
    await PermissionService.openSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 72,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 28),
          const Text(
            '카메라 권한이 필요합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '점자 학습을 위해 카메라 접근 권한이 필요합니다.\n설정에서 카메라 권한을 허용해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          Semantics(
            button: true,
            label: '설정으로 이동',
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _openSettings,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  '설정으로 이동',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Semantics(
            button: true,
            label: '카메라 권한 다시 확인',
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: widget.onRetry,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  '다시 확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Semantics(
            button: true,
            label: '홈으로 돌아가기',
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: widget.onHome,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  '홈으로 돌아가기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  void _goHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CameraPermissionView(
          onRetry: () => Navigator.pop(context),
          onHome: () => _goHome(context),
        ),
      ),
    );
  }
}