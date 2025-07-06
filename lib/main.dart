import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/notification_service.dart';
import 'models/notification_schedule.dart';
import 'screens/schedule_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(NotificationScheduleAdapter());

  await Hive.openBox<NotificationSchedule>('schedules');

  await NotificationService().init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('id'),
      supportedLocales: const [Locale('id')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
