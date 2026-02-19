import 'package:flutter/material.dart';

class AppConstants {
  // database
  static const Duration connectionTimeout = Duration(seconds: 15);

  static const List<String> categories = ['Pribadi', 'Pekerjaan', 'Urgent'];

  static const Map<String, Color> categoryColors = {
    'Pribadi': Color(0xFFBBDEFB),
    'Pekerjaan': Color(0xFFE1BEE7),
    'Urgent': Color(0xFFFFCDD2),
  };

  static const Map<String, Color> categoryAccentColors = {
    'Pribadi': Color(0xFF0D47A1),
    'Pekerjaan': Color(0xFF4A148C),
    'Urgent': Color(0xFFB71C1C),
  };

  static const Map<String, IconData> categoryIcons = {
    'Pribadi': Icons.person,
    'Pekerjaan': Icons.work,
    'Urgent': Icons.priority_high,
  };
}
