import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 0)
class Subject extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String color;

  @HiveField(2)
  String? notes;

  @HiveField(3)
  String? description; // For lecture details like "Lecture, Pythagoras"

  @HiveField(4)
  String? location; // For classroom/location

  Subject({
    required this.name,
    required this.color,
    this.notes,
    this.description,
    this.location,
  });
}
