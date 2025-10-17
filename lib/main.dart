import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:screamoclock/services/notifications.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the alarm package
  await Alarm.init();

  // Initialize notifications
  final notifications = Notifications();
  await notifications.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Scream O\'Clock',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
