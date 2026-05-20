import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzle_dot/core/constants/prefs_keys.dart';
import 'package:puzzle_dot/screens/home/home_screen.dart';
import 'package:puzzle_dot/screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const PuzzleDotApp());
}

class PuzzleDotApp extends StatelessWidget {
  const PuzzleDotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PuzzleDot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00AEEF),
        scaffoldBackgroundColor: const Color(0xFFF5FAFF),
      ),
      home: const AppStartGate(),
    );
  }
}

class AppStartGate extends StatefulWidget {
  const AppStartGate({super.key});

  @override
  State<AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<AppStartGate> {
  late final Future<bool> _isFirstLaunchFuture = _loadFirstLaunch();

  Future<bool> _loadFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefsKeys.isFirstLaunch) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstLaunchFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF0F6FF),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isFirstLaunch = snapshot.data ?? true;

        if (isFirstLaunch) {
          return const OnboardingScreen();
        }

        return const MainNavigationScreen();
      },
    );
  }
}