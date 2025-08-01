import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:study_scheduler/data/hive_db.dart';
import 'package:study_scheduler/data/models/subject.dart';

class SubjectsNotifier extends StateNotifier<List<Subject>> {
  SubjectsNotifier() : super([]) {
    _loadSubjects();
  }

  final Box<Subject> _box = HiveDb.getSubjectsBox();

  void _loadSubjects() {
    state = _box.values.toList();
    _box.watch().listen((event) {
      state = _box.values.toList();
    });
  }

  void addSubject(Subject subject) {
    _box.add(subject);
  }

  void updateSubject(int key, Subject subject) {
    _box.put(key, subject);
  }

  void deleteSubject(int key) {
    _box.delete(key);
  }
}

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, List<Subject>>(
    (ref) => SubjectsNotifier());
