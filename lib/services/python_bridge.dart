import 'dart:convert';
import 'package:flutter/services.dart';

class PythonBridge {
  static const _channel = MethodChannel('com.example.puzzle_dot/python');

  static Future<Map<String, dynamic>> processImage(String imagePath) async {
    final result = await _channel.invokeMethod<String>(
      'processImage',
      {'imagePath': imagePath},
    );
    return json.decode(result!) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getImageInfo(String imagePath) async {
    final result = await _channel.invokeMethod<String>(
      'getImageInfo',
      {'imagePath': imagePath},
    );
    return json.decode(result!) as Map<String, dynamic>;
  }
}
