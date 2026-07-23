import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_repository.dart';
import '../../domain/models/models.dart';
import '../../core/theme/app_theme.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(localRepositoryProvider);
    final workouts = repo.allWorkouts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tagebuch 🏋️‍♂️'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkoutDialog,
        backgroundColor: AppColors.protein,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Workout erstellen', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: workouts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fitness_center_outlined, size: 54, color: Colors.grey.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    const Text(
                      'Noch keine Workouts erfasst.\nTippe auf "Workout erstellen", um dein erstes Training zu loggen!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, height: 1.4, fontSize: 15),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final w = workouts[index];
                return Dismissible(
                  key: Key(w.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    repo.deleteWorkout(w.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${w.name}" gelöscht')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.protein.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('${w.durationMinutes} Min • ~${w.energyBurnedKcal.round()} kcal',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.protein, fontSize: 13)),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ...w.sets.map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('• ${s.exerciseName} ${s.note != null && s.note!.isNotEmpty ? "(${s.note})" : ""}',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                    ),
                                    Text('${s.weightKg > 0 ? "${s.weightKg} kg × " : ""}${s.reps} WDH',
                                        style: const TextStyle(color: AppColors.protein, fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddWorkoutDialog() {
    final repo = ref.read(localRepositoryProvider);
    final workoutNameCtrl = TextEditingController(text: 'Oberkörper / Pull Workout');
    final exerciseCtrl = TextEditingController(text: 'Pull-ups');
    final weightCtrl = TextEditingController(text: '10');
    final repsCtrl = TextEditingController(text: '6');
    final noteCtrl = TextEditingController(text: '+10kg Zusatzgewicht');

    String previousHistoryText = '';
    final lastSet = repo.getLastExerciseHistory(exerciseCtrl.text);
    if (lastSet != null) {
      previousHistoryText = 'Letztes Mal: ${lastSet.weightKg > 0 ? "${lastSet.weightKg}kg × " : ""}${lastSet.reps} WDH ${lastSet.note != null ? "(${lastSet.note})" : ""}';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Neues Workout erstellen 🏋️‍♂️'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: workoutNameCtrl,
                    decoration: const InputDecoration(labelText: 'Workout Name (z.B. Pull Workout)'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Übung & Sätze Hinzufügen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: exerciseCtrl,
                    decoration: const InputDecoration(labelText: 'Übungsname (z.B. Pull-ups, Bankdrücken)'),
                    onChanged: (val) {
                      final hist = repo.getLastExerciseHistory(val);
                      setDialogState(() {
                        if (hist != null) {
                          previousHistoryText = 'Letztes Mal: ${hist.weightKg > 0 ? "${hist.weightKg}kg × " : ""}${hist.reps} WDH ${hist.note != null ? "(${hist.note})" : ""}';
                        } else {
                          previousHistoryText = 'Erstes Mal ausgeführt!';
                        }
                      });
                    },
                  ),
                  if (previousHistoryText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.protein.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        previousHistoryText,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.protein, fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(labelText: 'Notiz / Zusatzgewicht (z.B. +10kg Zusatzgewicht)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: weightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Gewicht (kg)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: repsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Wiederholungen (WDH)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.protein, foregroundColor: Colors.white),
                onPressed: () {
                  final todayKey = DateTime.now().toString().split(' ')[0];
                  final workout = WorkoutEntry(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    timestamp: DateTime.now(),
                    dateKey: todayKey,
                    name: workoutNameCtrl.text.isNotEmpty ? workoutNameCtrl.text : 'Krafttraining',
                    durationMinutes: 45,
                    energyBurnedKcal: 280,
                    sets: [
                      WorkoutSet(
                        exerciseName: exerciseCtrl.text.isNotEmpty ? exerciseCtrl.text : 'Grundübung',
                        weightKg: double.tryParse(weightCtrl.text) ?? 0,
                        reps: int.tryParse(repsCtrl.text) ?? 6,
                        note: noteCtrl.text.trim(),
                      ),
                    ],
                  );

                  repo.addWorkout(workout);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Workout & Progression gespeichert! 💪')),
                  );
                },
                child: const Text('Speichern'),
              ),
            ],
          );
        },
      ),
    );
  }
}
