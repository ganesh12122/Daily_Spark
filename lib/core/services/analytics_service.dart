import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

class AnalyticsService {
  static Future<void> logEvent(String eventName, {Map<String, dynamic>? params}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();
      final log = {
        'event': eventName,
        'params': params ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': packageInfo.version,
      };
      final logs = prefs.getStringList('analytics_logs') ?? [];
      logs.add(jsonEncode(log));
      await prefs.setStringList('analytics_logs', logs);
    } catch (e) {
      debugPrint('Error logging event: $e');
    }
  }
}