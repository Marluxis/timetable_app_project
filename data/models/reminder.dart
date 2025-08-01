import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 2)
class Reminder extends HiveObject {
  @HiveField(0)
  late String subjectName;

  @HiveField(1)
  late int minutesBefore; // How many minutes before the session to remind

  @HiveField(2)
  late bool isEnabled; // Whether the reminder is active

  @HiveField(3)
  late String message; // Custom reminder message

  @HiveField(4)
  late DateTime sessionStartTime; // The session time this reminder is for

  @HiveField(5)
  String? sessionId; // Optional: to link to specific session

  Reminder({
    required this.subjectName,
    required this.minutesBefore,
    required this.isEnabled,
    required this.message,
    required this.sessionStartTime,
    this.sessionId,
  });

  // Generate a unique ID for the notification
  int get notificationId => hashCode;
}
