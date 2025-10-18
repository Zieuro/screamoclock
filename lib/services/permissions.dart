import 'dart:io';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmPermissions {
  static final _log = Logger('AlarmPermissions');

  static Future<void> checkNotificationPermission() async {
    if (Platform.isIOS) {
      // Check if permission is already granted before requesting
      final status = await Permission.notification.status;
      if (status.isGranted) {
        _log.info('iOS: Notification permission already granted');
        return;
      }
      _log.info('iOS: Notification permission will be requested when needed');
      return;
    }

    // Android notification permission logic
    final status = await Permission.notification.status;
    if (status.isGranted) {
      _log.info('Android: Notification permission already granted');
      return;
    }

    if (status.isDenied) {
      _log.info('Requesting notification permission...');
      final res = await Permission.notification.request();
      _log.info(
        'Notification permission ${res.isGranted ? '' : 'not '}granted',
      );
    }
  }

  static Future<void> checkAndroidExternalStoragePermission() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.storage.status;
    if (status.isGranted) {
      _log.info('External storage permission already granted');
      return;
    }

    if (status.isDenied) {
      _log.info('Requesting external storage permission...');
      final res = await Permission.storage.request();
      _log.info(
        'External storage permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }

  static Future<void> checkAndroidScheduleExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.scheduleExactAlarm.status;
    _log.info('Schedule exact alarm permission: $status.');

    if (status.isGranted) {
      _log.info('Schedule exact alarm permission already granted');
      return;
    }

    if (status.isDenied) {
      _log.info('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      _log.info(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }

  // iOS Request permission - only if not already granted
  static Future<void> requestIOSNotificationPermission() async {
    if (!Platform.isIOS) return;

    try {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        _log.info('iOS notification permission already granted');
        return;
      }

      if (status.isDenied) {
        _log.info('Requesting iOS notification permission...');
        final result = await Permission.notification.request();
        _log.info('iOS notification permission result: $result');
      }
    } catch (e) {
      _log.severe('Failed to request iOS notification permission: $e');
    }
  }

  // Add this method to check all permissions at once without requesting
  static Future<bool> areAllPermissionsGranted() async {
    try {
      final notificationStatus = await Permission.notification.status;

      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.status;
        final scheduleAlarmStatus = await Permission.scheduleExactAlarm.status;

        return notificationStatus.isGranted &&
            storageStatus.isGranted &&
            scheduleAlarmStatus.isGranted;
      } else {
        return notificationStatus.isGranted;
      }
    } catch (e) {
      _log.severe('Error checking permissions: $e');
      return false;
    }
  }
}
