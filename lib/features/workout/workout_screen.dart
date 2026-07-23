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
  final List<String> _muscleGroups = ['Brust', 'Rücken', 'Beine', 'Schultern', 'Arme', 'Core'];

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
        label: const Text('Workout erfassen', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      'Noch keine Workouts erfasst.\nTippe unten auf "Workout erfassen"!',
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
                                  color: AppColors.lightAccent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('~${w.energyBurnedKcal.round()} kcal',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightAccent, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${w.muscleGroup} • ${w.durationMinutes} Minuten',
                              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                          const Divider(height: 24),
                          ...w.sets.map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('• ${s.exerciseName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    Text('${s.weightKg} kg × ${s.reps} Wdh ${s.rpe != null ? "(RPE ${s.rpe})" : ""}',
                                        style: const TextStyle(color: AppColors.protein, fontWeight: FontWeight.bold, fontSize: 13)),
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
    final nameCtrl = TextEditingController(text: 'Oberkörper Training');
    final durationCtrl = TextEditingController(text: '45');
    final burnCtrl = TextEditingController(text: '300');
    final exerciseCtrl = TextEditingController(text: 'Bankdrücken');
    final weightCtrl = TextEditingController(text: '70');
    final repsCtrl = TextEditingController(text: '10');
    String selectedMuscle = 'Brust';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neues Workout erfassen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Workout Name')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedMuscle,
                decoration: const InputDecoration(labelText: 'Fokus Muskelgruppe'),
                items: _muscleGroups.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => selectedMuscle = v!,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dauer (Min)'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: burnCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kcal Burn'))),
                ],
              ),
              const Divider(height: 24),
              const Text('Übung & Satz Hinzufügen', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: exerciseCtrl, decoration: const InputDecoration(labelText: 'Übungsname')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gewicht (kg)'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: repsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Wiederholungen'))),
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
              final repo = ref.read(localRepositoryProvider);
              final todayKey = DateTime.now().toString().split(' ')[0];

              final workout = WorkoutEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                timestamp: DateTime.now(),
                dateKey: todayKey,
                name: nameCtrl.text.isNotEmpty ? nameCtrl.text : 'Krafttraining',
                muscleGroup: selectedMuscle,
                durationMinutes: int.tryParse(durationCtrl.text) ?? 45,
                energyBurnedKcal: double.tryParse(burnCtrl.text) ?? 300,
                sets: [
                  WorkoutSet(
                    exerciseName: exerciseCtrl.text.isNotEmpty ? exerciseCtrl.text : 'Grundübung',
                    setOrder: 1,
                    weightKg: double.tryParse(weightCtrl.text) ?? 60,
                    reps: int.tryParse(repsCtrl.text) ?? 10,
                  ),
                ],
              );

              repo.addWorkout(workout);
              Navigator.pop(ctx);
            },
            child: const Text('Speichern'),
          )
        ],
      ),
    );
  }
}
