import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_schedule.dart';

class ScheduleStorageService {
  ScheduleStorageService._();

  static final ScheduleStorageService instance = ScheduleStorageService._();
  static const String _storageKey = 'notification_schedules';

  final ValueNotifier<List<NotificationSchedule>> _schedulesNotifier = ValueNotifier<List<NotificationSchedule>>([]);
  SharedPreferences? _prefs;

  ValueListenable<List<NotificationSchedule>> get listenable => _schedulesNotifier;
  List<NotificationSchedule> get schedules => _schedulesNotifier.value;

  Future<void> init() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    _schedulesNotifier.value = _readSchedules();
  }

  NotificationSchedule? getByDay(String day) {
    for (final schedule in _schedulesNotifier.value) {
      if (schedule.day == day) return schedule;
    }
    return null;
  }

  Future<void> upsertSchedule(NotificationSchedule schedule) async {
    final updated = List<NotificationSchedule>.from(_schedulesNotifier.value);
    final index = updated.indexWhere((item) => item.day == schedule.day);

    if (index == -1) {
      updated.add(schedule);
    } else {
      updated[index] = schedule;
    }

    await _saveSchedules(updated);
  }

  Future<void> _saveSchedules(List<NotificationSchedule> schedules) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    final encoded = schedules.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
    _schedulesNotifier.value = List<NotificationSchedule>.from(schedules);
  }

  List<NotificationSchedule> _readSchedules() {
    final raw = _prefs?.getStringList(_storageKey) ?? [];
    return raw
        .map((item) => NotificationSchedule.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }
}
