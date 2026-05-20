import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puzzle_dot/controllers/practice_controller.dart';
import 'package:puzzle_dot/models/learning_capture_source.dart';
import 'package:puzzle_dot/screens/practice/permission_screen.dart';
import 'package:puzzle_dot/screens/practice/widgets/camera_unavailable_view.dart';
import 'package:puzzle_dot/screens/practice/widgets/practice_camera_view.dart';
import 'package:puzzle_dot/screens/practice/widgets/practice_loading_view.dart';
import 'package:puzzle_dot/services/tts/app_tts_service.dart';
import 'package:puzzle_dot/services/tts/tts_script_provider.dart';

class PracticeScreen extends StatefulWidget {
  final VoidCallback? onHome;

  const PracticeScreen({
    super.key,
    this.onHome,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final PracticeController _controller;
  final AppTtsService _tts = AppTtsService();

  PracticeCameraStatus? _lastSpokenStatus;

  @override
  void initState() {
    super.initState();

    _controller = PracticeController();
    _controller.addListener(_handleControllerChanged);

    /// 권한 확인은 자동 실행하지 않음
    ///
    /// 사용자가 확인 버튼을 눌렀을 때만 카메라 권한 확인 시작
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    unawaited(_tts.stop());
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) return;

    setState(() {});

    final status = _controller.status;
    if (_lastSpokenStatus == status) return;

    _lastSpokenStatus = status;

    switch (status) {
      case PracticeCameraStatus.ready:
        unawaited(_tts.speak(TtsScriptProvider.cameraReady));
        break;

      case PracticeCameraStatus.unavailable:
        unawaited(_tts.speak(TtsScriptProvider.cameraUnavailable));
        break;

      case PracticeCameraStatus.permissionRequired:
      case PracticeCameraStatus.checking:
      case PracticeCameraStatus.permissionDenied:
        /// 권한 관련 TTS는 CameraPermissionView에서만 담당
        break;
    }
  }

  Future<void> _confirmCameraPermission() async {
    _lastSpokenStatus = null;
    await _controller.prepare();
  }

  Future<void> _capture() async {
    await _tts.speak(TtsScriptProvider.capturing);

    final captureResult = await _controller.capture();
    if (!mounted) return;

    if (!captureResult.isSuccess || captureResult.imagePath == null) {
      await _tts.speak(
        captureResult.message ?? TtsScriptProvider.captureFailed,
      );
      return;
    }

    final source = LearningCaptureSource.camera(captureResult.imagePath!);

    /// TODO: 학습 단계 정보 연결 후 ActiveLearning 분석 흐름으로 전달
    ///
    /// 현재 Practice 탭은 특정 CurriculumItem을 알지 못함
    /// 추후 item/level 정보가 주입되면 ActiveLearningController.analyzeCapture(source)로 연결
    await _tts.speak(TtsScriptProvider.analyzing);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          source.isCamera
              ? '촬영 이미지를 준비했습니다. 학습 분석 연결은 다음 단계에서 진행합니다.'
              : '테스트 이미지를 준비했습니다.',
        ),
      ),
    );
  }

  void _goHome() {
    if (widget.onHome != null) {
      widget.onHome!();
      return;
    }

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_controller.status) {
      case PracticeCameraStatus.permissionRequired:
        return CameraPermissionView(
          isRetry: false,
          onConfirm: _confirmCameraPermission,
          onHome: _goHome,
        );

      case PracticeCameraStatus.checking:
        return const PracticeLoadingView();

      case PracticeCameraStatus.permissionDenied:
        return CameraPermissionView(
          isRetry: true,
          onConfirm: _confirmCameraPermission,
          onHome: _goHome,
        );

      case PracticeCameraStatus.unavailable:
        return CameraUnavailableView(
          onRetry: _confirmCameraPermission,
          onHome: _goHome,
        );

      case PracticeCameraStatus.ready:
        return PracticeCameraView(
          cameraController: _controller.cameraController,
          isCapturing: _controller.isCapturing,
          onCapture: _capture,
        );
    }
  }
}