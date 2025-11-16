// lib/core/services/alarm_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

/// AlarmService - singleton used by UI.
/// Provides methods expected by your screens:
///  - init(navigatorKey)
///  - scheduleDailyReminder(...)
///  - scheduleWeeklyReminder(...)
///  - snoozeMinutes(...)
///  - cancel / cancelAll
class AlarmService {
  AlarmService._internal();
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _inited = false;

  Future<void> init(GlobalKey<NavigatorState>? navigatorKey) async {
    if (_inited) return;
    tzdata.initializeTimeZones();
    // Try to set local timezone; best-effort
    try {
      final String local = tz.local.name;
      // no-op; tz already initialized
    } catch (_) {}

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iOSInit),
      onDidReceiveNotificationResponse: (response) async {
        // If a notification tap has payload, navigate using navigatorKey (if provided)
        if (response.payload != null && response.payload!.isNotEmpty) {
          // payload expected to be JSON-like string if you stored one
          // You can parse and route accordingly using navigatorKey.currentState
          // Left intentionally minimal to avoid assumptions.
        }
      },
    );

    // Create a high-priority channel for medication alarms (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medication_channel',
      'Medication Reminders',
      description: 'Medication reminder alarms',
      importance: Importance.max,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _inited = true;
  }

  NotificationDetails _platformDetails({bool fullScreen = true}) {
    final android = AndroidNotificationDetails(
      'medication_channel',
      'Medication Reminders',
      channelDescription: 'Medication reminder alarms',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'medication',
      playSound: true,
      fullScreenIntent: fullScreen,
      // sound: RawResourceAndroidNotificationSound('medicine_alarm'), // optional if you add raw sound
    );

    final ios = const DarwinNotificationDetails(presentSound: true, presentAlert: true);

    return NotificationDetails(android: android, iOS: ios);
  }

  /// Show immediate alarm/notification (one-shot)
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) =>
      _plugin.show(id, title, body, _platformDetails(), payload: payload);

  /// Schedule daily reminder at given hour/minute (local timezone).
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    // ensure ints
    final int h = hour;
    final int m = minute;

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _platformDetails(),
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule weekly reminders. weekdays: 1=Mon ... 7=Sun
  /// idBase is used to create distinct ids (idBase + weekday).
  Future<void> scheduleWeeklyReminder({
    required int idBase,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<int> weekdays,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    for (final wd in weekdays) {
      // compute next occurrence of weekday wd
      tz.TZDateTime scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      final int currentW = scheduled.weekday; // Monday=1
      int daysToAdd = (wd - currentW) % 7;
      if (daysToAdd < 0) daysToAdd += 7;
      if (daysToAdd == 0 && scheduled.isBefore(now)) daysToAdd = 7;
      scheduled = scheduled.add(Duration(days: daysToAdd));
      final int id = idBase + wd;
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _platformDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Snooze (one-off after minutes)
  Future<void> snoozeMinutes({
    required int id,
    required String title,
    required String body,
    required int minutes,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduled = now.add(Duration(minutes: minutes));
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _platformDetails(),
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}
