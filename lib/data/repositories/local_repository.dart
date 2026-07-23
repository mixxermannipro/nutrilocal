import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/models.dart';

class LocalRepository extends ChangeNotifier {
  UserProfile? _userProfile;
  List<MealEntry> _meals = [];
  List<WorkoutEntry> _workoutEntries = [];
  List<WeightEntry> _weightEntries = [];
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

  void updateMeal(MealEntry meal) {
    final idx = _meals.indexWhere((m) => m.id == meal.id);
    if (idx != -1) {
      _meals[idx] = meal;
      notifyListeners();
    }
  }

  void deleteMeal(String mealId) {
    _meals.removeWhere((m) => m.id == mealId);
    notifyListeners();
  }

  List<WorkoutEntry> getWorkoutsForDate(String dateKey) {
    return _workoutEntries.where((w) => w.dateKey == dateKey).toList();
  }

  List<WorkoutEntry> get allWorkouts => List.unmodifiable(_workoutEntries);

  void addWorkout(WorkoutEntry workout) {
    _workoutEntries.insert(0, workout);
    notifyListeners();
  }

  void deleteWorkout(String workoutId) {
    _workoutEntries.removeWhere((w) => w.id == workoutId);
    notifyListeners();
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
    _userProfile = UserProfile(
      id: _userProfile!.id,
      heightCm: _userProfile!.heightCm,
      weightKg: weightKg,
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
    _workoutEntries = [];
    _weightEntries = [];
    _aiConfig = AIProviderConfig();
    _healthSyncEnabled = false;
    _initDefaultProfile();
    notifyListeners();
  }
}

final localRepositoryProvider = ChangeNotifierProvider<LocalRepository>((ref) {
  return LocalRepository();
});
