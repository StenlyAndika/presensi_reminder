import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notification_schedule.dart';
import 'notif_service.dart';

class ScheduleScreen extends StatelessWidget {
  ScheduleScreen({super.key});

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
  ];

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
        title: dayData['title'],
        body: dayData['message'],
      );

      final box = Hive.box<NotificationSchedule>('schedules');
      final index = box.values.toList().indexWhere((s) => s.day == schedule.day);

      if (index != -1) {
        await box.putAt(index, updated);
      }

      NotifService().scheduleWeekly(updated);
    }
  }

  NotificationSchedule _getSchedule(Box<NotificationSchedule> box, String day) {
    return box.values.firstWhere(
      (s) => s.day == day,
      orElse: () {
        final dayData = _dayData.firstWhere((d) => d['day'] == day);
        final defaultSchedule = NotificationSchedule(
          day: day,
          hour: day == 'Friday' ? 7 : 7,
          minute: day == 'Friday' ? 11 : 26,
          title: dayData['title'],
          body: dayData['message'],
        );
        box.add(defaultSchedule);
        NotifService().scheduleWeekly(defaultSchedule);
        return defaultSchedule;
      },
    );
  }

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Jadwal Absen', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<NotificationSchedule>>(
        valueListenable: Hive.box<NotificationSchedule>('schedules').listenable(),
        builder: (context, box, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atur waktu notifikasi absen harian',
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _dayData.length,
                    itemBuilder: (context, index) {
                      final dayData = _dayData[index];
                      final schedule = _getSchedule(box, dayData['day']);

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
                          contentPadding: const EdgeInsets.all(20),
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
                              Text(dayData['day'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                              icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                              onPressed: () => _pickTime(context, schedule),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
