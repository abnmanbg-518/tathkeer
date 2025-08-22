import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense'; // 'income' or 'expense'
  String _category = 'عام';
  List<Map<String, dynamic>> _items = [];

  static const _key = 'expenses_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _items = await StorageService.loadList(_key);
    setState(() {});
  }

  Future<void> _save() async {
    await StorageService.saveList(_key, _items);
  }

  double get totalIncome => _items.where((e) => e['type'] == 'income').fold(0.0, (p, e) => p + (e['amount'] as num).toDouble());
  double get totalExpense => _items.where((e) => e['type'] == 'expense').fold(0.0, (p, e) => p + (e['amount'] as num).toDouble());
  double get balance => totalIncome - totalExpense;

  Future<void> _addItem() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return;
    _items.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': _type,
      'category': _category,
      'amount': amount,
      'note': _noteController.text.trim(),
      'date': DateTime.now().toIso8601String(),
    });
    _amountController.clear();
    _noteController.clear();
    await _save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat('#,##0.##');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('الدخل', f.format(totalIncome)),
                  _stat('المصروف', f.format(totalExpense)),
                  _stat('الرصيد', f.format(balance)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'المبلغ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('مصروف')),
                  DropdownMenuItem(value: 'income', child: Text('دخل')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'عام', child: Text('عام')),
                  DropdownMenuItem(value: 'طعام', child: Text('طعام')),
                  DropdownMenuItem(value: 'مواصلات', child: Text('مواصلات')),
                  DropdownMenuItem(value: 'فواتير', child: Text('فواتير')),
                  DropdownMenuItem(value: 'ترفيه', child: Text('ترفيه')),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'ملاحظة (اختياري)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('إضافة'),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final e = _items[_items.length - 1 - i]; // newest first
                final date = DateTime.tryParse(e['date'] ?? '');
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text('${e['type'] == 'income' ? 'دخل' : 'مصروف'} – ${e['category']} – ${f.format((e['amount'] as num).toDouble())}'),
                  subtitle: Text('${e['note'] ?? ''}${date != null ? ' • ${DateFormat.yMd().add_Hm().format(date)}' : ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      _items.removeWhere((x) => x['id'] == e['id']);
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

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }
}
