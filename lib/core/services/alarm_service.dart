import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

// FIXED: Removed all 'import .../reminder_confirmation_screen.dart'
// This solves the "ambiguous import" error.

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
    try {
      final String local = await tz.local.name;
      tz.setLocalLocation(tz.getLocation(local));
    } catch (_) {}

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // FIXED: Use DarwinInitializationSettings for your package version
    final iosInit = DarwinInitializationSettings(); 

    await _plugin.initialize(
      // FIXED: Removed 'const' because iosInit is not const
      InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty && navigatorKey != null) {
          try {
            final Map<String, dynamic> p = jsonDecode(payload);
            final userMode = p['userMode'] ?? 'normal';
            
            // FIXED: Use pushNamed. main.dart will handle the routing.
            if (userMode == 'blind') {
              navigatorKey.currentState!.pushNamed(
                '/blindReminder',
                arguments: p, // Pass all data
              );
            } else {
              navigatorKey.currentState!.pushNamed(
                '/normalReminder',
                arguments: p, // Pass all data
              );
            }
          } catch (_) {
            // ignore
          }
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medication_channel',
      'Medication Reminders',
      description: 'Medication reminder alarms',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('medicine_alarm'),
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
      sound: const RawResourceAndroidNotificationSound('medicine_alarm'),
    );
    final ios = const DarwinNotificationDetails(presentSound: true);
    return NotificationDetails(android: android, iOS: ios);
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    required String medicineId, // This parameter is required
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _platformDetails(fullScreen: true),
      payload: payload,
      // FIXED: Replaced deprecated member
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleWeeklyReminder({
    required int idBase,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<int> weekdays,
    String? payload,
    required String medicineId, // This parameter is required
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    for (final wd in weekdays) {
      tz.TZDateTime scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      final int currentW = scheduled.weekday;
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
        _platformDetails(fullScreen: true),
        payload: payload,
        // FIXED: Replaced deprecated member
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

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
      _platformDetails(fullScreen: true),
      payload: payload,
      // FIXED: Replaced deprecated member
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}