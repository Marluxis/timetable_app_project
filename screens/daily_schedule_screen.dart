import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_scheduler/providers/reminder_provider.dart';
import 'package:study_scheduler/providers/schedule_provider.dart';
import 'package:study_scheduler/providers/subject_provider.dart';
import 'package:study_scheduler/widgets/add_session_dialog.dart';
import 'package:study_scheduler/widgets/ai_schedule_dialog.dart';
import 'package:study_scheduler/widgets/manage_subjects_dialog.dart';
import 'package:study_scheduler/widgets/subject_notes_dialog.dart';
import 'package:study_scheduler/widgets/set_reminder_dialog.dart';

class DailyScheduleScreen extends ConsumerWidget {
  const DailyScheduleScreen({super.key});

  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = _normalizeDate(DateTime.now());
    final schedule = ref.watch(scheduleProvider);
    final todaysSessions = schedule[today] ?? [];
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with manage subjects button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Class schedule',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const ManageSubjectsDialog(),
                            );
                          },
                          icon: const Icon(Icons.school),
                          tooltip: 'Manage Subjects',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Day • Week • Calendar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE').format(today),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      DateFormat('d MMMM').format(today),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.teal[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Schedule List
          Expanded(
            child: todaysSessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No classes scheduled for today',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subjects.isEmpty
                              ? 'Add subjects first using the school icon above'
                              : 'Add a session manually or check other days',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: todaysSessions.length,
                    itemBuilder: (context, index) {
                      final session = todaysSessions[index];
                      final sessionColor =
                          Color(int.parse(session.subjectColor, radix: 16));

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: sessionColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: sessionColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Session number
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Time and subject info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat.Hm().format(session.startTime)} - ${DateFormat.Hm().format(session.endTime)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      session.subjectName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          'Study Session',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Show notes and reminders indicators
                                        Consumer(
                                          builder: (context, ref, child) {
                                            final subjects =
                                                ref.watch(subjectsProvider);
                                            final reminders =
                                                ref.watch(remindersProvider);

                                            final hasNotes = subjects
                                                .where((subject) =>
                                                    subject.name ==
                                                    session.subjectName)
                                                .any((subject) =>
                                                    subject.notes != null &&
                                                    subject.notes!.isNotEmpty);

                                            final hasReminders = reminders
                                                .where((reminder) =>
                                                    reminder.subjectName ==
                                                        session.subjectName &&
                                                    reminder.isEnabled)
                                                .isNotEmpty;

                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (hasNotes)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 3),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4,
                                                        vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.sticky_note_2,
                                                          size: 10,
                                                          color: Colors.white
                                                              .withOpacity(0.9),
                                                        ),
                                                        const SizedBox(
                                                            width: 2),
                                                        Text(
                                                          'Notes',
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.9),
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (hasReminders)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4,
                                                        vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.alarm_on,
                                                          size: 10,
                                                          color: Colors.white
                                                              .withOpacity(0.9),
                                                        ),
                                                        const SizedBox(
                                                            width: 2),
                                                        Text(
                                                          'Reminder',
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.9),
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Edit button
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AddSessionDialog(
                                      existingSession: session,
                                      sessionKey: session.key,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Edit Session',
                              ),
                              // Notes button
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => SubjectNotesDialog(
                                      subjectName: session.subjectName,
                                      subjectColor: session.subjectColor,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.sticky_note_2,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Add/Edit Notes',
                              ),
                              // Reminder button
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => SetReminderDialog(
                                      session: session,
                                      subjectColor: session.subjectColor,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.alarm_add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Set Reminder',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          // AI Schedule Generation button (left side)
          Positioned(
            left: 30,
            bottom: 0,
            child: FloatingActionButton(
              heroTag: "ai_schedule",
              onPressed: () {
                if (subjects.isEmpty) {
                  // Show message to add subjects first
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('No Subjects Available'),
                      content: const Text(
                          'Please add subjects first using the school icon above, then you can generate AI schedules.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show AI schedule generation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AIScheduleDialog(subjects: subjects),
                  );
                }
              },
              backgroundColor:
                  subjects.isEmpty ? Colors.grey : Colors.teal.shade600,
              tooltip: 'Generate AI Schedule',
              child: const Icon(Icons.auto_awesome),
            ),
          ),
          // Manual Add Session button (right side)
          Positioned(
            right: 16,
            bottom: 0,
            child: FloatingActionButton(
              heroTag: "add_session",
              onPressed: () {
                if (subjects.isEmpty) {
                  // Show message to add subjects first
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('No Subjects Available'),
                      content: const Text(
                          'Please add subjects first using the school icon above, then you can create study sessions.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show add session dialog
                  showDialog(
                    context: context,
                    builder: (context) => const AddSessionDialog(),
                  );
                }
              },
              backgroundColor:
                  subjects.isEmpty ? Colors.grey : Colors.teal.shade600,
              tooltip: 'Add Session',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
