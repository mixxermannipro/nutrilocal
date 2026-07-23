import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/local_repository.dart';
import '../../domain/models/models.dart';
import '../../core/theme/app_theme.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final List<FoodItem> initialItems;
  final String source;
  final String mealType;
  final String defaultTitle;

  const ReviewScreen({
    super.key,
    required this.initialItems,
    required this.source,
    required this.mealType,
    required this.defaultTitle,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late List<FoodItem> _items;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
    if (_items.isEmpty) {
      _items.add(FoodItem(
        id: '1',
        name: widget.defaultTitle,
        portionQuantity: 1,
        portionUnit: 'Portion',
        portionGrams: 200,
        energyKcal: 350,
        proteinG: 20,
        carbohydrateG: 40,
        fatG: 10,
      ));
    }
    _titleController = TextEditingController(text: _items.length == 1 ? _items.first.name : widget.defaultTitle);
  }

  double get _totalKcal => _items.fold(0, (sum, i) => sum + i.energyKcal);
  double get _totalProtein => _items.fold(0, (sum, i) => sum + i.proteinG);
  double get _totalCarbs => _items.fold(0, (sum, i) => sum + i.carbohydrateG);
  double get _totalFat => _items.fold(0, (sum, i) => sum + i.fatG);

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(localRepositoryProvider);
    final profile = repo.userProfile;
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final existingMeals = repo.getMealsForDate(todayKey);
    final currentEatenKcal = existingMeals.fold<double>(0, (sum, m) => sum + m.totalKcal);

    final whatIfTotalKcal = currentEatenKcal + _totalKcal;
    final remainingAfterSave = profile.targetKcal - whatIfTotalKcal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Bestätigen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Mahlzeiten-Titel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // What-If Impact Card (Fud AI Benchmark Feature!)
            Card(
              color: AppColors.lightAccentSoft,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.lightAccent, size: 20),
                        SizedBox(width: 8),
                        Text('What-If? Auswirkung auf heute', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightAccent)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainState.spaceBetween,
                      children: [
                        Text('Diese Mahlzeit: +${_totalKcal.round()} kcal', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('Verbleibend danach: ${remainingAfterSave.round()} kcal',
                            style: TextStyle(fontWeight: FontWeight.bold, color: remainingAfterSave >= 0 ? AppColors.lightAccent : AppColors.danger)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (whatIfTotalKcal / profile.targetKcal).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: Colors.white,
                        color: remainingAfterSave >= 0 ? AppColors.lightAccent : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text('Enthaltene Lebensmittel:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                });
                              },
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text('Gramm: ${item.portionGrams.round()}g'),
                            Expanded(
                              child: Slider(
                                value: item.portionGrams.clamp(10.0, 1000.0),
                                min: 10,
                                max: 1000,
                                onChanged: (v) {
                                  setState(() {
                                    _items[index] = item.copyWithPortion(v / 100.0, v);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainState.spaceAround,
                          children: [
                            Text('${item.energyKcal.round()} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('P: ${item.proteinG.toStringAsFixed(1)}g', style: const TextStyle(color: AppColors.protein)),
                            Text('K: ${item.carbohydrateG.toStringAsFixed(1)}g', style: const TextStyle(color: AppColors.carbs)),
                            Text('F: ${item.fatG.toStringAsFixed(1)}g', style: const TextStyle(color: AppColors.fat)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Total Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainState.spaceBetween,
                      children: [
                        const Text('Gesamtkalorien:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${_totalKcal.round()} kcal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.lightAccent)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainState.spaceAround,
                      children: [
                        Text('Protein: ${_totalProtein.round()}g', style: const TextStyle(color: AppColors.protein, fontWeight: FontWeight.bold)),
                        Text('Carbs: ${_totalCarbs.round()}g', style: const TextStyle(color: AppColors.carbs, fontWeight: FontWeight.bold)),
                        Text('Fett: ${_totalFat.round()}g', style: const TextStyle(color: AppColors.fat, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saveMeal,
                child: const Text('Mahlzeit Speichern', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMeal() {
    final repo = ref.read(localRepositoryProvider);
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final meal = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      dateKey: todayKey,
      mealType: widget.mealType,
      title: _titleController.text.isNotEmpty ? _titleController.text : widget.defaultTitle,
      source: widget.source,
      items: _items,
    );

    repo.addMeal(meal);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${meal.title}" gespeichert! 🎉'),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () {
            repo.deleteMeal(meal.id);
          },
        ),
      ),
    );
  }
}
