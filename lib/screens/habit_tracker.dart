import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final _nameController = TextEditingController();
  List<Map<String, dynamic>> _habits = [];
  static const _key = 'habits_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _habits = await StorageService.loadList(_key);
    setState(() {});
  }

  Future<void> _save() async {
    await StorageService.saveList(_key, _habits);
  }

  Future<void> _addHabit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    _habits.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'days': <String, bool>{}, // map dateString -> done
      'streak': 0,
    });
    _nameController.clear();
    await _save();
    setState(() {});
  }

  void _toggleToday(Map<String, dynamic> h) async {
    final key = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String();
    final days = Map<String, dynamic>.from(h['days'] ?? {});
    final wasDone = (days[key] ?? false) as bool;
    days[key] = !wasDone;
    h['days'] = days;

    // Recalc streak (consecutive days ending today)
    int streak = 0;
    DateTime d = DateTime.now();
    while (true) {
      final k = DateTime(d.year, d.month, d.day).toIso8601String();
      if ((days[k] ?? false) == true) {
        streak += 1;
        d = d.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    h['streak'] = streak;
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
                    labelText: 'اسم العادة (مثل: شرب الماء)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _addHabit,
                icon: const Icon(Icons.add),
                label: const Text('إضافة'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _habits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final h = _habits[_habits.length - 1 - i];
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(h['name'] ?? ''),
                  subtitle: Text('سلسلة الأيام: ${h['streak'] ?? 0}'),
                  trailing: FilledButton(
                    onPressed: () => _toggleToday(h),
                    child: const Text('أنجزت اليوم'),
                  ),
                  leading: const Icon(Icons.flag_outlined),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
