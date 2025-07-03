import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'notification_schedule.dart';

class NotifService {
  final _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Request permission (Android 13+)
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notifications.initialize(initSettings);

    _isInitialized = true;
  }

  NotificationDetails _defaultDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notification',
        channelDescription: 'Daily reminder notification',
        importance: Importance.max,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList(const [0, 300, 100, 300]),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      ),
    );
  }

  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    int id = 1,
    String title = 'Waktunya Absen Pagi',
    String body = 'Jangan Lupa Absen Icik Bos :D',
  }) async {
    await _notifications.cancelAll(); // Clear existing scheduled notifications

    final now = tz.TZDateTime.now(tz.local);
    var schedule = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (schedule.isBefore(now)) {
      schedule = schedule.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      schedule,
      _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('Daily notification scheduled at: $schedule');
  }

  Future<void> scheduleWeekly(NotificationSchedule schedule) async {
    final dateTime = _nextDayTime(schedule.day, schedule.hour, schedule.minute);

    await _notifications.zonedSchedule(
      schedule.day.hashCode, // Unique ID per weekday
      schedule.title,
      schedule.body,
      dateTime,
      _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    debugPrint('Weekly notification scheduled for ${schedule.day}: $dateTime');
  }

  tz.TZDateTime _nextDayTime(String day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    final weekdays = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
    };

    final targetWeekday = weekdays[day]!;
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduled.weekday != targetWeekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  Future<void> testNotification() async {
    final testTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    await _notifications.zonedSchedule(
      999,
      'Test Notification',
      'This is a test alarm notification',
      testTime,
      _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );

    debugPrint('Test notification scheduled at: $testTime');
  }
}
