import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class SmartNotesScreen extends StatefulWidget {
  const SmartNotesScreen({super.key});

  @override
  State<SmartNotesScreen> createState() => _SmartNotesScreenState();
}

class _SmartNotesScreenState extends State<SmartNotesScreen> {
  final _textController = TextEditingController();
  DateTime? _reminder;
  List<Map<String, dynamic>> _notes = [];
  static const _key = 'notes_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _notes = await StorageService.loadList(_key);
    setState(() {});
  }

  Future<void> _save() async {
    await StorageService.saveList(_key, _notes);
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (time == null) return;
    setState(() {
      _reminder = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _addNote() async {
    final txt = _textController.text.trim();
    if (txt.isEmpty) return;
    _notes.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': txt,
      'reminder': _reminder?.toIso8601String(),
      'created': DateTime.now().toIso8601String(),
    });
    _textController.clear();
    _reminder = null;
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
            controller: _textController,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'اكتب ملاحظة...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.alarm_add_outlined),
                label: Text(_reminder == null ? 'تذكير (اختياري)' : DateFormat.yMd().add_Hm().format(_reminder!)),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _addNote,
                icon: const Icon(Icons.add),
                label: const Text('حفظ'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final e = _notes[_notes.length - 1 - i];
                final rem = e['reminder'] != null ? DateTime.tryParse(e['reminder']) : null;
                final created = DateTime.tryParse(e['created'] ?? '');
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(e['text'] ?? ''),
                  subtitle: Text([
                    if (created != null) 'أُنشئت: ${DateFormat.yMd().add_Hm().format(created)}',
                    if (rem != null) 'تذكير: ${DateFormat.yMd().add_Hm().format(rem)}',
                  ].join(' • ')),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      _notes.removeWhere((x) => x['id'] == e['id']);
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
