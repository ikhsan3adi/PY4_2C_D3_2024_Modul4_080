import 'dart:async';

import 'package:flutter/foundation.dart';

class LoginController {
  // Database of valid users and passwords
  final Map<String, String> _users = {
    'admin': '123',
    'satriadi': '123',
    'user': 'user',
  };

  // Lockout state
  int _failedAttempts = 0;
  final ValueNotifier<bool> isLocked = ValueNotifier(false);
  Timer? _lockoutTimer;

  // Login function
  bool login(String username, String password) {
    if (isLocked.value) return false;

    if (_users.containsKey(username) && _users[username] == password) {
      _resetLockout();
      return true;
    } else {
      _handleFailedAttempt();
      return false;
    }
  }

  void _handleFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= 3) {
      isLocked.value = true;
      _lockoutTimer = Timer(const Duration(seconds: 10), () {
        _resetLockout();
      });
    }
  }

  void _resetLockout() {
    _failedAttempts = 0;
    isLocked.value = false;
    _lockoutTimer?.cancel();
  }

  void dispose() {
    _lockoutTimer?.cancel();
    isLocked.dispose();
  }
}
