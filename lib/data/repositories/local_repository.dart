import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/models.dart';
import '../db/sqlite_database.dart';
import '../datasources/secure_storage_service.dart';

class LocalRepository extends ChangeNotifier {
  UserProfile? _userProfile;
  List<MealEntry> _cachedMeals = [];
  List<FoodItem> _favorites = [];
  List<WorkoutEntry> _workoutEntries = [];
  List<WeightEntry> _weightEntries = [];
  final Map<String, WorkoutSet> _lastExerciseHistory = {};
  AIProviderConfig _aiConfig = AIProviderConfig();
  bool _healthSyncEnabled = false;
  bool _isInitialized = false;

  LocalRepository() {
    init();
  }

  bool get isInitialized => _isInitialized;
  bool get hasProfile => _userProfile != null;

  Future<void> init() async {
    try {
      _userProfile = await SqliteDatabase.loadUserProfile();
      _workoutEntries = await SqliteDatabase.loadAllWorkouts();
      _weightEntries = await SqliteDatabase.loadWeightEntries();

      final keys = await SecureStorageService.readApiKeys();
      _aiConfig = AIProviderConfig(
        primaryApiKey: keys['primaryApiKey'] ?? '',
        fallbackApiKey: keys['fallbackApiKey'] ?? '',
        speechApiKey: keys['speechApiKey'] ?? '',
      );

      for (var w in _workoutEntries) {
        for (var set in w.sets) {
          _lastExerciseHistory[set.exerciseName.toLowerCase().trim()] = set;
        }
      }
    } catch (e) {
      debugPrint('LocalRepository init error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  UserProfile get userProfile => _userProfile ?? UserProfile(
    id: 'default_user',
    heightCm: 178,
    weightKg: 75.0,
    bodyFatPercentage: 18.0,
    birthYear: 1995,
    sex: 'male',
    activityLevel: 1.55,
    pace: 'maintain',
  );

  Future<void> saveUserProfile(UserProfile profile) async {
    _userProfile = profile;
    await SqliteDatabase.saveUserProfile(profile);
    notifyListeners();
  }

  AIProviderConfig get aiConfig => _aiConfig;

  Future<void> saveAIConfig(AIProviderConfig config) async {
    _aiConfig = config;
    await SecureStorageService.saveApiKeys(
      primaryKey: config.primaryApiKey,
      fallbackKey: config.fallbackApiKey,
      speechKey: config.speechApiKey,
    );
    notifyListeners();
  }

  bool get healthSyncEnabled => _healthSyncEnabled;

  void setHealthSyncEnabled(bool enabled) {
    _healthSyncEnabled = enabled;
    notifyListeners();
  }

  List<MealEntry> getMealsForDate(String dateKey) {
    // Return cached meals for date
    return _cachedMeals.where((m) => m.dateKey == dateKey).toList();
  }

  Future<List<MealEntry>> loadMealsForDate(String dateKey) async {
    final meals = await SqliteDatabase.loadMealsForDate(dateKey);
    _cachedMeals.removeWhere((m) => m.dateKey == dateKey);
    _cachedMeals.addAll(meals);
    notifyListeners();
    return meals;
  }

  Future<void> addMeal(MealEntry meal) async {
    _cachedMeals.insert(0, meal);
    await SqliteDatabase.saveMeal(meal);
    notifyListeners();
  }

  Future<void> copyMealsFromDate(String sourceDateKey, String targetDateKey) async {
    final sourceMeals = await SqliteDatabase.loadMealsForDate(sourceDateKey);
    for (var m in sourceMeals) {
      final newMeal = MealEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString() + m.id,
        timestamp: DateTime.now(),
        dateKey: targetDateKey,
        mealType: m.mealType,
        title: m.title,
        notes: m.notes,
        source: 'copy',
        items: List.from(m.items),
      );
      _cachedMeals.insert(0, newMeal);
      await SqliteDatabase.saveMeal(newMeal);
    }
    notifyListeners();
  }

  Future<void> deleteMeal(String mealId) async {
    _cachedMeals.removeWhere((m) => m.id == mealId);
    await SqliteDatabase.deleteMeal(mealId);
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

  Future<void> addWorkout(WorkoutEntry workout) async {
    _workoutEntries.insert(0, workout);
    await SqliteDatabase.saveWorkout(workout);
    for (var set in workout.sets) {
      _lastExerciseHistory[set.exerciseName.toLowerCase().trim()] = set;
    }
    notifyListeners();
  }

  WorkoutSet? getLastExerciseHistory(String exerciseName) {
    return _lastExerciseHistory[exerciseName.toLowerCase().trim()];
  }

  Future<void> deleteWorkout(String workoutId) async {
    _workoutEntries.removeWhere((w) => w.id == workoutId);
    await SqliteDatabase.deleteWorkout(workoutId);
    notifyListeners();
  }

  List<WeightEntry> get weightEntries => List.unmodifiable(_weightEntries);

  Future<void> addWeight(double weightKg, {double? bodyFat, String? note, bool fromHealthConnect = false}) async {
    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weightKg: weightKg,
      bodyFatPercentage: bodyFat ?? _userProfile?.bodyFatPercentage,
      note: note,
      syncedFromHealthConnect: fromHealthConnect,
    );
    _weightEntries.add(entry);
    await SqliteDatabase.saveWeightEntry(entry);

    if (_userProfile != null) {
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
      await SqliteDatabase.saveUserProfile(_userProfile!);
    }
    notifyListeners();
  }

  Future<void> deleteWeight(String weightId) async {
    _weightEntries.removeWhere((w) => w.id == weightId);
    await SqliteDatabase.deleteWeightEntry(weightId);
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    _cachedMeals = [];
    _favorites = [];
    _workoutEntries = [];
    _weightEntries = [];
    _lastExerciseHistory.clear();
    _aiConfig = AIProviderConfig();
    _healthSyncEnabled = false;
    _userProfile = null;

    await SqliteDatabase.deleteAllData();
    await SecureStorageService.deleteAllKeys();
    notifyListeners();
  }
}

final localRepositoryProvider = ChangeNotifierProvider<LocalRepository>((ref) {
  return LocalRepository();
});
