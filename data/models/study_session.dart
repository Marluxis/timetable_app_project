import 'package:hive/hive.dart';

part 'study_session.g.dart';

@HiveType(typeId: 1)
class StudySession extends HiveObject {
  @HiveField(0)
  late String subjectName;

  @HiveField(1)
  late DateTime startTime;

  @HiveField(2)
  late DateTime endTime;

  @HiveField(3)
  late String subjectColor;

  StudySession({
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    required this.subjectColor,
  });
}
