import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Writes profile data so the native home-screen widget can read it.
/// Android: SharedPreferences ("FlutterSharedPreferences" with "flutter." prefix).
/// iOS: App Group UserDefaults via MethodChannel + WidgetKit reload.
class WidgetUpdateService {
  static const _iosChannel = MethodChannel('com.example.dontsmoke/widget');

  static Future<void> saveProfileForWidget(UserProfile profile) async {
    try {
      // Android — SharedPreferences (read natively by the widget provider)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'quit_date_millis',
        profile.quitDate.millisecondsSinceEpoch,
      );
      await prefs.setInt('cigarettes_per_day', profile.cigarettesPerDay);
      await prefs.setInt('cost_per_pack', profile.costPerPack);
      await prefs.setInt('cigarettes_per_pack', profile.cigarettesPerPack);

      // iOS — write to App Group UserDefaults & reload WidgetKit
      if (Platform.isIOS) {
        await _iosChannel.invokeMethod('saveWidgetData', {
          'quit_date_millis': profile.quitDate.millisecondsSinceEpoch,
          'cigarettes_per_day': profile.cigarettesPerDay,
          'cost_per_pack': profile.costPerPack,
          'cigarettes_per_pack': profile.cigarettesPerPack,
        });
      }
    } catch (_) {
      // Widget data is best-effort; don't crash the app.
    }
  }

  static Future<void> clearProfileForWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('quit_date_millis');
      await prefs.remove('cigarettes_per_day');
      await prefs.remove('cost_per_pack');
      await prefs.remove('cigarettes_per_pack');

      if (Platform.isIOS) {
        await _iosChannel.invokeMethod('clearWidgetData');
      }
    } catch (_) {}
  }
}
