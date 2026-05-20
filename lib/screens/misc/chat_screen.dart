import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const ChatScreen({
    super.key,
    this.onBackPressed,
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