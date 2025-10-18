// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:screamoclock/components/model.dart';

int id = 1; // A unique id for each alarm

Future<void> armAlarms(
  List<Slot> slots,
  DateTime now,
  BuildContext context,
) async {
  slots = buildSlots(now);
  try {
    await Alarm.setWarningNotificationOnKill(
      'Careful!',
      'The alarm may not ring if the app is killed.',
    );

    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No slots available to set alarms for!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    int alarmsSet = 0;

    for (final s in slots) {
      // Only set alarmas for future times
      if (s.start.isAfter(now)) {
        // Slot Lines
        final items = <MapEntry<String, Status>>[
          MapEntry('A', s.statusA),
          MapEntry('B', s.statusB),
          MapEntry('C', s.statusC),
        ];

        List<String> namesFor(Status s) =>
            items.where((e) => e.value == s).map((e) => e.key).toList();

        String joinWithAmpersand(List<String> names) {
          if (names.isEmpty) return '';
          if (names.length == 1) return names.first;
          if (names.length == 2) return '${names[0]} & ${names[1]}';
          final last = names.last;
          return '${names.sublist(0, names.length - 1).join(', ')} & $last';
        }

        final on = namesFor(Status.onSet);
        final off = namesFor(Status.offSet);
        final meal = namesFor(Status.meal);

        final onLine = on.isNotEmpty ? '${joinWithAmpersand(on)} on SET' : null;
        final offLine = off.isNotEmpty
            ? '${joinWithAmpersand(off)} off SET'
            : null;
        final mealLine = meal.isNotEmpty
            ? '${joinWithAmpersand(meal)} on MEAL'
            : null;

        // Combine lines
        final bodyLines = [
          onLine,
          offLine,
          mealLine,
        ].where((line) => line != null).join(' ');

        final alarmID = now.month + now.day + id;

        // Alarm Settings

        final alarmSettings = AlarmSettings(
          id: alarmID,
          dateTime: s.start,
          assetAudioPath: 'assets/silence.mp3',
          loopAudio: true,
          vibrate: true,
          warningNotificationOnKill: true,
          androidFullScreenIntent: true,
          volumeSettings: VolumeSettings.fixed(
            volume: 0.1, // Start silent, Stay silent
            volumeEnforced: false,
          ),
          notificationSettings: NotificationSettings(
            title: 'ROTATE!',
            body: bodyLines.isNotEmpty ? bodyLines : 'Time to rotate!',
            stopButton: 'Stop the alarm',
            icon: 'notification_icon',
            iconColor: const Color(0xff862778),
          ),
        );

        await Alarm.set(alarmSettings: alarmSettings);

        alarmsSet++;
        id++;
      }
    }

    if (alarmsSet > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$alarmsSet alarms set!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No future alarms set!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } on Exception catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error setting alarms: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> disarmAlarms(BuildContext context) async {
  try {
    await Alarm.stopAll();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All alarms stopped'),
        backgroundColor: Colors.green,
      ),
    );
  } on Exception catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error stopping alarms: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Add function to stop current alarm
Future<void> stopCurrentAlarm(int alarmId, BuildContext context) async {
  try {
    await Alarm.stop(alarmId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Current alarm stopped!'),
        backgroundColor: Colors.blue,
      ),
    );
  } on Exception catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error stopping current alarm: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Function to check if any alarms are currently ringing
Future<bool> isAnyAlarmRinging() {
  return Alarm.hasAlarm();
}

// Function to get the ID of the currently ringing alarm
Future<int?> getCurrentRingingAlarmId() async {
  final alarms = await Alarm.getAlarms();
  return alarms.isNotEmpty ? alarms.first.id : null;
}
