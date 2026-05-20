import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzle_dot/core/constants/prefs_keys.dart';
import 'package:puzzle_dot/services/tts/app_tts_service.dart';
import 'package:puzzle_dot/services/tts/tts_script_provider.dart';

class CameraGuideScreen extends StatefulWidget {
  final String levelId;
  final VoidCallback onConfirm;

  const CameraGuideScreen({
    super.key,
    required this.levelId,
    required this.onConfirm,
  });

  @override
  State<CameraGuideScreen> createState() => _CameraGuideScreenState();
}

class _CameraGuideScreenState extends State<CameraGuideScreen> {
  final AppTtsService _tts = AppTtsService();

  /// 카메라 거치 안내 문장
  ///
  /// 화면은 문장 내용을 직접 관리하지 않음
  String get _guideText => TtsScriptProvider.cameraGuide;

  @override
  void initState() {
    super.initState();

    /// 화면 진입 후 카메라 거치 안내 TTS 실행
    ///
    /// 문장 내용은 TtsScriptProvider가 담당
    unawaited(_tts.speak(_guideText));
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    super.dispose();
  }

  Future<void> _confirm() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      PrefsKeys.cameraGuideKey(widget.levelId),
      true,
    );

    await _tts.stop();

    if (!mounted) return;
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                '카메라 거치 안내',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '보호자 전용 화면입니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0E000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.smartphone,
                      size: 64,
                      color: Color(0xFF2563EB),
                    ),
                    SizedBox(height: 8),
                    Icon(
                      Icons.arrow_downward,
                      size: 28,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '점자판',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '카메라가 점자판 바로 위를\n수직으로 향하도록 거치',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _guideText,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: '카메라 거치 안내 다시 듣기',
                      child: OutlinedButton(
                        onPressed: () => _tts.speak(_guideText),
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
                          '다시 듣기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: '확인, 학습 시작',
                      child: ElevatedButton(
                        onPressed: _confirm,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}