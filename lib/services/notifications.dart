import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

class Notifications {
  Notifications() {
    init();
  }
  static const _iosCategoryId = 'sample_category';
  static const _rotationCategoryId = 'rotation_category';
  static final _log = Logger('Notifications');

  final _plugin = FlutterLocalNotificationsPlugin();
  final _initCompleter = Completer<void>();

  Future<void> init() async {
    tz.initializeTimeZones();
    setLocalLocation(getLocation('America/New_York'));

    final success = await _plugin.initialize(
      InitializationSettings(
        iOS: DarwinInitializationSettings(
          notificationCategories: [
            DarwinNotificationCategory(
              _iosCategoryId,
              actions: [
                DarwinNotificationAction.plain(
                  'sample_action',
                  'Sample Action',
                  options: {DarwinNotificationActionOption.foreground},
                ),
              ],
              options: {
                DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
                DarwinNotificationCategoryOption.hiddenPreviewShowSubtitle,
                DarwinNotificationCategoryOption.allowAnnouncement,
              },
            ),
            // Add rotation-specific category
            DarwinNotificationCategory(
              _rotationCategoryId,
              actions: [
                DarwinNotificationAction.plain(
                  'stop_rotation',
                  'Stop Alarm',
                  options: {DarwinNotificationActionOption.foreground},
                ),
                DarwinNotificationAction.plain(
                  'snooze_rotation',
                  'Snooze',
                  options: {DarwinNotificationActionOption.foreground},
                ),
              ],
              options: {
                DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
                DarwinNotificationCategoryOption.allowAnnouncement,
              },
            ),
          ],
        ),
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: notificationTapForeground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (success ?? false) {
      _log.info('Notifications initialized');
    } else {
      _log.severe('Failed to initialize notifications');
    }
    _initCompleter.complete();
  }

  Future<void> showNotification() async {
    await _initCompleter.future;

    await _plugin.show(
      _randomId,
      'Notification Title',
      'This is the notification body.',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          badgeNumber: 1,
          categoryIdentifier: _iosCategoryId,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
        android: AndroidNotificationDetails('sample_channel', 'Sample Channel'),
      ),
      payload: 'payload',
    );
    _log.info('Notification shown.');
  }

  Future<void> scheduleNotification() async {
    await _initCompleter.future;

    await _plugin.zonedSchedule(
      _randomId,
      'Delayed Notification Title',
      'This is the notification body shown after 5s.',
      TZDateTime.now(local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          badgeNumber: 1,
          categoryIdentifier: _iosCategoryId,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
        android: AndroidNotificationDetails('sample_channel', 'Sample Channel'),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      payload: 'payload',
    );
    _log.info('Notification scheduled.');
  }

  Future<void> scheduleRotationNotification(
    DateTime dateTime,
    String title,
    String body,
    int alarmId,
  ) async {
    await _initCompleter.future;

    await _plugin.zonedSchedule(
      alarmId, // Use the same ID as your alarm
      title,
      body,
      TZDateTime.from(dateTime, local),
      NotificationDetails(
        iOS: DarwinNotificationDetails(
          badgeNumber: 1,
          categoryIdentifier: _rotationCategoryId,
          interruptionLevel: InterruptionLevel.timeSensitive,
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'rotation_channel',
          'Rotation Alarms',
          channelDescription: 'Notifications for rotation schedule alarms',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
          color: const Color(0xff862778), // Match your app's theme
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      payload: 'rotation_alarm_$alarmId',
    );
    _log.info('Rotation notification scheduled for $dateTime with ID $alarmId');
  }

  Future<void> showRotationNotification(
    String title,
    String body,
    int alarmId,
  ) async {
    await _initCompleter.future;

    await _plugin.show(
      alarmId,
      title,
      body,
      NotificationDetails(
        iOS: DarwinNotificationDetails(
          badgeNumber: 1,
          categoryIdentifier: _rotationCategoryId,
          interruptionLevel: InterruptionLevel.timeSensitive,
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'rotation_channel',
          'Rotation Alarms',
          channelDescription: 'Notifications for rotation schedule alarms',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
          color: const Color(0xff862778),
        ),
      ),
      payload: 'rotation_alarm_$alarmId',
    );
    _log.info('Rotation notification shown with ID $alarmId');
  }

  Future<void> cancelRotationNotification(int alarmId) async {
    await _plugin.cancel(alarmId);
    _log.info('Rotation notification $alarmId cancelled');
  }

  Future<void> cancelAllRotationNotifications() async {
    await _plugin.cancelAll();
    _log.info('All rotation notifications cancelled');
  }

  int get _randomId {
    const min = -0x80000000;
    const max = 0x7FFFFFFF;
    return Random().nextInt(max - min) + min;
  }

  @pragma('vm:entry-point')
  static void notificationTapForeground(
    NotificationResponse notificationResponse,
  ) {
    _log.info('notificationTapForeground: $notificationResponse');
    
    // Handle rotation notification actions
    if (notificationResponse.payload?.contains('rotation_alarm') == true) {
      switch (notificationResponse.actionId) {
        case 'stop_rotation':
          _log.info('Stop rotation action triggered');
          // Handle stop action
          break;
        case 'snooze_rotation':
          _log.info('Snooze rotation action triggered');
          // Handle snooze action
          break;
        default:
          _log.info('Rotation notification tapped');
          // Handle regular tap
          break;
      }
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(
    NotificationResponse notificationResponse,
  ) {
    _log.info('notificationTapBackground: $notificationResponse');
    
    // Handle rotation notification actions in background
    if (notificationResponse.payload?.contains('rotation_alarm') == true) {
      switch (notificationResponse.actionId) {
        case 'stop_rotation':
          _log.info('Stop rotation action triggered (background)');
          // Handle stop action
          break;
        case 'snooze_rotation':
          _log.info('Snooze rotation action triggered (background)');
          // Handle snooze action
          break;
        default:
          _log.info('Rotation notification tapped (background)');
          // Handle regular tap
          break;
      }
    }
  }
}