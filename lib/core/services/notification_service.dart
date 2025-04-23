import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  late FlutterLocalNotificationsPlugin _local;
  bool _isInitialized = false;

  NotificationService() {
    _local = FlutterLocalNotificationsPlugin();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      final String timeZoneName = tz.local.name;
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Initialize notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _local.initialize(settings);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<bool> requestNotificationPermission() async {
    if (!_isInitialized) {
      await _initialize();
    }

    bool? granted;
    try {
      granted = await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<void> scheduleDailyReminders() async {
    if (!_isInitialized) {
      await _initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily discipline reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _local.zonedSchedule(
        0,
        'SparkVow Reminder',
        'Time to tackle your disciplines! Don’t waste a second!',
        _nextInstanceOfTenAM(),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> showAchievementNotification(String title, String body) async {
    if (!_isInitialized) {
      await _initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'achievement_channel',
      'Achievements',
      channelDescription: 'Notifications for achievements',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _local.show(
        DateTime.now().millisecondsSinceEpoch % 10000,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Error showing achievement notification: $e');
    }
  }
}