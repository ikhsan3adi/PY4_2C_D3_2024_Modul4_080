import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int get value => _counter;

  int _step = 1;
  int get step => _step;

  final List<(String, String, Color?)> _history = [];
  List<(String, String, Color?)> get history => _history;

  String _username = 'guest';
  String get username => _username;

  void setUsername(String username) {
    _username = username;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('counter_$_username') ?? 0;
    _step = prefs.getInt('step_$_username') ?? 1;

    final historyList = prefs.getStringList('history_$_username') ?? [];
    _history.clear();
    for (var item in historyList) {
      final parts = item.split('|');

      if (parts.length >= 3) {
        // Format: time|msg|colorValue
        final time = parts[0];
        final msg = parts[1];
        final colorValue = int.tryParse(parts[2]);

        final color = colorValue != null ? Color(colorValue) : null;

        _history.add((time, msg, color));
      }
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_$_username', _counter);
    await prefs.setInt('step_$_username', _step);

    final historyStrings = _history
        .map(
          (e) =>
              '${e.$1}|${e.$2}|${e.$3 != null ? (e.$3!.r * 255).toInt() << 16 | (e.$3!.g * 255).toInt() << 8 | (e.$3!.b * 255).toInt() | (e.$3!.a * 255).toInt() << 24 : null}',
        )
        .toList();
    await prefs.setStringList('history_$_username', historyStrings);
  }

  Future<void> increment() async {
    _counter += _step;

    addHistory(
      'User menambah nilai sebesar $_step. Hitungan: $_counter',
      Colors.green[100],
    );
    await save();
  }

  Future<void> decrement() async {
    if (_counter > 0) {
      _counter = max(_counter - _step, 0);

      addHistory(
        'User mengurangi nilai sebesar $_step. Hitungan: $_counter',
        Colors.red[100],
      );
      await save();
    }
  }

  Future<void> reset() async {
    _counter = 0;
    _step = 1;
    _history.clear();

    addHistory('User mereset nilai. Hitungan: $_counter', Colors.purple[100]);
    await save();
  }

  Future<void> setStep(int step) async {
    if (step > 0) {
      _step = step;

      addHistory('User mengubah step menjadi $_step', Colors.lightBlue[100]);
      await save();
    }
  }

  void addHistory(String msg, Color? color) {
    final time = DateTime.now();
    final timeString = DateFormat('d MMM yyyy hh:mm:ss').format(time);

    _history.add((timeString, msg, color));

    if (_history.length > 5) _history.removeAt(0);
  }
}
