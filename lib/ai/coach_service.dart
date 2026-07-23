import '../domain/models/models.dart';
import '../domain/services/weight_analysis_service.dart';

class CoachChatMessage {
  final String sender; // 'user' or 'coach'
  final String text;
  final DateTime timestamp;

  CoachChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}

class CoachService {
  /// Enhanced AI Coach reply engine using Fud AI Thermodynamic & Body Context logic
  static String generateCoachReply({
    required String userQuery,
    required UserProfile profile,
    required List<MealEntry> recentMeals,
    required List<WeightEntry> weights,
  }) {
    final queryLower = userQuery.toLowerCase();
    final forecast = WeightAnalysisService.calculateForecast(
      profile: profile,
      weightHistory: weights,
      recentMeals: recentMeals,
    );

    // Thermodynamische Gewichtsprognose Query
    if (queryLower.contains('prognose') || queryLower.contains('gewicht') || queryLower.contains('30 tage')) {
      final underLogWarn = forecast.isUnderLoggingDetected
          ? '\n⚠️ *Hinweis*: Deine beobachtete Gewichtsänderung deutet darauf hin, dass möglicherweise Mahlzeiten (z. B. Öle oder Saucen) nicht erfasst wurden.'
          : '';

      return '''
Hier ist deine thermodynamische Gewichtsprognose (Fud AI Engine):

📊 **Aktuelles Gewicht**: ${forecast.currentWeightKg.toStringAsFixed(1)} kg
🔥 **TDEE (Gesamtumsatz)**: ${profile.tdee.round()} kcal/Tag
🎯 **Zielkalorien**: ${profile.targetKcal.round()} kcal/Tag
📉 **Tägliches Defizit**: ${forecast.dailyDeficitKcal.abs().round()} kcal/Tag

🔮 **Erwartetes Gewicht**:
• In 30 Tagen: **${forecast.projected30DaysKg.toStringAsFixed(1)} kg** (${forecast.weeklyWeightChangeKg > 0 ? '-' : '+'}${(forecast.weeklyWeightChangeKg.abs() * 4.3).toStringAsFixed(1)} kg)
• In 60 Tagen: **${forecast.projected60DaysKg.toStringAsFixed(1)} kg**
• In 90 Tagen: **${forecast.projected90DaysKg.toStringAsFixed(1)} kg**$underLogWarn

💡 *Tipp*: Dein Proteinziel liegt bei **${profile.targetProteinG.round()} g/Tag**, um Muskelmasse während der Diät zu schützen.
''';
    }

    if (queryLower.contains('protein') || queryLower.contains('eiweiß')) {
      return '''
Dein tägliches Proteinziel beträgt **${profile.targetProteinG.round()} g/Tag** (1,8 g/kg Körpergewicht).

Beste Proteinquellen für deinen Tag:
• Hähnchenbrust / Putenbrust (ca. 30g P / 100g)
• Magerquark (ca. 60g P pro 500g Packung)
• Eier & Eiklar
• Tofu, Kichererbsen & Linsen
• Whey oder veg. Proteinpulver
''';
    }

    if (queryLower.contains('tipp') || queryLower.contains('abnehmen') || queryLower.contains('aufbau')) {
      return '''
3 essenzielle Regeln für deinen Erfolg:

1. **Exakte Mengenerfassung**: Nutze Küchenwaagen für Öle, Nüsse und Saucen.
2. **Volumennahrung**: Bevorzuge Gemüse und proteinreiche Lebensmittel mit niedriger Kaloriendichte.
3. **Konsequentes Krafttraining**: Erhalte deine Muskelmasse durch progressive Überlastung beim Training.
''';
    }

    return '''
Hallo! Ich bin dein lokaler NutriLocal AI Coach. 

Basierend auf deinem Profil liegt dein Gesamtumsatz bei **${profile.tdee.round()} kcal** (Ziel: **${profile.targetKcal.round()} kcal**).

Frage mich z.B.:
• "Wie sieht meine 30-Tage Gewichtsprognose aus?"
• "Erreiche ich mein Proteinziel?"
• "Tipps für effektiven Fettabbau"
''';
  }
}
