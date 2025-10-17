// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:screamoclock/components/createroute.dart';
import 'package:screamoclock/Screens/schedule.dart';
import 'package:screamoclock/Screens/settings.dart';
import 'package:screamoclock/views/mainview.dart';
import 'package:screamoclock/views/shownext.dart';
import 'package:screamoclock/components/model.dart';
import 'package:screamoclock/components/alarm.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:screamoclock/services/permissions.dart';
import 'dart:async';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime now = DateTime.now();
  late DateTime calltime;
  late DateTime starttime;
  late DateTime endtime;
  late Timer timer;
  late StreamSubscription<AlarmSet> alarmSubscription;
  List<Slot> slots = [];
  bool isAlarmsArmed = false;
  bool isProcessing = false;
  bool isAlarmRinging = false;
  int? currentRingingAlarmId;

  @override
  void initState() {
    super.initState();
    _requestPermissionsOnStartup();
    now = DateTime.now();

    calltime = DateTime(now.year, now.month, now.day, 18, 0);
    starttime = DateTime(now.year, now.month, now.day, 19, 0);

    // next-day midnight and 1:00 AM
    final nextMidnight = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final next1am = DateTime(
      nextMidnight.year,
      nextMidnight.month,
      nextMidnight.day,
      1,
      0,
    );

    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    if (weekday == DateTime.thursday || weekday == DateTime.sunday) {
      endtime = nextMidnight;
    } else if (weekday == DateTime.friday || weekday == DateTime.saturday) {
      endtime = next1am;
    } else {
      endtime = now; // no event today
    }

    // Listen for alarm events
    alarmSubscription = Alarm.ringing.listen((AlarmSet alarmsSet) {
      setState(() {
        if (alarmsSet.alarms.isNotEmpty) {
          // At least one alarm is ringing
          isAlarmRinging = true;
          currentRingingAlarmId = alarmsSet.alarms.first.id;
        } else {
          isAlarmRinging = false;
          currentRingingAlarmId = null;
        }
      });
    });

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  Future<void> _requestPermissionsOnStartup() async {
    try {
      if (Platform.isIOS) {
        await AlarmPermissions.requestIOSNotificationPermission();
      } else if (Platform.isAndroid) {
        await AlarmPermissions.checkNotificationPermission();
        await AlarmPermissions.checkAndroidExternalStoragePermission();
        await AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
      }
    } catch (e) {
      print('Startup permission error: $e');
      // Don't show error to user at startup - they can try activating alarms later
    }
  }

  Future<void> _toggleAlarms() async {
    if (isProcessing) return; // Prevents multiple taps

    setState(() {
      isProcessing = true;
    });

    try {
      if (isAlarmsArmed) {
        // disarm alarms
        await disarmAlarms(context);
        setState(() {
          isAlarmsArmed = false;
        });
      } else {
        // arm alarms
        await armAlarms(slots, now, context);
        setState(() {
          isAlarmsArmed = true;
        });
      }
    } catch (e) {
      print('Error toggling alarms: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error toggling alarms: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _stopCurrentAlarm() async {
    if (currentRingingAlarmId != null) {
      await stopCurrentAlarm(currentRingingAlarmId!, context);
      setState(() {
        isAlarmRinging = false;
        currentRingingAlarmId = null;
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        shadowColor: Colors.black,
        surfaceTintColor: Colors.grey[900],
        elevation: 5,
        backgroundColor: Colors.grey[900],
        title: Text(
          'HOS 2025',
          style: TextStyle(
            color: Colors.red[800],
            fontFamily: 'Creepster',
            fontSize: 30,
            letterSpacing: 4,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.calendar_month),
          onPressed: () {
            Navigator.of(
              context,
            ).push(createRoute(const SchedulePage(), const Offset(-1.0, 0.0)));
          },
          tooltip: 'Schedule',
          color: Colors.red[800],
          enableFeedback: true,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(createRoute(const SettingsPage(), const Offset(1.0, 0.0)));
            },
            tooltip: 'Settings',
            color: Colors.red[800],
            enableFeedback: true,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 100),
            SizedBox(
              height: 200,
              child: mainView(now, calltime, starttime, endtime),
            ),

            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 200,
              child: now.isBefore(starttime) || now.isAfter(endtime)
                  ? Text('')
                  : showNext(now),
            ),

            isAlarmRinging ? SizedBox(height: 10) : SizedBox(height: 100),

            // Stop Current Alarm Button (only shows when an alarm is ringing)
            if (isAlarmRinging) ...[
              ElevatedButton(
                onPressed: _stopCurrentAlarm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.stop_circle, size: 24),
                    SizedBox(width: 8),
                    Text(' Stop Alarm'),
                  ],
                ),
              ),
              SizedBox(height: 50),
            ],

            // Toggle Alarms Button
            ElevatedButton(
              onPressed: isProcessing ? null : _toggleAlarms,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAlarmsArmed
                    ? Colors.red[800]
                    : Colors.grey[850],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[850],
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: TextStyle(
                  fontFamily: 'GoogleSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: isProcessing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isAlarmsArmed ? Icons.alarm_on : Icons.alarm_off),
                        Text(
                          isAlarmsArmed
                              ? ' Alarms Activated'
                              : ' Alarms Deactivated',
                        ),
                      ],
                    ),
            ),

            // // Show alarm ringing indicator
            // if (isAlarmRinging) ...[
            //   SizedBox(height: 16),
            //   Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 16,
            //       vertical: 8,
            //     ),
            //     decoration: BoxDecoration(
            //       color: Colors.red[800],
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(
            //           Icons.notifications_active,
            //           color: Colors.white,
            //           size: 16,
            //         ),
            //         SizedBox(width: 8),
            //         Text(
            //           'ALARM RINGING',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontFamily: 'GoogleSans',
            //             fontWeight: FontWeight.w500,
            //             fontSize: 16,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
