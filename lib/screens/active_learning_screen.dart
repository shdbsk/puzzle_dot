import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:puzzle_dot/models/curriculum_item.dart';
import 'package:puzzle_dot/screens/level_completion_screen.dart';
import 'package:puzzle_dot/screens/permission_screen.dart';
import 'package:puzzle_dot/services/app_tts_service.dart';
import 'package:puzzle_dot/services/camera_service.dart';
import 'package:puzzle_dot/services/hint_service.dart';
import 'package:puzzle_dot/services/permission_service.dart';
import 'package:puzzle_dot/services/progress_service.dart';
import 'package:puzzle_dot/services/xp_service.dart';

class ActiveLearningScreen extends StatefulWidget {
  final CurriculumItem item;
  final String levelId;
  final String levelName;
  final List<CurriculumItem> allItems;
  final int currentIndex;

  const ActiveLearningScreen({
    super.key,
    required this.item,
    required this.levelId,
    required this.levelName,
    required this.allItems,
    required this.currentIndex,
  });

  @override
  State<ActiveLearningScreen> createState() => _ActiveLearningScreenState();
}

class _ActiveLearningScreenState extends State<ActiveLearningScreen> {
  final CameraService _cameraService = CameraService();
  final AppTtsService _tts = AppTtsService();

  bool _isPreparing = true;
  bool _hasPermission = false;
  bool _isCameraReady = false;
  bool _isAnalyzing = false;
  bool _isSpeaking = false;
  int _wrongCount = 0;

  String _statusMessage = '카메라를 준비하고 있습니다.';

  String get _guideMessage {
    if (widget.item.ttsGuide.isNotEmpty) return widget.item.ttsGuide;
    return '이번 학습은 ${widget.item.character}, ${widget.item.description}입니다. 점자판을 완성한 뒤 촬영 버튼을 눌러주세요.';
  }

  double get _progressValue {
    if (widget.allItems.isEmpty) return 0;
    return (widget.currentIndex + 1) / widget.allItems.length;
  }

  String get _progressText {
    return '${widget.currentIndex + 1}/${widget.allItems.length}';
  }

  @override
  void initState() {
    super.initState();
    _prepareLearningCamera();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _prepareLearningCamera() async {
    setState(() {
      _isPreparing = true;
      _statusMessage = '카메라 권한을 확인하고 있습니다.';
    });

    final granted = await PermissionService.requestCamera();

    if (!mounted) return;

    if (!granted) {
      setState(() {
        _isPreparing = false;
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
      _isPreparing = false;
      _isCameraReady = initialized;
      _statusMessage = initialized
          ? '점자판을 화면 중앙에 맞춘 뒤 촬영 버튼을 눌러주세요.'
          : '이 기기에서는 카메라를 사용할 수 없습니다.';
    });

    if (initialized) {
      await _speakGuide();
    } else {
      await _tts.speak('이 기기에서는 카메라를 사용할 수 없습니다. 실제 기기에서 다시 확인해주세요.');
    }
  }

  Future<void> _speakGuide() async {
    if (_isSpeaking) return;

    if (mounted) setState(() => _isSpeaking = true);

    await _tts.speak(_guideMessage);
    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isCameraReady || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _statusMessage = '촬영 중입니다.';
    });

    await _tts.speak('촬영 중입니다.');

    final imagePath = await _cameraService.capture();

    if (!mounted) return;

    if (imagePath == null) {
      setState(() {
        _isAnalyzing = false;
        _statusMessage = '촬영에 실패했습니다. 다시 시도해주세요.';
      });

      await _tts.speak('촬영에 실패했습니다. 다시 시도해주세요.');
      return;
    }

    setState(() {
      _statusMessage = '분석 중입니다. 잠시 기다려주세요.';
    });

    await _tts.speak('분석 중입니다. 잠시 기다려주세요.');
    await _analyzeCapturedImage();
  }

  Future<void> _analyzeCapturedImage() async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final isCorrect = DateTime.now().millisecond.isOdd;

