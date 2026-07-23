import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<Map<String, dynamic>> _workouts = [
    {
      'name': 'Oberkörper Kraft A',
      'duration': 60,
      'burnKcal': 320,
      'date': 'Heute',
      'exercises': ['Bankdrücken (4x8, 80kg)', 'Klimmzüge (4x10)', 'Schulterdrücken (3x10, 22kg)']
    },
    {
      'name': 'Unterkörper Kraft B',
      'duration': 50,
      'burnKcal': 380,
      'date': 'Gestern',
      'exercises': ['Kniebeugen (4x8, 100kg)', 'Kreuzheben (3x6, 120kg)', 'Wadenheben (4x15)']
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tagebuch 🏋️‍♂️'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWorkoutDialog,
        backgroundColor: AppColors.protein,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Workout Loggen'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _workouts.length,
        itemBuilder: (context, index) {
          final w = _workouts[index];
          final List exercises = w['exercises'];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainState.spaceBetween,
                    children: [
                      Text(w['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('~${w['burnKcal']} kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightAccent)),
                    ],
                  ),
                  Text('${w['date']} • ${w['duration']} Minuten', style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 20),
                  ...exercises.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text('• $e', style: const TextStyle(fontSize: 14)),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addWorkoutDialog() {
    final nameCtrl = TextEditingController(text: 'Ganzkörper Training');
    final burnCtrl = TextEditingController(text: '300');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neues Workout erfassen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Workout Name')),
            const SizedBox(height: 12),
            TextField(controller: burnCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Geschätzte Kcal')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _workouts.insert(0, {
                  'name': nameCtrl.text,
                  'duration': 45,
                  'burnKcal': int.tryParse(burnCtrl.text) ?? 250,
                  'date': 'Heute',
                  'exercises': ['Freies Training (Sätze & Wdh)']
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text('Speichern'),
          )
        ],
      ),
    );
  }
}
