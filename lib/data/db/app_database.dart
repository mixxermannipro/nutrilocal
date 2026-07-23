import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class UserProfileTable extends Table {
  TextColumn get id => text()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  RealColumn get bodyFatPercentage => real().nullable()();
  IntColumn get birthYear => integer()();
  TextColumn get sex => text()();
  RealColumn get activityLevel => real()();
  TextColumn get pace => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class MealEntryTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get dateKey => text()(); // YYYY-MM-DD
  TextColumn get mealType => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get source => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class FoodItemTable extends Table {
  TextColumn get id => text()();
  TextColumn get mealId => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  RealColumn get portionQuantity => real()();
  TextColumn get portionUnit => text()();
  RealColumn get portionGrams => real()();
  RealColumn get energyKcal => real()();
  RealColumn get proteinG => real()();
  RealColumn get carbohydrateG => real()();
  RealColumn get fatG => real()();
  RealColumn get fiberG => real().withDefault(const Constant(0.0))();
  RealColumn get sugarG => real().withDefault(const Constant(0.0))();
  RealColumn get sodiumMg => real().withDefault(const Constant(0.0))();
  RealColumn get confidence => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FoodPhotoTable extends Table {
  TextColumn get id => text()();
  TextColumn get mealId => text()();
  TextColumn get localFilePath => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WeightEntryTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real()();
  RealColumn get bodyFatPercentage => real().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get syncedFromHealthConnect => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutEntryTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get dateKey => text()();
  TextColumn get name => text()();
  IntColumn get durationMinutes => integer()();
  RealColumn get energyBurnedKcal => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSetTable extends Table {
  TextColumn get id => text()();
  TextColumn get workoutId => text()();
  TextColumn get exerciseName => text()();
  RealColumn get weightKg => real()();
  IntColumn get reps => integer()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FavoriteFoodTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  RealColumn get portionQuantity => real()();
  TextColumn get portionUnit => text()();
  RealColumn get portionGrams => real()();
  RealColumn get energyKcal => real()();
  RealColumn get proteinG => real()();
  RealColumn get carbohydrateG => real()();
  RealColumn get fatG => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class SettingTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  UserProfileTable,
  MealEntryTable,
  FoodItemTable,
  FoodPhotoTable,
  WeightEntryTable,
  WorkoutEntryTable,
  WorkoutSetTable,
  FavoriteFoodTable,
  SettingTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nutrilocal.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
