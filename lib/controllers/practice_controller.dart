import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:puzzle_dot/models/camera_capture_result.dart';
import 'package:puzzle_dot/services/camera_service.dart';
import 'package:puzzle_dot/services/permission_service.dart';

enum PracticeCameraStatus {
  permissionRequired,
  checking,
  permissionDenied,
  unavailable,
  ready,
}

/// Practice 화면 상태 컨트롤러
///
/// 역할:
/// - 카메라 권한 확인 전/중/거절 상태 관리
/// - 카메라 없음/준비 완료 상태 관리
/// - 촬영 요청 처리
///
/// UI는 CameraService, PermissionService 직접 호출하지 않음
class PracticeController extends ChangeNotifier {
  final CameraService _cameraService;

  PracticeController({
    CameraService? cameraService,
  }) : _cameraService = cameraService ?? CameraService();

  PracticeCameraStatus _status = PracticeCameraStatus.permissionRequired;
  bool _isPreparing = false;
  bool _isCapturing = false;
  CameraCaptureResult? _lastCaptureResult;

  PracticeCameraStatus get status => _status;
  bool get isPreparing => _isPreparing;
  bool get isCapturing => _isCapturing;
  CameraController? get cameraController => _cameraService.controller;
  CameraCaptureResult? get lastCaptureResult => _lastCaptureResult;

  /// 권한 확인 후 카메라 준비
  ///
  /// 사용자가 확인/다시 확인 버튼을 눌렀을 때만 호출
  Future<void> prepare() async {
    if (_isPreparing) return;

    _isPreparing = true;
    _setStatus(PracticeCameraStatus.checking);

    final granted = await PermissionService.requestCamera();
    if (!granted) {
      _isPreparing = false;
      _setStatus(PracticeCameraStatus.permissionDenied);
      return;
    }

    final initialized = await _cameraService.initialize();
    _isPreparing = false;

    if (!initialized) {
      _setStatus(PracticeCameraStatus.unavailable);
      return;
    }

    _setStatus(PracticeCameraStatus.ready);
  }

  /// 카메라 촬영
  ///
  /// 성공 시 imagePath 반환
  /// 실패 시 실패 메시지 반환
  Future<CameraCaptureResult> capture() async {
    if (_isCapturing) {
      return CameraCaptureResult.failure('이미 촬영 중입니다.');
    }

    _isCapturing = true;
    notifyListeners();

    final imagePath = await _cameraService.capture();

    _isCapturing = false;

    if (imagePath == null) {
      _lastCaptureResult = CameraCaptureResult.failure(
        '촬영에 실패했습니다. 다시 시도해주세요.',
      );
      notifyListeners();
      return _lastCaptureResult!;
    }

    _lastCaptureResult = CameraCaptureResult.success(imagePath);
    notifyListeners();

    return _lastCaptureResult!;
  }

  void _setStatus(PracticeCameraStatus nextStatus) {
    if (_status == nextStatus) return;

    _status = nextStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}