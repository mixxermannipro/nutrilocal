class UserProfile {
  final String id;
  final double heightCm;
  final double weightKg;
  final int birthYear;
  final String sex; // 'male', 'female', 'other'
  final double activityLevel; // 1.2, 1.375, 1.55, 1.725, 1.9
  final String pace; // 'maintain', 'lose_slow', 'lose_fast', 'gain_slow', 'gain_fast'

  UserProfile({
    required this.id,
    required this.heightCm,
    required this.weightKg,
    required this.birthYear,
    required this.sex,
    required this.activityLevel,
    required this.pace,
  });

  int get age => DateTime.now().year - birthYear;

  double get bmr {
    if (sex == 'male') {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else if (sex == 'female') {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    } else {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 78;
    }
  }

  double get tdee => bmr * activityLevel;

  double get targetKcal {
    switch (pace) {
      case 'lose_fast':
        return tdee * 0.80;
      case 'lose_slow':
        return tdee * 0.85;
      case 'gain_slow':
        return tdee * 1.10;
      case 'gain_fast':
        return tdee * 1.15;
      case 'maintain':
      default:
        return tdee;
    }
  }

  double get targetProteinG => weightKg * 1.8;
  double get targetFatG => (targetKcal * 0.25) / 9.0;
  double get targetCarbG => (targetKcal - (targetProteinG * 4.0) - (targetFatG * 9.0)) / 4.0;
}

class MealEntry {
  final String id;
  final DateTime timestamp;
  final String dateKey; // YYYY-MM-DD
  final String mealType; // Frühstück, Mittagessen, Abendessen, Snacks
  final String title;
  final String? notes;
  final String source; // manual, barcode, ai_text, ai_photo
  final List<FoodItem> items;

  MealEntry({
    required this.id,
    required this.timestamp,
    required this.dateKey,
    required this.mealType,
    required this.title,
    this.notes,
    required this.source,
    required this.items,
  });

  double get totalKcal => items.fold(0, (sum, item) => sum + item.energyKcal);
  double get totalProtein => items.fold(0, (sum, item) => sum + item.proteinG);
  double get totalCarbs => items.fold(0, (sum, item) => sum + item.carbohydrateG);
  double get totalFat => items.fold(0, (sum, item) => sum + item.fatG);
  double get totalFiber => items.fold(0, (sum, item) => sum + item.fiberG);
  double get totalSugar => items.fold(0, (sum, item) => sum + item.sugarG);
  double get totalSodium => items.fold(0, (sum, item) => sum + item.sodiumMg);
}

class FoodItem {
  final String id;
  final String name;
  final String? brand;
  final double portionQuantity;
  final String portionUnit; // g, ml, Stück, Scheibe, Portion
  final double portionGrams;
  final double energyKcal;
  final double proteinG;
  final double carbohydrateG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;
  final double? confidence;

  FoodItem({
    required this.id,
    required this.name,
    this.brand,
    required this.portionQuantity,
    required this.portionUnit,
    required this.portionGrams,
    required this.energyKcal,
    required this.proteinG,
    required this.carbohydrateG,
    required this.fatG,
    this.fiberG = 0,
    this.sugarG = 0,
    this.sodiumMg = 0,
    this.confidence,
  });

  FoodItem copyWithPortion(double newQuantity, double newGrams) {
    final scale = newGrams / (portionGrams > 0 ? portionGrams : 1.0);
    return FoodItem(
      id: id,
      name: name,
      brand: brand,
      portionQuantity: newQuantity,
      portionUnit: portionUnit,
      portionGrams: newGrams,
      energyKcal: energyKcal * scale,
      proteinG: proteinG * scale,
      carbohydrateG: carbohydrateG * scale,
      fatG: fatG * scale,
      fiberG: fiberG * scale,
      sugarG: sugarG * scale,
      sodiumMg: sodiumMg * scale,
      confidence: confidence,
    );
  }
}

class WaterEntry {
  final String id;
  final DateTime timestamp;
  final String dateKey;
  final int amountMl;

  WaterEntry({
    required this.id,
    required this.timestamp,
    required this.dateKey,
    required this.amountMl,
  });
}

class WorkoutEntry {
  final String id;
  final DateTime timestamp;
  final String dateKey;
  final String name;
  final int durationMinutes;
  final double energyBurnedKcal;
  final String? notes;
  final List<WorkoutSet> sets;

  WorkoutEntry({
    required this.id,
    required this.timestamp,
    required this.dateKey,
    required this.name,
    required this.durationMinutes,
    required this.energyBurnedKcal,
    this.notes,
    required this.sets,
  });
}

class WorkoutSet {
  final String exerciseName;
  final int setOrder;
  final double weightKg;
  final int reps;
  final double? rpe;

  WorkoutSet({
    required this.exerciseName,
    required this.setOrder,
    required this.weightKg,
    required this.reps,
    this.rpe,
  });
}

class WeightEntry {
  final String id;
  final DateTime date;
  final double weightKg;
  final double? bodyFatPercentage;
  final String? note;

  WeightEntry({
    required this.id,
    required this.date,
    required this.weightKg,
    this.bodyFatPercentage,
    this.note,
  });
}

class AIProviderConfig {
  final String primaryProvider; // gemini, openrouter, openai, groq, ollama
  final String primaryApiKey;
  final String primaryModel;
  final String fallbackProvider;
  final String fallbackApiKey;
  final String customInstructions;

  AIProviderConfig({
    this.primaryProvider = 'gemini',
    this.primaryApiKey = '',
    this.primaryModel = 'gemini-1.5-flash',
    this.fallbackProvider = 'openrouter',
    this.fallbackApiKey = '',
    this.customInstructions = 'Ich lebe in Deutschland. Bevorzuge deutsche Produktnamen und metrische Einheiten.',
  });
}
