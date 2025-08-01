import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:study_scheduler/data/models/reminder.dart';
import 'package:study_scheduler/data/models/study_session.dart';
import 'package:study_scheduler/providers/reminder_provider.dart';

class SetReminderDialog extends ConsumerStatefulWidget {
  final StudySession session;
  final String subjectColor;

  const SetReminderDialog({
    super.key,
    required this.session,
    required this.subjectColor,
  });

  @override
  ConsumerState<SetReminderDialog> createState() => _SetReminderDialogState();
}

class _SetReminderDialogState extends ConsumerState<SetReminderDialog> {
  late TextEditingController _messageController;
  int _selectedMinutes = 15; // Default to 15 minutes before

  final List<int> _reminderOptions = [
    5,
    10,
    15,
    30,
    60
  ]; // Minutes before session

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text: 'Time for ${widget.session.subjectName}! Get ready to study.',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _addReminder() {
    final reminder = Reminder(
      subjectName: widget.session.subjectName,
      minutesBefore: _selectedMinutes,
      isEnabled: true,
      message: _messageController.text.trim().isEmpty
          ? 'Time for ${widget.session.subjectName}!'
          : _messageController.text.trim(),
      sessionStartTime: widget.session.startTime,
      sessionId: widget.session.hashCode.toString(),
    );

    ref.read(remindersProvider.notifier).addReminder(reminder);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder set for $_selectedMinutes minutes before ${widget.session.subjectName}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View All',
          textColor: Colors.white,
          onPressed: () {
            _showManageRemindersDialog();
          },
        ),
      ),
    );
  }

  void _showManageRemindersDialog() {
    showDialog(
      context: context,
      builder: (context) => ManageRemindersDialog(
        subjectName: widget.session.subjectName,
        subjectColor: widget.subjectColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(int.parse(widget.subjectColor, radix: 16));
    final sessionTime =
        DateFormat('MMM d, h:mm a').format(widget.session.startTime);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: subjectColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.alarm,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Set Reminder',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.session.subjectName} • $sessionTime',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Reminder Time Selection
            const Text(
              'Remind me:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _reminderOptions.map((minutes) {
                final isSelected = _selectedMinutes == minutes;
                return ChoiceChip(
                  label: Text('$minutes min before'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMinutes = minutes;
                    });
                  },
                  selectedColor: subjectColor.withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: isSelected ? subjectColor : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Custom Message
            const Text(
              'Reminder message:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Enter a custom reminder message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                TextButton(
                  onPressed: _showManageRemindersDialog,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  child: const Text(
                    'Manage',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: _addReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subjectColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.alarm_add, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ManageRemindersDialog extends ConsumerWidget {
  final String subjectName;
  final String subjectColor;

  const ManageRemindersDialog({
    super.key,
    required this.subjectName,
    required this.subjectColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReminders = ref.watch(remindersProvider);
    final subjectReminders = allReminders
        .where((reminder) => reminder.subjectName == subjectName)
        .toList();

    final subjectColorValue = Color(int.parse(subjectColor, radix: 16));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: subjectColorValue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.alarm,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminders for $subjectName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${subjectReminders.length} reminder(s) set',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Reminders List
            Expanded(
              child: subjectReminders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.alarm_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No reminders set for this subject',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: subjectReminders.length,
                      itemBuilder: (context, index) {
                        final reminder = subjectReminders[index];
                        final reminderTime = reminder.sessionStartTime.subtract(
                          Duration(minutes: reminder.minutesBefore),
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              reminder.isEnabled
                                  ? Icons.alarm_on
                                  : Icons.alarm_off,
                              color: reminder.isEnabled
                                  ? subjectColorValue
                                  : Colors.grey,
                            ),
                            title: Text(
                              '${reminder.minutesBefore} minutes before',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(reminder.message),
                                const SizedBox(height: 4),
                                Text(
                                  'At ${DateFormat('MMM d, h:mm a').format(reminderTime)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value: reminder.isEnabled,
                                      onChanged: (value) {
                                        ref
                                            .read(remindersProvider.notifier)
                                            .toggleReminder(reminder.key);
                                      },
                                      activeColor: subjectColorValue,
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 20,
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      ref
                                          .read(remindersProvider.notifier)
                                          .deleteReminder(reminder.key);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Close Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: subjectColorValue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