    if (isCorrect) {
      final isNewCompletion =
          await ProgressService.markCompleted(widget.item.id);
      final xpEarned = isNewCompletion ? XpService.xpPerItem : 0;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LevelCompletionScreen(
            levelId: widget.levelId,
            levelName: widget.levelName,
            itemName: widget.item.character,
            allItems: widget.allItems,
            currentIndex: widget.currentIndex,
            xpEarned: xpEarned,
          ),
        ),
      );

      return;
    }

    _wrongCount += 1;

    final hint = _buildWrongAnswerHint();

    setState(() {
      _isAnalyzing = false;
      _statusMessage = hint;
    });

    await _tts.speak(hint);

    if (!mounted) return;
    _showFailureDialog(hint);
  }

  String _buildWrongAnswerHint() {
    final answerVector = _parseFirstDotVector(widget.item.dotPattern);

    if (answerVector == null) {
      if (_wrongCount >= 3) {
        return '계속 어려우신가요? 정답 안내를 다시 듣고 천천히 시도해보세요.';
      }

      return '오답입니다. 점자판을 다시 확인한 뒤 한 번 더 촬영해주세요.';
    }

    final mockResultVector = _createMockResultVector(answerVector);

    return HintService.generateHint(
      answer: answerVector,
      result: mockResultVector,
      wrongCount: _wrongCount,
    );
  }

  List<int>? _parseFirstDotVector(String dotPattern) {
    final match = RegExp(r'\[([0-9,\s]+)\]').firstMatch(dotPattern);
    if (match == null) return null;

    final values = match
        .group(1)!
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .toList();

    if (values.length != 6 || values.any((value) => value == null)) {
      return null;
    }

    return values.cast<int>();
  }

  List<int> _createMockResultVector(List<int> answerVector) {
    final result = List<int>.from(answerVector);
    final index = (_wrongCount - 1) % result.length;
    result[index] = result[index] == 1 ? 0 : 1;
    return result;
  }

  Future<void> _openSettings() async {
    await PermissionService.openSettings();
  }

  void _showFailureDialog(String hint) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '다시 시도해 보세요',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(hint),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _speakGuide();
            },
            child: const Text('안내 다시 듣기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

    Widget _buildPermissionView() {
    return CameraPermissionView(
      onRetry: _prepareLearningCamera,
      onHome: () => Navigator.popUntil(context, (route) => route.isFirst),
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
            '시뮬레이터나 카메라가 없는 환경에서는 프리뷰가 표시되지 않을 수 있습니다.\n실제 기기에서 다시 확인해주세요.',
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
              onPressed: _prepareLearningCamera,
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

  Widget _buildLearningHeader() {
    final item = widget.item;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _progressText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    minHeight: 8,
                    color: const Color(0xFF00AEEF),
                    backgroundColor: const Color(0xFFDCEBFA),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.character,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.reading.isEmpty ? item.description : item.reading,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.goal.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.goal,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label: '학습 안내 다시 듣기',
            child: OutlinedButton.icon(
              onPressed: _isAnalyzing ? null : _speakGuide,
              icon: Icon(_isSpeaking ? Icons.volume_up : Icons.replay),
              label: Text(_isSpeaking ? '음성 안내 중...' : '다시 듣기'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(
                  color: Color(0xFFBFD7F7),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    final controller = _cameraService.controller;

    if (controller == null || !controller.value.isInitialized) {
      return _buildUnavailableView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: _buildLearningHeader(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(controller),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isAnalyzing
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF00AEEF),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  const Center(child: _FocusGuide()),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
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
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (_isAnalyzing)
                    Container(
                      color: Colors.black.withAlpha(90),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 14),
                            Text(
                              '분석 중...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Semantics(
            button: true,
            label: '점자판 촬영하기',
            child: SizedBox(
              height: 62,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _captureAndAnalyze,
                icon: Icon(
                  _isAnalyzing
                      ? Icons.hourglass_top
                      : Icons.camera_alt_rounded,
                ),
                label: Text(
                  _isAnalyzing ? '분석 중...' : '촬영하기',
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
    if (_isPreparing) {
      return Center(
        child: Semantics(
          label: _statusMessage,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasPermission) return _buildPermissionView();
    if (!_isCameraReady) return _buildUnavailableView();

    return _buildCameraView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        title: Text(widget.levelName),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          Semantics(
            button: true,
            label: '학습 안내 다시 듣기',
            child: IconButton(
              onPressed: _isAnalyzing ? null : _speakGuide,
              icon: Icon(_isSpeaking ? Icons.volume_up : Icons.replay),
              tooltip: '다시 듣기',
            ),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }
}

class _FocusGuide extends StatelessWidget {
  const _FocusGuide();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 190,
        height: 190,
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