import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_scheduler/data/models/subject.dart';
import 'package:study_scheduler/providers/subject_provider.dart';

class SubjectNotesDialog extends ConsumerStatefulWidget {
  final String subjectName;
  final String subjectColor;

  const SubjectNotesDialog({
    super.key,
    required this.subjectName,
    required this.subjectColor,
  });

  @override
  ConsumerState<SubjectNotesDialog> createState() => _SubjectNotesDialogState();
}

class _SubjectNotesDialogState extends ConsumerState<SubjectNotesDialog> {
  late TextEditingController _notesController;
  Subject? _currentSubject;
  int? _subjectKey;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _loadSubjectNotes();
  }

  void _loadSubjectNotes() {
    final subjects = ref.read(subjectsProvider);
    for (final subject in subjects) {
      if (subject.name == widget.subjectName) {
        _currentSubject = subject;
        _subjectKey = subject.key;
        _notesController.text = _currentSubject?.notes ?? '';
        break;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveNotes() {
    if (_currentSubject != null && _subjectKey != null) {
      final updatedSubject = Subject(
        name: _currentSubject!.name,
        color: _currentSubject!.color,
        notes: _notesController.text.trim(),
        description: _currentSubject!.description,
        location: _currentSubject!.location,
      );

      ref
          .read(subjectsProvider.notifier)
          .updateSubject(_subjectKey!, updatedSubject);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notes saved for ${widget.subjectName}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(int.parse(widget.subjectColor, radix: 16));

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
                    Icons.sticky_note_2,
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
                        'Notes for ${widget.subjectName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Add your thoughts, reminders, or important points',
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

            // Notes Input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.yellow[200]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Write your notes here...\n\n• Key concepts to remember\n• Homework assignments\n• Study tips\n• Questions to ask',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Character count and action buttons
            Row(
              children: [
                Flexible(
                  child: ListenableBuilder(
                    listenable: _notesController,
                    builder: (context, child) {
                      return Text(
                        '${_notesController.text.length} characters',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 40),
                TextButton(
                  onPressed: () {
                    _notesController.clear();
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  onPressed: _saveNotes,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subjectColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
