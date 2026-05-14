import 'package:flutter/services.dart';

// Communicates with native code to toggle DND / Focus mode.
// Android: requires MANAGE_NOTIFICATIONS permission and NotificationManager
//          setInterruptionFilter(INTERRUPTION_FILTER_NONE / INTERRUPTION_FILTER_ALL).
// iOS:     no public API for Focus mode; the channel call silently no-ops on iOS.
class FocusModeService {
  static const _channel = MethodChannel('rhythm_app/focus_mode');

  Future<void> enable() async {
    try {
      await _channel.invokeMethod<void>('enable');
    } on PlatformException {
      // DND permission not granted — proceed without it.
    }
  }

  Future<void> disable() async {
    try {
      await _channel.invokeMethod<void>('disable');
    } on PlatformException {
      // Silently ignore — disabling should never block the user.
    }
  }
}
