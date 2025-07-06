import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'notif_service.dart';
import 'notification_schedule.dart';
import 'schedule_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(NotificationScheduleAdapter());

  await Hive.openBox<NotificationSchedule>('schedules');

  await NotifService().init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScheduleScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        fontFamily: 'Titilium Web SemiBold',
        colorSchemeSeed: Colors.indigo,
      ),
    );
  }
}
