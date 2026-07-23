import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/local_repository.dart';
import '../../core/theme/app_theme.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.calorieRingGradient,
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('NutriLocal', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.lightAccent),
            tooltip: 'Gestern kopieren',
            onPressed: () {
              final yesterdayKey = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
              repo.copyMealsFromDate(yesterdayKey, _todayKey);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mahlzeiten von gestern kopiert! 📋')),
              );
            },
          )
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightAccent.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: widget.onOpenLogging,
          backgroundColor: AppColors.lightAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text('Mahlzeit erfassen', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, d. MMMM', 'de_DE').format(DateTime.now()),
                  style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Ziel: ${profile.targetKcal.round()} kcal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightAccent)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fud AI Style Calorie Ring Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: AppColors.glassHeaderGradient,
                ),
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${totalEatenKcal.round()}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1)),
                            const Text('Gegessen', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        // Ring Visualizer with Gradient
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 110,
                              height: 110,
                              child: CircularProgressIndicator(
                                value: (totalEatenKcal / profile.targetKcal).clamp(0.0, 1.0),
                                strokeWidth: 12,
                                backgroundColor: Colors.grey.withOpacity(0.15),
                                color: remainingKcal >= 0 ? AppColors.lightAccent : AppColors.danger,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${remainingKcal.abs()}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: remainingKcal >= 0 ? null : AppColors.danger)),
                                Text(remainingKcal >= 0 ? 'Verbleibend' : 'Drüber', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${(profile.targetKcal - totalEatenKcal).round()}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1)),
                            const Text('Rest Kcal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
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

            const SizedBox(height: 22),

            // Today Meals Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Heutige Mahlzeiten', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                Text('${meals.length} Einträge', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),

            if (meals.isEmpty)
              Padding(
                padding: const EdgeInsets.all(36.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.restaurant_outlined, size: 48, color: Colors.grey.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      const Text('Noch keine Mahlzeiten erfassen.\nTippe unten auf "Mahlzeit erfassen"!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, height: 1.4)),
                    ],
                  ),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      title: Text(meal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('${meal.mealType} • ${meal.totalProtein.round()}g P | ${meal.totalCarbs.round()}g K | ${meal.totalFat.round()}g F', style: const TextStyle(fontSize: 13)),
                      ),
                      trailing: Text('${meal.totalKcal.round()} kcal', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.lightAccent)),
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
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: color.withOpacity(0.15),
            color: color,
          ),
        ),
      ],
    );
  }
}
