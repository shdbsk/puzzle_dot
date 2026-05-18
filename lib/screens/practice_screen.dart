import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:puzzle_dot/services/app_tts_service.dart';
import 'package:puzzle_dot/services/camera_service.dart';
import 'package:puzzle_dot/services/permission_service.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final CameraService _cameraService = CameraService();
  final AppTtsService _tts = AppTtsService();

  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isCameraReady = false;
  bool _isCapturing = false;
  String _statusMessage = '카메라를 준비하고 있습니다.';

  @override
  void initState() {
    super.initState();
    _prepareCamera();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _prepareCamera() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '카메라 권한을 확인하고 있습니다.';
    });

    final granted = await PermissionService.requestCamera();

    if (!mounted) return;

    if (!granted) {
      setState(() {
        _isLoading = false;
        _hasPermission = false;
        _isCameraReady = false;
        _statusMessage = '카메라 권한이 필요합니다.';
      });

      await _tts.speak('카메라 권한이 필요합니다. 설정에서 카메라 권한을 허용해주세요.');
      return;
    }

    setState(() {
      _hasPermission = true;
      _statusMessage = '카메라를 초기화하고 있습니다.';
    });

    final initialized = await _cameraService.initialize();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isCameraReady = initialized;
      _statusMessage = initialized
          ? '점자판을 화면 중앙에 맞춘 뒤 촬영 버튼을 눌러주세요.'
          : '이 기기에서는 카메라를 사용할 수 없습니다.';
    });

    if (initialized) {
      await _tts.speak('점자판을 화면 중앙에 맞춘 뒤 촬영 버튼을 눌러주세요.');
    } else {
      await _tts.speak('이 기기에서는 카메라를 사용할 수 없습니다. 실제 기기에서 다시 확인해주세요.');
    }
  }

  Future<void> _captureImage() async {
    if (!_isCameraReady || _isCapturing) return;

    setState(() {
      _isCapturing = true;
      _statusMessage = '촬영 중입니다.';
    });

    await _tts.speak('촬영 중입니다.');

    final path = await _cameraService.capture();

    if (!mounted) return;

    setState(() {
      _isCapturing = false;
      _statusMessage = path == null
          ? '촬영에 실패했습니다. 다시 시도해주세요.'
          : '촬영이 완료되었습니다. 분석 기능은 다음 단계에서 연결합니다.';
    });

    await _tts.speak(_statusMessage);
  }

  Future<void> _openSettings() async {
    await PermissionService.openSettings();
  }

  Widget _buildPermissionView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 72,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 24),
          const Text(
            '카메라 권한이 필요합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '점자판을 촬영하려면 카메라 접근 권한이 필요합니다.\n설정에서 카메라 권한을 허용해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Semantics(
            button: true,
            label: '설정으로 이동',
            child: ElevatedButton(
              onPressed: _openSettings,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
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
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label: '다시 확인',
            child: OutlinedButton(
              onPressed: _prepareCamera,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
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
        ],
      ),
    );
  }

  Widget _buildUnavailableView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.videocam_off_outlined,
            size: 72,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 24),
          const Text(
            '카메라를 사용할 수 없습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'iOS 시뮬레이터나 카메라가 없는 환경에서는 프리뷰가 표시되지 않을 수 있습니다.\n실제 기기에서 다시 확인해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Semantics(
            button: true,
            label: '카메라 다시 준비',
            child: ElevatedButton(
              onPressed: _prepareCamera,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                '다시 시도',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraService.controller;

    if (controller == null || !controller.value.isInitialized) {
      return _buildUnavailableView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(controller),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isCapturing
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF00AEEF),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  const Center(
                    child: _FocusGuide(),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(150),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Semantics(
            button: true,
            label: '점자판 촬영하기',
            child: SizedBox(
              height: 64,
              child: ElevatedButton.icon(
                onPressed: _isCapturing ? null : _captureImage,
                icon: Icon(
                  _isCapturing
                      ? Icons.hourglass_top
                      : Icons.camera_alt_rounded,
                ),
                label: Text(
                  _isCapturing ? '촬영 중...' : '촬영하기',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Semantics(
          label: _statusMessage,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionView();
    }

    if (!_isCameraReady) {
      return _buildUnavailableView();
    }

    return _buildCameraPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F6FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Text(
              '카메라 학습 인터페이스',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 6, 20, 8),
            child: Text(
              '점자판을 화면 중앙에 맞추고 촬영해 주세요.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}

class _FocusGuide extends StatelessWidget {
  const _FocusGuide();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 220,
        height: 220,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Center(
            child: Text(
              '점자판 위치',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}