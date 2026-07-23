import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/models.dart';
import 'package:intl/intl.dart';

class LocalRepository extends ChangeNotifier {
  UserProfile? _userProfile;
  List<MealEntry> _meals = [];
  List<FoodItem> _favorites = [];
  List<WorkoutEntry> _workoutEntries = [];
  List<WeightEntry> _weightEntries = [];
  final Map<String, WorkoutSet> _lastExerciseHistory = {};
  AIProviderConfig _aiConfig = AIProviderConfig();
  bool _healthSyncEnabled = false;

  LocalRepository() {
    _initDefaultProfile();
  }

  void _initDefaultProfile() {
    _userProfile = UserProfile(
      id: 'default_user',
      heightCm: 178,
      weightKg: 75.0,
      bodyFatPercentage: 18.0,
      birthYear: 1995,
      sex: 'male',
      activityLevel: 1.55,
      pace: 'maintain',
    );
  }

  UserProfile get userProfile => _userProfile!;

  void saveUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  AIProviderConfig get aiConfig => _aiConfig;

  void saveAIConfig(AIProviderConfig config) {
    _aiConfig = config;
    notifyListeners();
  }

  bool get healthSyncEnabled => _healthSyncEnabled;

  void setHealthSyncEnabled(bool enabled) {
    _healthSyncEnabled = enabled;
    notifyListeners();
  }

  List<MealEntry> getMealsForDate(String dateKey) {
    return _meals.where((m) => m.dateKey == dateKey).toList();
  }

  void addMeal(MealEntry meal) {
    _meals.insert(0, meal);
    notifyListeners();
  }

  void copyMealsFromDate(String sourceDateKey, String targetDateKey) {
    final sourceMeals = getMealsForDate(sourceDateKey);
    for (var m in sourceMeals) {
      _meals.insert(
        0,
        MealEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString() + m.id,
          timestamp: DateTime.now(),
          dateKey: targetDateKey,
          mealType: m.mealType,
          title: m.title,
          notes: m.notes,
          source: 'copy',
          items: List.from(m.items),
        ),
      );
    }
    notifyListeners();
  }

  void deleteMeal(String mealId) {
    _meals.removeWhere((m) => m.id == mealId);
    notifyListeners();
  }

  List<FoodItem> get favorites => List.unmodifiable(_favorites);

  void toggleFavorite(FoodItem item) {
    final idx = _favorites.indexWhere((f) => f.name == item.name);
    if (idx != -1) {
      _favorites.removeAt(idx);
    } else {
      _favorites.add(item);
    }
    notifyListeners();
  }

  List<WorkoutEntry> get allWorkouts => List.unmodifiable(_workoutEntries);

  void addWorkout(WorkoutEntry workout) {
    _workoutEntries.insert(0, workout);
    for (var set in workout.sets) {
      _lastExerciseHistory[set.exerciseName.toLowerCase().trim()] = set;
    }
    notifyListeners();
  }

  WorkoutSet? getLastExerciseHistory(String exerciseName) {
    return _lastExerciseHistory[exerciseName.toLowerCase().trim()];
  }

  void deleteWorkout(String workoutId) {
    _workoutEntries.removeWhere((w) => w.id == workoutId);
    notifyListeners();
  }

  List<WeightEntry> get weightEntries => List.unmodifiable(_weightEntries);

  void addWeight(double weightKg, {double? bodyFat, String? note, bool fromHealthConnect = false}) {
    _weightEntries.add(WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weightKg: weightKg,
      bodyFatPercentage: bodyFat ?? _userProfile?.bodyFatPercentage,
      note: note,
      syncedFromHealthConnect: fromHealthConnect,
    ));
    _userProfile = UserProfile(
      id: _userProfile!.id,
      heightCm: _userProfile!.heightCm,
      weightKg: weightKg,
      bodyFatPercentage: bodyFat ?? _userProfile!.bodyFatPercentage,
      birthYear: _userProfile!.birthYear,
      sex: _userProfile!.sex,
      activityLevel: _userProfile!.activityLevel,
      pace: _userProfile!.pace,
    );
    notifyListeners();
  }

  void deleteWeight(String weightId) {
    _weightEntries.removeWhere((w) => w.id == weightId);
    notifyListeners();
  }

  void deleteAllData() {
    _meals = [];
    _favorites = [];
    _workoutEntries = [];
    _weightEntries = [];
    _lastExerciseHistory.clear();
    _aiConfig = AIProviderConfig();
    _healthSyncEnabled = false;
    _initDefaultProfile();
    notifyListeners();
  }
}

final localRepositoryProvider = ChangeNotifierProvider<LocalRepository>((ref) {
  return LocalRepository();
});
