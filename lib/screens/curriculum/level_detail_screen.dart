import 'package:flutter/material.dart';

class LevelDetailScreen extends StatelessWidget {
  final String levelId;
  final String stageTitle;
  final String stageDescription;

  const LevelDetailScreen({
    super.key,
    required this.levelId,
    required this.stageTitle,
    required this.stageDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$stageTitle Level')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Level ID: $levelId',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              const SizedBox(height: 12),
              Text(stageTitle,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(stageDescription,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF475569))),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Start Learning',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}