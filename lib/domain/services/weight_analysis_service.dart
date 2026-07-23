import 'dart:math';
import '../models/models.dart';

class ThermodynamicForecast {
  final double currentWeightKg;
  final double projected30DaysKg;
  final double projected60DaysKg;
  final double projected90DaysKg;
  final double dailyDeficitKcal;
  final double weeklyWeightChangeKg;
  final bool isUnderLoggingDetected;

  ThermodynamicForecast({
    required this.currentWeightKg,
    required this.projected30DaysKg,
    required this.projected60DaysKg,
    required this.projected90DaysKg,
    required this.dailyDeficitKcal,
    required this.weeklyWeightChangeKg,
    required this.isUnderLoggingDetected,
  });
}

class WeightAnalysisService {
  /// Calculates thermodynamic weight forecast adapted from Fud AI WeightAnalysisService.kt
  static ThermodynamicForecast calculateForecast({
    required UserProfile profile,
    required List<WeightEntry> weightHistory,
    required List<MealEntry> recentMeals,
  }) {
    final currentW = weightHistory.isNotEmpty ? weightHistory.last.weightKg : profile.weightKg;
    final dailyDeficit = profile.tdee - profile.targetKcal;
    
    // 7700 kcal per 1 kg body fat loss/gain (Thermodynamic constant)
    final dailyFatLossKg = dailyDeficit / 7700.0;
    
    final p30 = max(40.0, currentW - (dailyFatLossKg * 30));
    final p60 = max(40.0, currentW - (dailyFatLossKg * 60));
    final p90 = max(40.0, currentW - (dailyFatLossKg * 90));
    final weeklyChange = dailyFatLossKg * 7;

    // Detect under-logging if observed weight loss is significantly lower than calculated deficit
    bool underLogging = false;
    if (weightHistory.length >= 7) {
      final firstW = weightHistory.first.weightKg;
      final actualChange = firstW - currentW;
      final expectedChange = (dailyFatLossKg * weightHistory.length);
      if (expectedChange > 1.5 && actualChange < 0.2) {
        underLogging = true;
      }
    }

    return ThermodynamicForecast(
      currentWeightKg: currentW,
      projected30DaysKg: p30,
      projected60DaysKg: p60,
      projected90DaysKg: p90,
      dailyDeficitKcal: dailyDeficit,
      weeklyWeightChangeKg: weeklyChange,
      isUnderLoggingDetected: underLogging,
    );
  }

  /// Calculates Exponentially Weighted Moving Average (EMA) for smooth weight trends
  static double calculateEMAWeight(List<WeightEntry> entries, {double alpha = 0.2}) {
    if (entries.isEmpty) return 70.0;
    double ema = entries.first.weightKg;
    for (int i = 1; i < entries.length; i++) {
      ema = alpha * entries[i].weightKg + (1 - alpha) * ema;
    }
    return ema;
  }
}
