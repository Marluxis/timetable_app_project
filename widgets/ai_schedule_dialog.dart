import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:study_scheduler/data/models/subject.dart';
import 'package:study_scheduler/data/models/study_session.dart';
import 'package:study_scheduler/providers/schedule_provider.dart';

class AIScheduleDialog extends ConsumerStatefulWidget {
  final List<Subject> subjects;

  const AIScheduleDialog({super.key, required this.subjects});

  @override
  ConsumerState<AIScheduleDialog> createState() => _AIScheduleDialogState();
}

class _AIScheduleDialogState extends ConsumerState<AIScheduleDialog> {
  DateTime selectedDate = DateTime.now();
  bool includeBreaks = true;
  int sessionDuration = 60; // minutes
  int breakDuration = 15; // minutes
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Generate AI Schedule'),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'I\'ll create a smart schedule for your study sessions with optimal timing and breaks.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Date selection
              ListTile(
                title: const Text('Target Date'),
                subtitle:
                    Text(DateFormat('EEEE, MMM d, yyyy').format(selectedDate)),
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Time range
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: Colors.teal, size: 20),
                      const SizedBox(width: 8),
                      const Text('Study Hours',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setState(() {
                                startTime = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600)),
                                Text(startTime.format(context),
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setState(() {
                                endTime = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('End',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600)),
                                Text(endTime.format(context),
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Session duration
              Text('Session Duration: $sessionDuration minutes'),
              Slider(
                value: sessionDuration.toDouble(),
                min: 30,
                max: 120,
                divisions: 9,
                activeColor: Colors.teal,
                onChanged: (value) {
                  setState(() {
                    sessionDuration = value.round();
                  });
                },
              ),

              const SizedBox(height: 8),

              // Break settings
              SwitchListTile(
                title: const Text('Include Breaks'),
                subtitle: Text(includeBreaks
                    ? 'Add $breakDuration-minute breaks between sessions'
                    : 'No breaks between sessions'),
                value: includeBreaks,
                activeColor: Colors.teal,
                onChanged: (value) {
                  setState(() {
                    includeBreaks = value;
                  });
                },
              ),

              if (includeBreaks) ...[
                Text('Break Duration: $breakDuration minutes'),
                Slider(
                  value: breakDuration.toDouble(),
                  min: 5,
                  max: 30,
                  divisions: 5,
                  activeColor: Colors.teal,
                  onChanged: (value) {
                    setState(() {
                      breakDuration = value.round();
                    });
                  },
                ),
              ],

              const SizedBox(height: 16),

              // Available subjects preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.teal, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Available Subjects (${widget.subjects.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.subjects.map((subject) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(int.parse(subject.color, radix: 16))
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            subject.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await _generateAISchedule();
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'AI schedule generated for ${DateFormat('MMM d').format(selectedDate)}!'),
                  backgroundColor: Colors.teal,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Generate Schedule'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _generateAISchedule() async {
    final random = Random();
    final scheduleNotifier = ref.read(scheduleProvider.notifier);

    // Clear existing sessions for the selected date
    final existingSessions =
        ref.read(scheduleProvider)[_normalizeDate(selectedDate)] ?? [];
    for (final session in existingSessions) {
      if (session.key != null) {
        await scheduleNotifier.deleteSession(session.key!);
      }
    }

    // Calculate time slots
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    final totalMinutes = endDateTime.difference(startDateTime).inMinutes;
    final sessionWithBreak =
        sessionDuration + (includeBreaks ? breakDuration : 0);
    final maxSessions = totalMinutes ~/ sessionWithBreak;

    // Generate sessions
    DateTime currentTime = startDateTime;
    final shuffledSubjects = List.from(widget.subjects)..shuffle(random);

    for (int i = 0; i < maxSessions && i < widget.subjects.length * 2; i++) {
      if (currentTime
          .add(Duration(minutes: sessionDuration))
          .isAfter(endDateTime)) {
        break;
      }

      final subject = shuffledSubjects[i % shuffledSubjects.length];
      final session = StudySession(
        subjectName: subject.name,
        startTime: currentTime,
        endTime: currentTime.add(Duration(minutes: sessionDuration)),
        subjectColor: subject.color,
      );

      await scheduleNotifier.addSession(session);

      // Move to next time slot
      currentTime = currentTime.add(Duration(minutes: sessionWithBreak));
    }
  }

  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }
}
