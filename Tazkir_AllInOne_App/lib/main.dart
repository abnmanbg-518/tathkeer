import 'package:flutter/material.dart';
import 'screens/expense_tracker.dart';
import 'screens/med_reminder.dart';
import 'screens/smart_notes.dart';
import 'screens/habit_tracker.dart';
import 'screens/student_organizer.dart';

void main() {
  runApp(const AllInOneApp());
}

class AllInOneApp extends StatelessWidget {
  const AllInOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tazkir – All in One',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = const [
    ExpenseTrackerScreen(),
    MedReminderScreen(),
    SmartNotesScreen(),
    HabitTrackerScreen(),
    StudentOrganizerScreen(),
  ];

  final _titles = const [
    'الدخل والمصروف',
    'مذكّر الأدوية',
    'دفتر الملاحظات',
    'عاداتي اليومية',
    'منظّم الطلاب',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Tazkir – All in One',
                applicationVersion: '1.0.0',
                children: const [
                  Text('نسخة مبسّطة للتعلّم والعرض على المتجر بإذن الله.'),
                ],
              );
            },
            icon: const Icon(Icons.info_outline),
          )
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'مصروف'),
          NavigationDestination(icon: Icon(Icons.medication_outlined), label: 'أدوية'),
          NavigationDestination(icon: Icon(Icons.note_alt_outlined), label: 'ملاحظات'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'عادات'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'طلاب'),
        ],
      ),
    );
  }
}
