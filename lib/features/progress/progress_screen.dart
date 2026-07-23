import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_repository.dart';
import '../../core/theme/app_theme.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  final _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(localRepositoryProvider);
    final weights = repo.weightEntries;
    final latestWeight = weights.isNotEmpty ? weights.last.weightKg : repo.userProfile.weightKg;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fortschritt & Trends 📈'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Weight Card & Quick Add
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainState.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Aktuelles Gewicht', style: TextStyle(color: Colors.grey)),
                            Text('${latestWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Gewicht loggen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showAddWeightDialog(repo),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text('Gewichtsverlauf (Letzte Einträge):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weights.length,
              itemBuilder: (context, index) {
                final w = weights[weights.length - 1 - index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.monitor_weight_outlined, color: AppColors.lightAccent),
                    title: Text('${w.weightKg.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${w.date.day}.${w.date.month}.${w.date.year}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWeightDialog(LocalRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neues Gewicht eintragen'),
        content: TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Gewicht in kg (z.B. 74.5)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(_weightController.text);
              if (val != null) {
                repo.addWeight(val);
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
