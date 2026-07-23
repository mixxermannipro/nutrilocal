import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilocal/domain/models/models.dart';

void main() {
  group('Nutrition Calculation Tests', () {
    test('BMR calculation for male', () {
      final profile = UserProfile(
        id: '1',
        heightCm: 180,
        weightKg: 80,
        birthYear: 1990,
        sex: 'male',
        activityLevel: 1.55,
        pace: 'maintain',
      );

      // Mifflin-St Jeor: 10(80) + 6.25(180) - 5(36) + 5 = 800 + 1125 - 180 + 5 = 1750
      expect(profile.bmr, greaterThan(1700));
      expect(profile.tdee, equals(profile.bmr * 1.55));
    });

    test('Macro targets calculation', () {
      final profile = UserProfile(
        id: '1',
        heightCm: 175,
        weightKg: 70,
        birthYear: 1995,
        sex: 'female',
        activityLevel: 1.375,
        pace: 'maintain',
      );

      // Protein target: 1.8 * 70 = 126g
      expect(profile.targetProteinG, equals(126.0));
      expect(profile.targetFatG, greaterThan(0));
      expect(profile.targetCarbG, greaterThan(0));
    });
  });
}
