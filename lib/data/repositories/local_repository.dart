import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/models.dart';
import 'package:intl/intl.dart';

class LocalRepository {
  UserProfile? _userProfile;
  final List<MealEntry> _meals = [];
  final List<WaterEntry> _waterEntries = [];
  final List<WorkoutEntry> _workoutEntries = [];
  final List<WeightEntry> _weightEntries = [];
  AIProviderConfig _aiConfig = AIProviderConfig();
  int _waterGoalMl = 2500;

  LocalRepository() {
    _initDefaults();
  }

  void _initDefaults() {
    _userProfile = UserProfile(
      id: 'default_user',
      heightCm: 178,
      weightKg: 75.0,
      birthYear: 1995,
      sex: 'male',
      activityLevel: 1.55,
      pace: 'maintain',
    );

    // Initial weight entry
    _weightEntries.add(WeightEntry(
      id: 'w1',
      date: DateTime.now().subtract(const Duration(days: 7)),
      weightKg: 75.8,
    ));
    _weightEntries.add(WeightEntry(
      id: 'w2',
      date: DateTime.now(),
      weightKg: 75.0,
    ));

    // Sample initial meal
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _meals.add(MealEntry(
      id: 'sample_1',
      timestamp: DateTime.now(),
      dateKey: todayKey,
      mealType: 'Frühstück',
      title: 'Haferflocken mit Beeren & Protein',
      source: 'manual',
      items: [
        FoodItem(
          id: 'item_1',
          name: 'Haferflocken',
          portionQuantity: 80,
          portionUnit: 'g',
          portionGrams: 80,
          energyKcal: 295,
          proteinG: 10.5,
          carbohydrateG: 46.4,
          fatG: 5.6,
          fiberG: 8.0,
        ),
        FoodItem(
          id: 'item_2',
          name: 'Whey Protein Vanille',
          portionQuantity: 30,
          portionUnit: 'g',
          portionGrams: 30,
          energyKcal: 115,
          proteinG: 24.0,
          carbohydrateG: 1.5,
          fatG: 1.2,
        ),
      ],
    ));

    _waterEntries.add(WaterEntry(
      id: 'wat_1',
      timestamp: DateTime.now(),
      dateKey: todayKey,
      amountMl: 500,
    ));
  }

  UserProfile get userProfile => _userProfile!;

  void saveUserProfile(UserProfile profile) {
    _userProfile = profile;
  }

  AIProviderConfig get aiConfig => _aiConfig;

  void saveAIConfig(AIProviderConfig config) {
    _aiConfig = config;
  }

  int get waterGoalMl => _waterGoalMl;

  void setWaterGoal(int ml) {
    _waterGoalMl = ml;
  }

  List<MealEntry> getMealsForDate(String dateKey) {
    return _meals.where((m) => m.dateKey == dateKey).toList();
  }

  void addMeal(MealEntry meal) {
    _meals.insert(0, meal);
  }

  void updateMeal(MealEntry meal) {
    final idx = _meals.indexWhere((m) => m.id == meal.id);
    if (idx != -1) {
      _meals[idx] = meal;
    }
  }

  void deleteMeal(String mealId) {
    _meals.removeWhere((m) => m.id == mealId);
  }

  int getWaterTotalForDate(String dateKey) {
    return _waterEntries
        .where((w) => w.dateKey == dateKey)
        .fold(0, (sum, w) => sum + w.amountMl);
  }

  void addWater(int amountMl, String dateKey) {
    _waterEntries.add(WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      dateKey: dateKey,
      amountMl: amountMl,
    ));
  }

  List<WorkoutEntry> getWorkoutsForDate(String dateKey) {
    return _workoutEntries.where((w) => w.dateKey == dateKey).toList();
  }

  void addWorkout(WorkoutEntry workout) {
    _workoutEntries.insert(0, workout);
  }

  List<WeightEntry> get weightEntries => List.unmodifiable(_weightEntries);

  void addWeight(double weightKg, {double? bodyFat, String? note}) {
    _weightEntries.add(WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weightKg: weightKg,
      bodyFatPercentage: bodyFat,
      note: note,
    ));
  }
}

final localRepositoryProvider = Provider<LocalRepository>((ref) {
  return LocalRepository();
});
