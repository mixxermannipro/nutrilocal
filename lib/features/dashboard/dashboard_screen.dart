import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/local_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenLogging;
  const DashboardScreen({super.key, required this.onOpenLogging});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late String _todayKey;

  @override
  void initState() {
    super.initState();
    _todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(localRepositoryProvider);
    final profile = repo.userProfile;
    final meals = repo.getMealsForDate(_todayKey);

    final totalEatenKcal = meals.fold<double>(0, (sum, m) => sum + m.totalKcal);
    final totalProtein = meals.fold<double>(0, (sum, m) => sum + m.totalProtein);
    final totalCarbs = meals.fold<double>(0, (sum, m) => sum + m.totalCarbs);
    final totalFat = meals.fold<double>(0, (sum, m) => sum + m.totalFat);

    final remainingKcal = (profile.targetKcal - totalEatenKcal).round();
    final waterMl = repo.getWaterTotalForDate(_todayKey);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriLocal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.water_drop_outlined, color: AppColors.water),
            onPressed: () {
              repo.addWater(250, _todayKey);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('+250 ml Wasser hinzugefügt! 💧'), duration: Duration(seconds: 1)),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onOpenLogging,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkAccent : AppColors.lightAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Mahlzeit loggen', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, d. MMMM', 'de_DE').format(DateTime.now()),
                  style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                Text('Ziel: ${profile.targetKcal.round()} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            // Calorie Ring & Summary Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${totalEatenKcal.round()}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            const Text('Gegessen', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        // Ring Visualizer
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: (totalEatenKcal / profile.targetKcal).clamp(0.0, 1.0),
                                strokeWidth: 10,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                color: remainingKcal >= 0 ? AppColors.lightAccent : AppColors.danger,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${remainingKcal.abs()}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: remainingKcal >= 0 ? null : AppColors.danger)),
                                Text(remainingKcal >= 0 ? 'Verbleibend' : 'Drüber', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${(profile.targetKcal - totalEatenKcal).round()}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            const Text('Rest Kcal', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Macro Progress Bars
                    _buildMacroRow('Protein', totalProtein, profile.targetProteinG, AppColors.protein),
                    const SizedBox(height: 12),
                    _buildMacroRow('Kohlenhydrate', totalCarbs, profile.targetCarbG, AppColors.carbs),
                    const SizedBox(height: 12),
                    _buildMacroRow('Fett', totalFat, profile.targetFatG, AppColors.fat),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick Water Tracker Card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, color: AppColors.water, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wasser: $waterMl / ${repo.waterGoalMl} ml', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text('Tagesfortschritt', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.water),
                      onPressed: () {
                        repo.addWater(250, _todayKey);
                        setState(() {});
                      },
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Today Meals Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Heutige Mahlzeiten', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${meals.length} Einträge', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            if (meals.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('Noch keine Mahlzeiten erfasst. Tippe auf "+ Mahlzeit loggen"!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(meal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${meal.mealType} • ${meal.totalProtein.round()}g P | ${meal.totalCarbs.round()}g K | ${meal.totalFat.round()}g F'),
                      trailing: Text('${meal.totalKcal.round()} kcal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.lightAccent)),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String title, double current, double target, Color color) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${current.round()} / ${target.round()} g', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.15),
            color: color,
          ),
        ),
      ],
    );
  }
}
