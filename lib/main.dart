import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'services/python_bridge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Python Pipeline Test',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _result = '버튼을 눌러 테스트를 시작하세요';
  bool _loading = false;
  String? _testImagePath;

  // 원이 그려진 테스트 이미지를 Dart Canvas로 생성하고 임시 경로에 저장
  Future<String> _prepareTestImage() async {
    if (_testImagePath != null) return _testImagePath!;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 400, 400),
      Paint()..color = Colors.white,
    );

    final circles = [
      (const Offset(100, 100), 40.0, Colors.red),
      (const Offset(250, 150), 60.0, Colors.green),
      (const Offset(300, 300), 30.0, Colors.blue),
    ];

    for (final (center, radius, color) in circles) {
      canvas.drawCircle(center, radius, Paint()..color = color);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(400, 400);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/test_circles.png');
    await file.writeAsBytes(bytes);

    _testImagePath = file.path;
    return _testImagePath!;
  }

  Future<void> _runProcessImage() async {
    setState(() { _loading = true; _result = '처리 중...'; });
    try {
      final path = await _prepareTestImage();
      final res = await PythonBridge.processImage(path);
      setState(() => _result = 'processImage 결과:\n$res');
    } catch (e) {
      setState(() => _result = '오류: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _runGetImageInfo() async {
    setState(() { _loading = true; _result = '처리 중...'; });
    try {
      final path = await _prepareTestImage();
      final res = await PythonBridge.getImageInfo(path);
      setState(() => _result = 'getImageInfo 결과:\n$res');
    } catch (e) {
      setState(() => _result = '오류: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Python Pipeline Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '테스트 이미지: 원 3개(빨강·초록·파랑)가 그려진 400×400 PNG를 자동 생성합니다.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _runProcessImage,
                    child: const Text('processImage'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _runGetImageInfo,
                    child: const Text('getImageInfo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
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
