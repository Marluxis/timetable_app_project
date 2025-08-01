import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:study_scheduler/data/models/study_session.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Top-level function for background notification handling
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle the tap event here
  print('Notification tapped in background: ${notificationResponse.payload}');
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'study_scheduler_channel_id';
  static const String _channelName = 'Study Reminders';
  static const String _channelDescription =
      'Reminders for upcoming study sessions';

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print('✅ Timezone configured: $timeZoneName');
    } catch (e) {
      print('❌ Error configuring timezone: $e');
      // Fallback to UTC if timezone configuration fails
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        showBadge: true,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
        print('✅ Notification channel created: $_channelId');

        // Also request exact alarm permission here
        await androidImplementation.requestExactAlarmsPermission();
      }
    }
  }

  Future<void> init() async {
    print('🔧 Initializing notification service...');

    // Configure timezone first
    await _configureLocalTimeZone();

    // Create notification channel
    await _createNotificationChannel();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // Handle foreground notification taps
        print(
            'Notification tapped in foreground: ${notificationResponse.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    print('✅ Notification service initialized successfully');
  }

  Future<bool> requestPermissions() async {
    print('🔐 Requesting notification permissions...');

    if (Platform.isAndroid) {
      // Request notification permission (Android 13+)
      final notificationStatus = await Permission.notification.request();
      print('📱 Notification permission: $notificationStatus');

      // Request exact alarm permission (Android 12+)
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      print('⏰ Exact alarm permission: $alarmStatus');

      // Request battery optimization exemption
      final batteryStatus =
          await Permission.ignoreBatteryOptimizations.request();
      print('🔋 Battery optimization exemption: $batteryStatus');

      // For Android, also request through the local notifications plugin
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted =
          await androidImplementation?.requestNotificationsPermission();
      print('📲 Local notifications permission: $granted');

      // Check if exact alarms are enabled
      final bool? exactAlarmsEnabled =
          await androidImplementation?.areNotificationsEnabled();
      print('⏰ Exact alarms enabled: $exactAlarmsEnabled');

      return notificationStatus.isGranted && (granted ?? false);
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>();

      final bool? granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🍎 iOS notifications permission: $granted');
      return granted ?? false;
    } else if (Platform.isMacOS) {
      final MacOSFlutterLocalNotificationsPlugin? macOSImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>();

      final bool? granted = await macOSImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🍎 macOS notifications permission: $granted');
      return granted ?? false;
    }

    return true;
  }

  // Core method to schedule a notification for a study session
  Future<void> scheduleNotification(
      StudySession session, int reminderMinutes) async {
    final scheduleTime =
        session.startTime.subtract(Duration(minutes: reminderMinutes));

    print('📱 Scheduling notification:');
    print('   Session: ${session.subjectName}');
    print('   Start Time: ${session.startTime}');
    print('   Reminder Minutes: $reminderMinutes');
    print('   Scheduled Time: $scheduleTime');
    print('   Current Time: ${DateTime.now()}');
    print(
        '   Minutes until notification: ${scheduleTime.difference(DateTime.now()).inMinutes}');

    if (scheduleTime.isBefore(DateTime.now())) {
      print('⚠️ Cannot schedule notification for past time');
      return;
    }

    // Ensure permissions are granted
    final hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      print('❌ Notification permissions not granted');
      return;
    }

    try {
      final tzScheduleTime = tz.TZDateTime.from(scheduleTime, tz.local);
      print('🕐 TZ Schedule Time: $tzScheduleTime');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        session.hashCode,
        'Study Time!',
        '${session.subjectName} starts in $reminderMinutes minutes',
        tzScheduleTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.alarm,
            fullScreenIntent: true,
            enableVibration: true,
            playSound: true,
            autoCancel: false, // Don't auto-cancel
            ongoing: false,
            ticker: 'Study reminder for ${session.subjectName}',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'study_session_${session.hashCode}',
      );

      print('✅ Notification scheduled successfully');

      // Verify the notification was scheduled
      final pending =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('📋 Total pending notifications: ${pending.length}');
    } catch (e) {
      print('❌ Failed to schedule notification: $e');

      // Try fallback with alarm clock mode
      try {
        print('🔄 Trying fallback with alarm clock mode...');
        final tzScheduleTime = tz.TZDateTime.from(scheduleTime, tz.local);

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          session.hashCode,
          'Study Time!',
          '${session.subjectName} starts in $reminderMinutes minutes',
          tzScheduleTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.max,
              priority: Priority.high,
              visibility: NotificationVisibility.public,
              category: AndroidNotificationCategory.alarm,
              enableVibration: true,
              playSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          payload: 'study_session_${session.hashCode}',
        );

        print('✅ Fallback notification scheduled successfully');
      } catch (fallbackError) {
        print('❌ Fallback scheduling also failed: $fallbackError');
      }
    }
  }

  // Method for custom reminder messages
  Future<void> scheduleNotificationWithCustomMessage(StudySession session,
      int reminderMinutes, String message, int notificationId) async {
    final scheduleTime =
        session.startTime.subtract(Duration(minutes: reminderMinutes));

    print('📱 Scheduling custom notification:');
    print('   ID: $notificationId');
    print('   Message: $message');
    print('   Scheduled Time: $scheduleTime');
    print('   Current Time: ${DateTime.now()}');
    print(
        '   Minutes until notification: ${scheduleTime.difference(DateTime.now()).inMinutes}');

    if (scheduleTime.isBefore(DateTime.now())) {
      print('⚠️ Cannot schedule notification for past time');
      return;
    }

    // Ensure permissions are granted
    final hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      print('❌ Notification permissions not granted');
      return;
    }

    try {
      final tzScheduleTime = tz.TZDateTime.from(scheduleTime, tz.local);
      print('🕐 TZ Schedule Time: $tzScheduleTime');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Study Reminder',
        message,
        tzScheduleTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.alarm,
            fullScreenIntent: true,
            enableVibration: true,
            playSound: true,
            autoCancel: false,
            ongoing: false,
            ticker: message,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'custom_reminder_$notificationId',
      );

      print('✅ Custom notification scheduled successfully');

      // Verify the notification was scheduled
      final pending =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('📋 Total pending notifications: ${pending.length}');
    } catch (e) {
      print('❌ Failed to schedule custom notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    print('🗑️ Cancelled notification with ID: $id');
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('🗑️ Cancelled all notifications');
  }

  // Get list of pending notifications for debugging
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
