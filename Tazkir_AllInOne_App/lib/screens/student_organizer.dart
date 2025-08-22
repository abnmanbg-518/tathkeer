import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class StudentOrganizerScreen extends StatefulWidget {
  const StudentOrganizerScreen({super.key});

  @override
  State<StudentOrganizerScreen> createState() => _StudentOrganizerScreenState();
}

class _StudentOrganizerScreenState extends State<StudentOrganizerScreen> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(days: 1));
  List<Map<String, dynamic>> _tasks = [];
  static const _key = 'student_tasks_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _tasks = await StorageService.loadList(_key);
    setState(() {});
  }

  Future<void> _save() async {
    await StorageService.saveList(_key, _tasks);
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (time == null) return;
    setState(() {
      _due = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    _tasks.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'subject': _subjectController.text.trim(),
      'due': _due.toIso8601String(),
      'done': false,
    });
    _titleController.clear();
    _subjectController.clear();
    _due = DateTime.now().add(const Duration(days: 1));
    await _save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'عنوان المهمة/الواجب',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'المادة (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _pickDue,
                icon: const Icon(Icons.event_outlined),
                label: Text(DateFormat.yMd().add_Hm().format(_due)),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _addTask,
                icon: const Icon(Icons.add),
                label: const Text('إضافة'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final t = _tasks[_tasks.length - 1 - i];
                final due = DateTime.tryParse(t['due'] ?? '');
                final done = (t['done'] ?? false) as bool;
                return CheckboxListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(t['title'] ?? ''),
                  subtitle: Text([
                    if ((t['subject'] ?? '').toString().isNotEmpty) 'المادة: ${t['subject']}',
                    if (due != null) 'التسليم: ${DateFormat.yMd().add_Hm().format(due)}',
                  ].join(' • ')),
                  value: done,
                  onChanged: (v) async {
                    t['done'] = v ?? false;
                    await _save();
                    setState(() {});
                  },
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      _tasks.removeWhere((x) => x['id'] == t['id']);
                      await _save();
                      setState(() {});
                    },
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
