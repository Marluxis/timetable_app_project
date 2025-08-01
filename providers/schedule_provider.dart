import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:study_scheduler/data/hive_db.dart';
import 'package:study_scheduler/data/models/study_session.dart';
import 'package:study_scheduler/providers/subject_provider.dart';
import 'package:study_scheduler/services/notification_service.dart';

// Utility to normalize a date to midnight
DateTime _normalizeDate(DateTime dt) {
  return DateTime(dt.year, dt.month, dt.day);
}

class ScheduleNotifier
    extends StateNotifier<Map<DateTime, List<StudySession>>> {
  ScheduleNotifier(this.ref) : super({}) {
    _loadSessions();
  }

  final Ref ref;
  final Box<StudySession> _box = HiveDb.getSessionsBox();

  void _loadSessions() {
    final sessions = _box.values.toList();
    state = groupBy(sessions, (s) => _normalizeDate(s.startTime));

    _box.watch().listen((event) {
      final sessions = _box.values.toList();
      state = groupBy(sessions, (s) => _normalizeDate(s.startTime));
    });
  }

  Future<void> addSession(StudySession session) async {
    await _box.add(session);
  }

  Future<void> updateSession(int key, StudySession updatedSession) async {
    await _box.put(key, updatedSession);
  }

  Future<void> deleteSession(int key) async {
    await _box.delete(key);
  }

  Future<void> generateNewSchedule() async {
    final subjects = ref.read(subjectsProvider);
    if (subjects.isEmpty) return; // Can't generate without subjects

    await _box.clear(); // Clear old schedule
    final notificationService = ref.read(notificationServiceProvider);

    final random = Random();
    final today = _normalizeDate(DateTime.now());

    // Define time slots throughout the day
    final timeSlots = [
      (8, 30), // 8:30 AM
      (9, 25), // 9:25 AM
      (10, 20), // 10:20 AM
      (11, 15), // 11:15 AM
      (12, 30), // 12:30 PM
      (13, 25), // 1:25 PM
      (14, 20), // 2:20 PM
      (15, 15), // 3:15 PM
    ];

    for (int i = 0; i < 7; i++) {
      // Generate for the next 7 days
      final day = today.add(Duration(days: i));

      // Skip weekends for now (optional)
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        continue;
      }

      // Generate 3-5 sessions per day randomly
      final numSessions = 3 + random.nextInt(3); // 3-5 sessions
      final shuffledSlots = List.from(timeSlots)..shuffle(random);

      for (int j = 0; j < numSessions && j < shuffledSlots.length; j++) {
        final randomSubject = subjects[random.nextInt(subjects.length)];
        final timeSlot = shuffledSlots[j];

        final startTime =
            DateTime(day.year, day.month, day.day, timeSlot.$1, timeSlot.$2);
        final duration = 45 + random.nextInt(31); // 45-75 minutes

        final session = StudySession(
          subjectName: randomSubject.name,
          startTime: startTime,
          endTime: startTime.add(Duration(minutes: duration)),
          subjectColor: randomSubject.color,
        );

        await addSession(session);
        // Schedule a notification 10 minutes before the session.
        await notificationService.scheduleNotification(session, 10);
      }
    }
  }
}

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, Map<DateTime, List<StudySession>>>(
        (ref) => ScheduleNotifier(ref));
