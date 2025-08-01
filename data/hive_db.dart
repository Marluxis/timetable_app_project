import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study_scheduler/data/models/reminder.dart';
import 'package:study_scheduler/data/models/study_session.dart';
import 'package:study_scheduler/data/models/subject.dart';

class HiveDb {
  static const String subjectsBoxName = 'subjects';
  static const String sessionsBoxName = 'sessions';
  static const String remindersBoxName = 'reminders';

  static Future<void> init() async {
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    } else {
      await Hive.initFlutter();
    }

    // Register Adapters
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(StudySessionAdapter());
    Hive.registerAdapter(ReminderAdapter());

    // Open Boxes
    await Hive.openBox<Subject>(subjectsBoxName);
    await Hive.openBox<StudySession>(sessionsBoxName);
    await Hive.openBox<Reminder>(remindersBoxName);
  }

  static Box<Subject> getSubjectsBox() {
    return Hive.box<Subject>(subjectsBoxName);
  }

  static Box<StudySession> getSessionsBox() {
    return Hive.box<StudySession>(sessionsBoxName);
  }

  static Box<Reminder> getRemindersBox() {
    return Hive.box<Reminder>(remindersBoxName);
  }
}
