import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final bool isActive;

  const SettingsScreen({
    super.key,
    this.onBackPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '빈페이지',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}