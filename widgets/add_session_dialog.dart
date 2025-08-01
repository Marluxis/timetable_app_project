import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_scheduler/data/models/study_session.dart';
import 'package:study_scheduler/data/models/subject.dart';
import 'package:study_scheduler/providers/schedule_provider.dart';
import 'package:study_scheduler/providers/subject_provider.dart';

class AddSessionDialog extends ConsumerStatefulWidget {
  final DateTime? selectedDate;
  final StudySession? existingSession; // For editing mode
  final int? sessionKey; // Hive key for editing mode

  const AddSessionDialog({
    super.key,
    this.selectedDate,
    this.existingSession,
    this.sessionKey,
  });

  @override
  ConsumerState<AddSessionDialog> createState() => _AddSessionDialogState();
}

class _AddSessionDialogState extends ConsumerState<AddSessionDialog> {
  Subject? selectedSubject;
  late DateTime selectedDate;
  late TimeOfDay startTime;
  int duration = 45; // minutes

  bool get isEditMode => widget.existingSession != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      // Initialize with existing session data
      final session = widget.existingSession!;
      selectedDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      startTime = TimeOfDay.fromDateTime(session.startTime);
      duration = session.endTime.difference(session.startTime).inMinutes;

      // Find the matching subject
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final subjects = ref.read(subjectsProvider);
        selectedSubject = subjects.firstWhere(
          (subject) => subject.name == session.subjectName,
          orElse: () => subjects.isNotEmpty ? subjects.first : subjects.first,
        );
        setState(() {});
      });
    } else {
      selectedDate = widget.selectedDate ?? DateTime.now();
      // Set default time to current time for new sessions
      final now = DateTime.now();
      startTime = TimeOfDay.fromDateTime(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);

    if (subjects.isEmpty) {
      return AlertDialog(
        title: const Text('No Subjects Available'),
        content:
            const Text('Please add subjects first before creating sessions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(isEditMode ? 'Edit Study Session' : 'Add Study Session'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subject selection
            DropdownButtonFormField<Subject>(
              value: selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              items: subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(int.parse(subject.color, radix: 16)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(subject.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Subject? value) {
                setState(() {
                  selectedSubject = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Date selection
            ListTile(
              title: const Text('Date'),
              subtitle:
                  Text(DateFormat('EEEE, MMM d, yyyy').format(selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),

            const SizedBox(height: 8),

            // Start time selection
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(startTime.format(context)),
              trailing: const Icon(Icons.access_time),
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
            ),

            const SizedBox(height: 16),

            // Duration selection
            Row(
              children: [
                const Text('Duration: '),
                Expanded(
                  child: Slider(
                    value: duration.toDouble(),
                    min: 15,
                    max: 180,
                    divisions: 11,
                    label: '$duration minutes',
                    onChanged: (double value) {
                      setState(() {
                        duration = value.round();
                      });
                    },
                  ),
                ),
                Text('$duration min'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedSubject == null
              ? null
              : () async {
                  final startDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    startTime.hour,
                    startTime.minute,
                  );

                  final session = StudySession(
                    subjectName: selectedSubject!.name,
                    startTime: startDateTime,
                    endTime: startDateTime.add(Duration(minutes: duration)),
                    subjectColor: selectedSubject!.color,
                  );

                  if (isEditMode) {
                    // Update existing session
                    await ref.read(scheduleProvider.notifier).updateSession(
                          widget.sessionKey!,
                          session,
                        );
                  } else {
                    // Add new session
                    await ref
                        .read(scheduleProvider.notifier)
                        .addSession(session);
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
          child: Text(isEditMode ? 'Update Session' : 'Add Session'),
        ),
      ],
    );
  }
}
