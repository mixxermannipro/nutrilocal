import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import '../../domain/models/models.dart';

class SqliteDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'nutrilocal_v2.sqlite');
    final db = sqlite3.open(dbPath);

    // Create Tables
    db.execute('''
      CREATE TABLE IF NOT EXISTS user_profile (
        id TEXT PRIMARY KEY,
        heightCm REAL NOT NULL,
        weightKg REAL NOT NULL,
        bodyFatPercentage REAL,
        birthYear INTEGER NOT NULL,
        sex TEXT NOT NULL,
        activityLevel REAL NOT NULL,
        pace TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS meal_entries (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        dateKey TEXT NOT NULL,
        mealType TEXT NOT NULL,
        title TEXT NOT NULL,
        notes TEXT,
        source TEXT NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS food_items (
        id TEXT PRIMARY KEY,
        mealId TEXT NOT NULL,
        name TEXT NOT NULL,
        brand TEXT,
        portionQuantity REAL NOT NULL,
        portionUnit TEXT NOT NULL,
        portionGrams REAL NOT NULL,
        energyKcal REAL NOT NULL,
        proteinG REAL NOT NULL,
        carbohydrateG REAL NOT NULL,
        fatG REAL NOT NULL,
        fiberG REAL DEFAULT 0,
        sugarG REAL DEFAULT 0,
        sodiumMg REAL DEFAULT 0,
        confidence REAL,
        isFavorite INTEGER DEFAULT 0,
        FOREIGN KEY (mealId) REFERENCES meal_entries (id) ON DELETE CASCADE
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS workout_entries (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        dateKey TEXT NOT NULL,
        name TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        energyBurnedKcal REAL NOT NULL
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS workout_sets (
        id TEXT PRIMARY KEY,
        workoutId TEXT NOT NULL,
        exerciseName TEXT NOT NULL,
        weightKg REAL NOT NULL,
        reps INTEGER NOT NULL,
        note TEXT,
        FOREIGN KEY (workoutId) REFERENCES workout_entries (id) ON DELETE CASCADE
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS weight_entries (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        weightKg REAL NOT NULL,
        bodyFatPercentage REAL,
        note TEXT,
        syncedFromHealthConnect INTEGER DEFAULT 0
      );
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS favorite_foods (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT,
        portionQuantity REAL NOT NULL,
        portionUnit TEXT NOT NULL,
        portionGrams REAL NOT NULL,
        energyKcal REAL NOT NULL,
        proteinG REAL NOT NULL,
        carbohydrateG REAL NOT NULL,
        fatG REAL NOT NULL
      );
    ''');

    return db;
  }

  // --- USER PROFILE CRUD ---
  static Future<UserProfile?> loadUserProfile() async {
    final db = await database;
    final ResultSet results = db.select('SELECT * FROM user_profile LIMIT 1');
    if (results.isEmpty) return null;
    final row = results.first;
    return UserProfile(
      id: row['id'] as String,
      heightCm: (row['heightCm'] as num).toDouble(),
      weightKg: (row['weightKg'] as num).toDouble(),
      bodyFatPercentage: row['bodyFatPercentage'] != null ? (row['bodyFatPercentage'] as num).toDouble() : null,
      birthYear: row['birthYear'] as int,
      sex: row['sex'] as String,
      activityLevel: (row['activityLevel'] as num).toDouble(),
      pace: row['pace'] as String,
    );
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    db.execute(
      '''
      INSERT INTO user_profile (id, heightCm, weightKg, bodyFatPercentage, birthYear, sex, activityLevel, pace)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        heightCm=excluded.heightCm,
        weightKg=excluded.weightKg,
        bodyFatPercentage=excluded.bodyFatPercentage,
        birthYear=excluded.birthYear,
        sex=excluded.sex,
        activityLevel=excluded.activityLevel,
        pace=excluded.pace;
    ''',
      [
        profile.id,
        profile.heightCm,
        profile.weightKg,
        profile.bodyFatPercentage,
        profile.birthYear,
        profile.sex,
        profile.activityLevel,
        profile.pace,
      ],
    );
  }

  // --- MEAL & FOOD ITEMS CRUD ---
  static Future<List<MealEntry>> loadMealsForDate(String dateKey) async {
    final db = await database;
    final ResultSet mealRows = db.select('SELECT * FROM meal_entries WHERE dateKey = ? ORDER BY timestamp DESC', [dateKey]);
    List<MealEntry> meals = [];

    for (var mRow in mealRows) {
      final mealId = mRow['id'] as String;
      final ResultSet foodRows = db.select('SELECT * FROM food_items WHERE mealId = ?', [mealId]);

      List<FoodItem> items = foodRows.map((fRow) {
        return FoodItem(
          id: fRow['id'] as String,
          name: fRow['name'] as String,
          brand: fRow['brand'] as String?,
          portionQuantity: (fRow['portionQuantity'] as num).toDouble(),
          portionUnit: fRow['portionUnit'] as String,
          portionGrams: (fRow['portionGrams'] as num).toDouble(),
          energyKcal: (fRow['energyKcal'] as num).toDouble(),
          proteinG: (fRow['proteinG'] as num).toDouble(),
          carbohydrateG: (fRow['carbohydrateG'] as num).toDouble(),
          fatG: (fRow['fatG'] as num).toDouble(),
          fiberG: (fRow['fiberG'] as num).toDouble(),
          sugarG: (fRow['sugarG'] as num).toDouble(),
          sodiumMg: (fRow['sodiumMg'] as num).toDouble(),
          confidence: fRow['confidence'] != null ? (fRow['confidence'] as num).toDouble() : null,
          isFavorite: (fRow['isFavorite'] as int) == 1,
        );
      }).toList();

      meals.add(MealEntry(
        id: mealId,
        timestamp: DateTime.parse(mRow['timestamp'] as String),
        dateKey: mRow['dateKey'] as String,
        mealType: mRow['mealType'] as String,
        title: mRow['title'] as String,
        notes: mRow['notes'] as String?,
        source: mRow['source'] as String,
        items: items,
      ));
    }

    return meals;
  }

  static Future<void> saveMeal(MealEntry meal) async {
    final db = await database;
    db.execute(
      'INSERT OR REPLACE INTO meal_entries (id, timestamp, dateKey, mealType, title, notes, source) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [meal.id, meal.timestamp.toIso8601String(), meal.dateKey, meal.mealType, meal.title, meal.notes, meal.source],
    );

    for (var item in meal.items) {
      db.execute(
        '''
        INSERT OR REPLACE INTO food_items (id, mealId, name, brand, portionQuantity, portionUnit, portionGrams, energyKcal, proteinG, carbohydrateG, fatG, fiberG, sugarG, sodiumMg, confidence, isFavorite)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          item.id,
          meal.id,
          item.name,
          item.brand,
          item.portionQuantity,
          item.portionUnit,
          item.portionGrams,
          item.energyKcal,
          item.proteinG,
          item.carbohydrateG,
          item.fatG,
          item.fiberG,
          item.sugarG,
          item.sodiumMg,
          item.confidence,
          item.isFavorite ? 1 : 0,
        ],
      );
    }
  }

  static Future<void> deleteMeal(String mealId) async {
    final db = await database;
    db.execute('DELETE FROM food_items WHERE mealId = ?', [mealId]);
    db.execute('DELETE FROM meal_entries WHERE id = ?', [mealId]);
  }

  // --- WORKOUT CRUD ---
  static Future<List<WorkoutEntry>> loadAllWorkouts() async {
    final db = await database;
    final ResultSet wRows = db.select('SELECT * FROM workout_entries ORDER BY timestamp DESC');
    List<WorkoutEntry> workouts = [];

    for (var wRow in wRows) {
      final workoutId = wRow['id'] as String;
      final ResultSet setRows = db.select('SELECT * FROM workout_sets WHERE workoutId = ?', [workoutId]);

      List<WorkoutSet> sets = setRows.map((sRow) {
        return WorkoutSet(
          exerciseName: sRow['exerciseName'] as String,
          weightKg: (sRow['weightKg'] as num).toDouble(),
          reps: sRow['reps'] as int,
          note: sRow['note'] as String?,
        );
      }).toList();

      workouts.add(WorkoutEntry(
        id: workoutId,
        timestamp: DateTime.parse(wRow['timestamp'] as String),
        dateKey: wRow['dateKey'] as String,
        name: wRow['name'] as String,
        durationMinutes: wRow['durationMinutes'] as int,
        energyBurnedKcal: (wRow['energyBurnedKcal'] as num).toDouble(),
        sets: sets,
      ));
    }

    return workouts;
  }

  static Future<void> saveWorkout(WorkoutEntry workout) async {
    final db = await database;
    db.execute(
      'INSERT OR REPLACE INTO workout_entries (id, timestamp, dateKey, name, durationMinutes, energyBurnedKcal) VALUES (?, ?, ?, ?, ?, ?)',
      [workout.id, workout.timestamp.toIso8601String(), workout.dateKey, workout.name, workout.durationMinutes, workout.energyBurnedKcal],
    );

    for (var set in workout.sets) {
      db.execute(
        'INSERT OR REPLACE INTO workout_sets (id, workoutId, exerciseName, weightKg, reps, note) VALUES (?, ?, ?, ?, ?, ?)',
        ['${workout.id}_${set.exerciseName}', workout.id, set.exerciseName, set.weightKg, set.reps, set.note],
      );
    }
  }

  static Future<void> deleteWorkout(String workoutId) async {
    final db = await database;
    db.execute('DELETE FROM workout_sets WHERE workoutId = ?', [workoutId]);
    db.execute('DELETE FROM workout_entries WHERE id = ?', [workoutId]);
  }

  // --- WEIGHT CRUD ---
  static Future<List<WeightEntry>> loadWeightEntries() async {
    final db = await database;
    final ResultSet rows = db.select('SELECT * FROM weight_entries ORDER BY date ASC');
    return rows.map((r) {
      return WeightEntry(
        id: r['id'] as String,
        date: DateTime.parse(r['date'] as String),
        weightKg: (r['weightKg'] as num).toDouble(),
        bodyFatPercentage: r['bodyFatPercentage'] != null ? (r['bodyFatPercentage'] as num).toDouble() : null,
        note: r['note'] as String?,
        syncedFromHealthConnect: (r['syncedFromHealthConnect'] as int) == 1,
      );
    }).toList();
  }

  static Future<void> saveWeightEntry(WeightEntry entry) async {
    final db = await database;
    db.execute(
      'INSERT OR REPLACE INTO weight_entries (id, date, weightKg, bodyFatPercentage, note, syncedFromHealthConnect) VALUES (?, ?, ?, ?, ?, ?)',
      [entry.id, entry.date.toIso8601String(), entry.weightKg, entry.bodyFatPercentage, entry.note, entry.syncedFromHealthConnect ? 1 : 0],
    );
  }

  static Future<void> deleteWeightEntry(String id) async {
    final db = await database;
    db.execute('DELETE FROM weight_entries WHERE id = ?', [id]);
  }

  // --- DELETE ALL DATA ---
  static Future<void> deleteAllData() async {
    final db = await database;
    db.execute('DELETE FROM user_profile');
    db.execute('DELETE FROM food_items');
    db.execute('DELETE FROM meal_entries');
    db.execute('DELETE FROM workout_sets');
    db.execute('DELETE FROM workout_entries');
    db.execute('DELETE FROM weight_entries');
    db.execute('DELETE FROM favorite_foods');
  }
}
