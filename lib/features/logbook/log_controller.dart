import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logbook_app_080/features/logbook/models/log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);
  String _storageKey = 'user_logs_data';

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

  LogController({String username = 'guest'}) {
    _storageKey = 'user_logs_$username';
    loadFromDisk();
  }

  void addLog(String title, String desc, {String category = 'Pribadi'}) {
    final newLog = LogModel(
      title: title,
      description: desc,
      timestamp: DateTime.now().toString(),
      category: category,
    );
    logsNotifier.value = [...logsNotifier.value, newLog];
    filteredLogs.value = logsNotifier.value;
    saveToDisk();
  }

  void updateLog(
    int index,
    String title,
    String desc, {
    String category = 'Pribadi',
  }) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs[index] = LogModel(
      title: title,
      description: desc,
      timestamp: DateTime.now().toString(),
      category: category,
    );
    logsNotifier.value = currentLogs;
    filteredLogs.value = currentLogs;
    saveToDisk();
  }

  void removeLog(int index) {
    final originalLog = filteredLogs.value[index];
    final actualIndex = logsNotifier.value.indexOf(originalLog);

    final currentLogs = List<LogModel>.from(logsNotifier.value);
    if (actualIndex != -1) currentLogs.removeAt(actualIndex);
    logsNotifier.value = currentLogs;
    filteredLogs.value = filteredLogs.value
        .where((log) => log != originalLog)
        .toList();
    saveToDisk();
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value.where((log) {
        bool searchTitle = log.title.toLowerCase().contains(
          query.toLowerCase(),
        );
        bool searchDesc = log.description.toLowerCase().contains(
          query.toLowerCase(),
        );
        return searchTitle || searchDesc;
      }).toList();
    }
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      logsNotifier.value.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List decoded = jsonDecode(data);
      logsNotifier.value = decoded.map((e) => LogModel.fromMap(e)).toList();
      filteredLogs.value = logsNotifier.value;
    }
  }
}
