import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class MedReminderScreen extends StatefulWidget {
  const MedReminderScreen({super.key});

  @override
  State<MedReminderScreen> createState() => _MedReminderScreenState();
}

class _MedReminderScreenState extends State<MedReminderScreen> {
  final _nameController = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  List<Map<String, dynamic>> _meds = [];
  static const _key = 'meds_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _meds = await StorageService.loadList(_key);
    setState(() {});
  }

  Future<void> _save() async {
    await StorageService.saveList(_key, _meds);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _addMed() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
    _meds.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'time': date.toIso8601String(),
      'taken': false,
    });
    _nameController.clear();
    await _save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الدواء',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time),
                label: Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _addMed,
                icon: const Icon(Icons.add),
                label: const Text('إضافة'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _meds.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final e = _meds[_meds.length - 1 - i];
                final dt = DateTime.tryParse(e['time'] ?? '');
                final taken = (e['taken'] ?? false) as bool;
                return CheckboxListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(e['name'] ?? ''),
                  subtitle: Text(dt != null ? DateFormat.yMd().add_Hm().format(dt) : ''),
                  value: taken,
                  onChanged: (v) async {
                    e['taken'] = v ?? false;
                    await _save();
                    setState(() {});
                  },
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      _meds.removeWhere((x) => x['id'] == e['id']);
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
