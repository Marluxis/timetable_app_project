import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:study_scheduler/data/hive_db.dart';
import 'package:study_scheduler/data/models/reminder.dart';
import 'package:study_scheduler/data/models/study_session.dart';
import 'package:study_scheduler/services/notification_service.dart';

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  RemindersNotifier(this._notificationService) : super([]) {
    _loadReminders();
  }

  final NotificationService _notificationService;
  final Box<Reminder> _box = HiveDb.getRemindersBox();

  void _loadReminders() {
    state = _box.values.toList();
    _box.watch().listen((event) {
      state = _box.values.toList();
    });
  }

  Future<void> addReminder(Reminder reminder) async {
    await _box.add(reminder);

    if (reminder.isEnabled) {
      await _scheduleNotification(reminder);
    }
  }

  Future<void> updateReminder(int key, Reminder reminder) async {
    // Cancel existing notification
    final oldReminder = _box.get(key);
    if (oldReminder != null) {
      await _notificationService.cancelNotification(oldReminder.notificationId);
    }

    await _box.put(key, reminder);

    if (reminder.isEnabled) {
      await _scheduleNotification(reminder);
    }
  }

  Future<void> deleteReminder(int key) async {
    final reminder = _box.get(key);
    if (reminder != null) {
      await _notificationService.cancelNotification(reminder.notificationId);
    }
    await _box.delete(key);
  }

  Future<void> toggleReminder(int key) async {
    final reminder = _box.get(key);
    if (reminder != null) {
      final updatedReminder = Reminder(
        subjectName: reminder.subjectName,
        minutesBefore: reminder.minutesBefore,
        isEnabled: !reminder.isEnabled,
        message: reminder.message,
        sessionStartTime: reminder.sessionStartTime,
        sessionId: reminder.sessionId,
      );

      await updateReminder(key, updatedReminder);
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    final scheduleTime = reminder.sessionStartTime.subtract(
      Duration(minutes: reminder.minutesBefore),
    );

    if (scheduleTime.isBefore(DateTime.now())) {
      // Don't schedule for past times
      return;
    }

    // Create a temporary StudySession for the notification service
    final tempSession = StudySession(
      subjectName: reminder.subjectName,
      startTime: reminder.sessionStartTime,
      endTime: reminder.sessionStartTime
          .add(const Duration(minutes: 60)), // Default duration
      subjectColor: 'FF4CAF50', // Default color
    );

    // Schedule the notification with custom message
    await _notificationService.scheduleNotificationWithCustomMessage(
      tempSession,
      reminder.minutesBefore,
      reminder.message,
      reminder.notificationId,
    );
  }

  Future<void> scheduleRemindersForSession(StudySession session) async {
    // Cancel any existing reminders for this session
    await cancelRemindersForSession(session);

    // Get default reminder settings (you can customize this)
    final defaultReminders = [5, 15, 30]; // 5, 15, 30 minutes before

    for (final minutesBefore in defaultReminders) {
      final reminder = Reminder(
        subjectName: session.subjectName,
        minutesBefore: minutesBefore,
        isEnabled: true,
        message: '$minutesBefore minutes until ${session.subjectName}!',
        sessionStartTime: session.startTime,
        sessionId: session.hashCode.toString(),
      );

      await addReminder(reminder);
    }
  }

  Future<void> cancelRemindersForSession(StudySession session) async {
    final sessionReminders = state
        .where(
          (reminder) => reminder.sessionId == session.hashCode.toString(),
        )
        .toList();

    for (final reminder in sessionReminders) {
      await deleteReminder(reminder.key);
    }
  }

  List<Reminder> getRemindersForSubject(String subjectName) {
    return state
        .where((reminder) => reminder.subjectName == subjectName)
        .toList();
  }

  List<Reminder> getActiveReminders() {
    return state.where((reminder) => reminder.isEnabled).toList();
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  return RemindersNotifier(notificationService);
});
