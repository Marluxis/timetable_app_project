import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_scheduler/data/models/study_session.dart';
import 'package:study_scheduler/providers/reminder_provider.dart';
import 'package:study_scheduler/providers/schedule_provider.dart';
import 'package:study_scheduler/providers/subject_provider.dart';
import 'package:study_scheduler/widgets/subject_notes_dialog.dart';
import 'package:study_scheduler/widgets/set_reminder_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

class WeeklyCalendarScreen extends ConsumerStatefulWidget {
  const WeeklyCalendarScreen({super.key});

  @override
  ConsumerState<WeeklyCalendarScreen> createState() =>
      _WeeklyCalendarScreenState();
}

class _WeeklyCalendarScreenState extends ConsumerState<WeeklyCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    final schedule = ref.watch(scheduleProvider);
    final selectedDayEvents = schedule[_selectedDay] ?? [];

    List<StudySession> getEventsForDay(DateTime day) {
      return schedule[_normalizeDate(day)] ?? [];
    }

    return Scaffold(
      body: Column(
        children: [
          TableCalendar<StudySession>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = _normalizeDate(selectedDay);
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: getEventsForDay,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: selectedDayEvents.length,
              itemBuilder: (context, index) {
                final session = selectedDayEvents[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Color(int.parse(session.subjectColor, radix: 16)),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(session.subjectName)),
                        // Show notes and reminders indicators
                        Consumer(
                          builder: (context, ref, child) {
                            final subjects = ref.watch(subjectsProvider);
                            final reminders = ref.watch(remindersProvider);

                            final hasNotes = subjects
                                .where((subject) =>
                                    subject.name == session.subjectName)
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
                              children: [
                                if (hasNotes)
                                  Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.sticky_note_2,
                                          size: 12,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Notes',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (hasReminders)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.alarm_on,
                                          size: 12,
                                          color: Colors.orange[600],
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Reminder',
                                          style: TextStyle(
                                            color: Colors.orange[600],
                                            fontSize: 10,
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
                    subtitle: Text(
                      '${DateFormat.jm().format(session.startTime)} - ${DateFormat.jm().format(session.endTime)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                          icon: const Icon(Icons.sticky_note_2),
                          tooltip: 'Add/Edit Notes',
                        ),
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
                          icon: const Icon(Icons.alarm_add),
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
    );
  }
}
