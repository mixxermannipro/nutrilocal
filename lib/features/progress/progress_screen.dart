import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/services/weight_analysis_service.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(localRepositoryProvider);
    final weights = repo.weightEntries;
    final latestWeight = weights.isNotEmpty ? weights.last.weightKg : repo.userProfile.weightKg;
    final latestBodyFat = weights.isNotEmpty && weights.last.bodyFatPercentage != null
        ? weights.last.bodyFatPercentage!
        : (repo.userProfile.bodyFatPercentage ?? 18.0);

    final emaWeight = WeightAnalysisService.calculateEMAWeight(weights);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fortschritt & Körperwerte 📈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.lightAccent),
            tooltip: 'Mit Health Connect synchronisieren',
            onPressed: () {
              repo.addWeight(latestWeight, bodyFat: latestBodyFat, note: 'Health Connect Auto-Sync', fromHealthConnect: true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Körperwerte von Health Connect synchronisiert! 💚')),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fud AI Style Weight & Body Fat Cards
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gewicht (7d Trend)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('${latestWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                            Text('Glatt: ${emaWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 12, color: AppColors.lightAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Körperfett %', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('${latestBodyFat.toStringAsFixed(1)} %', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.carbs)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Messwert eintragen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _showAddWeightDialog(repo),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text('Messverlauf & Health Connect Logs:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (weights.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.show_chart, size: 48, color: Colors.grey.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      const Text('Noch keine Körperwerte erfasst.\nTippe auf "Messwert eintragen" oder nutze den Health Connect Sync!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, height: 1.4)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weights.length,
                itemBuilder: (context, index) {
                  final w = weights[weights.length - 1 - index];
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
                      repo.deleteWeight(w.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Eintrag gelöscht')),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          w.syncedFromHealthConnect ? Icons.favorite : Icons.monitor_weight_outlined,
                          color: w.syncedFromHealthConnect ? Colors.green : AppColors.lightAccent,
                        ),
                        title: Text('${w.weightKg.toStringAsFixed(1)} kg ${w.bodyFatPercentage != null ? "• ${w.bodyFatPercentage!.toStringAsFixed(1)}% KFA" : ""}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${w.date.day}.${w.date.month}.${w.date.year} ${w.syncedFromHealthConnect ? "(Health Connect Sync)" : ""}'),
                      ),
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
        title: const Text('Messwert eintragen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Gewicht in kg (z.B. 74.5)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyFatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Körperfett % (z.B. 17.5)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () {
              final w = double.tryParse(_weightController.text);
              final bf = double.tryParse(_bodyFatController.text);
              if (w != null) {
                repo.addWeight(w, bodyFat: bf);
                _weightController.clear();
                _bodyFatController.clear();
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
