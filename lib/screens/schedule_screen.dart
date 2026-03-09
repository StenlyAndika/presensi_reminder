import 'package:flutter/material.dart';
import '../models/notification_schedule.dart';
import '../services/notification_service.dart';
import '../services/schedule_storage_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _storage = ScheduleStorageService.instance;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _dayData = [
    {
      'day': 'Monday',
      'title': 'Waktunya Absen Pagi 🌅',
      'message': 'Jangan lupa absen icik bos :D',
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.blue,
    },
    {
      'day': 'Tuesday',
      'title': 'Waktunya Absen Pagi 🌅',
      'message': 'Kegagalan adalah keberhasilan yang gagal!',
      'icon': Icons.work_outline,
      'color': Colors.green,
    },
    {
      'day': 'Wednesday',
      'title': 'Waktunya Absen Pagi 🌅',
      'message': 'Lorem ipsum dolor sit amet!',
      'icon': Icons.star_outline,
      'color': Colors.orange,
    },
    {
      'day': 'Thursday',
      'title': 'Waktunya Absen Pagi 🌅',
      'message': 'Apa ini njir!',
      'icon': Icons.trending_up,
      'color': Colors.purple,
    },
    {
      'day': 'Friday',
      'title': 'Waktunya Absen Pagi 🌅',
      'message': 'Jumat berkah, Jangan lupa sholat jumat!',
      'icon': Icons.celebration_outlined,
      'color': Colors.teal,
    },
    {
      'day': 'Saturday',
      'title': 'Waktunya isi ERK',
      'message': 'Jangan lupa isi erk bos!',
      'icon': Icons.date_range,
      'color': Colors.lightBlue,
    },
  ];

  final Map<String, String> _dayTranslation = {
    'Monday': 'Senin',
    'Tuesday': 'Selasa',
    'Wednesday': 'Rabu',
    'Thursday': 'Kamis',
    'Friday': 'Jumat',
    'Saturday': 'Sabtu E-RK',
  };

  @override
  void initState() {
    super.initState();
    _initializeSchedules();
  }

  Future<void> _initializeSchedules() async {
    await _storage.init();

    for (final dayData in _dayData) {
      final day = dayData['day'] as String;
      if (_storage.getByDay(day) != null) continue;

      final defaultSchedule = NotificationSchedule(
        day: day,
        hour: day == 'Friday' ? 7 : 7,
        minute: day == 'Friday' ? 11 : 26,
        title: dayData['title'] as String,
        body: dayData['message'] as String,
      );

      await _storage.upsertSchedule(defaultSchedule);
      await NotificationService().scheduleWeekly(defaultSchedule);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickTime(BuildContext context, NotificationSchedule schedule) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: schedule.hour, minute: schedule.minute),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final dayData = _dayData.firstWhere((d) => d['day'] == schedule.day);
      final updated = NotificationSchedule(
        day: schedule.day,
        hour: picked.hour,
        minute: picked.minute,
        title: dayData['title'] as String,
        body: dayData['message'] as String,
      );

      await _storage.upsertSchedule(updated);
      await NotificationService().scheduleWeekly(updated);
    }
  }

  NotificationSchedule _getSchedule(List<NotificationSchedule> schedules, String day) {
    return schedules.firstWhere((item) => item.day == day);
  }

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE9F2FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFE9F2FF),
      appBar: AppBar(
        title: const Text('Absen Reminder', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<NotificationSchedule>>(
        valueListenable: _storage.listenable,
        builder: (context, schedules, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Atur waktu notifikasi absen harian',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _dayData.length,
                    itemBuilder: (context, index) {
                      final dayData = _dayData[index];
                      final schedule = _getSchedule(schedules, dayData['day'] as String);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: dayData['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(dayData['icon'], color: dayData['color'], size: 24),
                          ),
                          title: Row(
                            children: [
                              Text(
                                _dayTranslation[dayData['day']] ?? dayData['day'],
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: dayData['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _formatTime(schedule.hour, schedule.minute),
                                  style: TextStyle(color: dayData['color'], fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                            child: IconButton(
                              icon: Icon(Icons.edit_outlined, size: 20, color: Colors.grey.shade600),
                              onPressed: () => _pickTime(context, schedule),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Text(
                  'Copyright © 2025 by Stenly Andika',
                  style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
