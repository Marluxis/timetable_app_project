import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_scheduler/data/models/subject.dart';
import 'package:study_scheduler/providers/subject_provider.dart';
import 'package:study_scheduler/widgets/subject_notes_dialog.dart';

class ManageSubjectsDialog extends ConsumerWidget {
  const ManageSubjectsDialog({super.key});

  void _showEditNoteDialog(
      BuildContext context, WidgetRef ref, Subject subject) {
    final TextEditingController notesController =
        TextEditingController(text: subject.notes);
    final TextEditingController descriptionController =
        TextEditingController(text: subject.description);
    final TextEditingController locationController =
        TextEditingController(text: subject.location);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${subject.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (e.g., Lecture, Advanced Topics)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (e.g., Room 101, Online)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
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
              onPressed: () {
                final updatedSubject = Subject(
                  name: subject.name,
                  color: subject.color,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  location: locationController.text.isEmpty
                      ? null
                      : locationController.text,
                );
                ref
                    .read(subjectsProvider.notifier)
                    .updateSubject(subject.key, updatedSubject);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final subjectNotifier = ref.read(subjectsProvider.notifier);
    final TextEditingController nameController = TextEditingController();

    // Beautiful rainbow color palette
    final List<Color> colorOptions = [
      const Color(0xFFE53E3E), // Red
      const Color(0xFFFF8C00), // Orange
      const Color(0xFFFFD700), // Yellow
      const Color(0xFF38A169), // Green
      const Color(0xFF3182CE), // Blue
      const Color(0xFF805AD5), // Purple
      const Color(0xFFD53F8C), // Pink
      const Color(0xFF319795), // Teal
    ];

    Color selectedColor = colorOptions[0];

    return AlertDialog(
      title: const Text('Manage Subjects'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: subjects.isEmpty
                  ? const Center(
                      child: Text(
                        'No subjects added yet.\nAdd your first subject below!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    Color(int.parse(subject.color, radix: 16)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  subject.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                // Show notes indicator if notes exist
                                if (subject.notes != null &&
                                    subject.notes!.isNotEmpty)
                                  Container(
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
                              ],
                            ),
                            subtitle: subject.description != null
                                ? Text(subject.description!)
                                : const Text('Tap to add details'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.sticky_note_2),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => SubjectNotesDialog(
                                        subjectName: subject.name,
                                        subjectColor: subject.color,
                                      ),
                                    );
                                  },
                                  tooltip: 'Add/Edit Notes',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    subjectNotifier.deleteSubject(subject.key);
                                  },
                                  tooltip: 'Delete Subject',
                                ),
                              ],
                            ),
                            onTap: () {
                              _showEditNoteDialog(context, ref, subject);
                            },
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(builder: (context, setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Color:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: colorOptions.map((color) {
                      final isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              final newSubject = Subject(
                name: nameController.text,
                color: selectedColor.value.toRadixString(16),
              );
              subjectNotifier.addSubject(newSubject);
              nameController.clear();
            }
          },
          child: const Text('Add Subject'),
        ),
      ],
    );
  }
}
