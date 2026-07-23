import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilocal/domain/models/models.dart';
import 'package:nutrilocal/domain/services/weight_analysis_service.dart';

void main() {
  group('Weight Analysis Service Tests', () {
    test('Thermodynamic forecast calculation', () {
      final profile = UserProfile(
        id: '1',
        heightCm: 180,
        weightKg: 80,
        birthYear: 1990,
        sex: 'male',
        activityLevel: 1.55,
        pace: 'lose_fast', // 20% deficit
      );

      final forecast = WeightAnalysisService.calculateForecast(
        profile: profile,
        weightHistory: [],
        recentMeals: [],
      );

      expect(forecast.currentWeightKg, equals(80.0));
      expect(forecast.dailyDeficitKcal, greaterThan(0));
      expect(forecast.projected30DaysKg, lessThan(80.0));
      expect(forecast.projected90DaysKg, lessThan(forecast.projected30DaysKg));
    });

    test('EMA weight smoothing calculation', () {
      final entries = [
        WeightEntry(id: '1', date: DateTime.now().subtract(const Duration(days: 2)), weightKg: 80.0),
        WeightEntry(id: '2', date: DateTime.now().subtract(const Duration(days: 1)), weightKg: 79.5),
        WeightEntry(id: '3', date: DateTime.now(), weightKg: 79.0),
      ];

      final ema = WeightAnalysisService.calculateEMAWeight(entries);
      expect(ema, lessThan(80.0));
      expect(ema, greaterThan(78.5));
    });
  });
}
