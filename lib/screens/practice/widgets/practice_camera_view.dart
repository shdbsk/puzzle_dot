import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Practice 카메라 프리뷰 화면
///
/// 역할:
/// - 카메라 프리뷰 표시
/// - 촬영 버튼 표시
/// - 촬영 중 버튼 상태 표시
///
/// 카메라 초기화/촬영 로직은 PracticeController가 담당
class PracticeCameraView extends StatelessWidget {
  final CameraController? cameraController;
  final bool isCapturing;
  final Future<void> Function() onCapture;

  const PracticeCameraView({
    super.key,
    required this.cameraController,
    required this.isCapturing,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final controller = cameraController;

    return Container(
      key: const ValueKey('practice_camera'),
      color: const Color(0xFF0D1117),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                '카메라 학습',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                '점자판을 화면 중앙에 맞춘 뒤 촬영해주세요',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B949E),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: const Color(0xFF161B22),
                    child: controller == null
                        ? const _CameraPreviewFallback()
                        : CameraPreview(controller),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: isCapturing ? null : onCapture,
                  icon: isCapturing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    isCapturing ? '촬영 중...' : '촬영하기',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AEEF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF1F6FEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraPreviewFallback extends StatelessWidget {
  const _CameraPreviewFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: Color(0xFF30363D),
          ),
          SizedBox(height: 16),
          Text(
            '카메라 화면을 준비하고 있습니다',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8B949E),
            ),
          ),
        ],
      ),
    );
  }
}