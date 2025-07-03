import 'package:hive/hive.dart';

part 'notification_schedule.g.dart';

@HiveType(typeId: 0)
class NotificationSchedule extends HiveObject {
  @HiveField(0)
  String day;

  @HiveField(1)
  int hour;

  @HiveField(2)
  int minute;

  @HiveField(3)
  String title;

  @HiveField(4)
  String body;

  NotificationSchedule({
    required this.day,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
  });
}
