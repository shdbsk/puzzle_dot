import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzle_dot/core/constants/prefs_keys.dart';
import 'package:puzzle_dot/screens/home_screen.dart';
import 'package:puzzle_dot/services/app_tts_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final AppTtsService _tts = AppTtsService();

  static const String _welcomeMessage =
      '퍼즐닷 점자 학습 앱에 오신 것을 환영합니다. '
      '이 앱에서는 점자 위치를 익히고, 자음과 모음, 받침, 숫자를 단계별로 학습할 수 있습니다. '
      '학습을 시작하려면 화면 아래의 학습 시작하기 버튼을 눌러주세요.';

  bool _isStarting = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.speak(_welcomeMessage);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _startLearning() async {
    if (_isStarting) return;

    setState(() => _isStarting = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.isFirstLaunch, false);
    await _tts.stop();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
      ),
    );
  }

  Future<void> _replayGuide() async {
    await _tts.speak(_welcomeMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 28,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDBEAFE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        size: 46,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'PuzzleDot에 오신 것을 환영합니다',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '점자 위치부터 자음, 모음, 받침, 숫자까지 단계별로 학습할 수 있습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Semantics(
                      button: true,
                      label: '온보딩 안내 다시 듣기',
                      child: OutlinedButton.icon(
                        onPressed: _isStarting ? null : _replayGuide,
                        icon: const Icon(Icons.replay),
                        label: const Text('다시 듣기'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
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
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: '학습 시작하기',
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isStarting ? null : _startLearning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF94A3B8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isStarting ? '시작하는 중...' : '학습 시작하기',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}