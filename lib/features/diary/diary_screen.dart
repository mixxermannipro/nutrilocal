import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/local_repository.dart';
import '../../core/theme/app_theme.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(localRepositoryProvider);
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final meals = repo.getMealsForDate(dateKey);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagebuch'),
      ),
      body: Column(
        children: [
          // Date Selector Strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainState.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
                ),
                Text(
                  DateFormat('EEEE, d. MMMM', 'de_DE').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: meals.isEmpty
                ? const Center(child: Text('Keine Einträge an diesem Tag.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return Dismissible(
                        key: Key(meal.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          repo.deleteMeal(meal.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${meal.title}" gelöscht')),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(meal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${meal.mealType} • ${meal.totalProtein.round()}g P | ${meal.totalCarbs.round()}g K | ${meal.totalFat.round()}g F'),
                            trailing: Text('${meal.totalKcal.round()} kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightAccent)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
