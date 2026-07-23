import '../domain/models/models.dart';

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
  static String generateCoachReply({
    required String userQuery,
    required UserProfile profile,
    required List<MealEntry> recentMeals,
    required List<WeightEntry> weights,
  }) {
    final queryLower = userQuery.toLowerCase();

    // Thermodynamischer Gewichtsprognose-Check
    if (queryLower.contains('prognose') || queryLower.contains('gewicht') || queryLower.contains('30 tage')) {
      final currentW = weights.isNotEmpty ? weights.last.weightKg : profile.weightKg;
      final dailyDeficitKcal = profile.tdee - profile.targetKcal;
      final weightChange30Days = (dailyDeficitKcal * 30) / 7700; // 7700 kcal per kg body fat
      final projected30 = currentW - weightChange30Days;
      final projected60 = currentW - (weightChange30Days * 2);

      return '''
Hier ist deine thermodynamische Gewichtsprognose basierend auf deinen Daten:

📊 **Aktuelles Gewicht**: ${currentW.toStringAsFixed(1)} kg
🔥 **TDEE (Gesamtumsatz)**: ${profile.tdee.round()} kcal/Tag
🎯 **Zielkalorien**: ${profile.targetKcal.round()} kcal/Tag
📉 **Tägliches Defizit/Überschuss**: ${dailyDeficitKcal.abs().round()} kcal

🔮 **Erwartetes Gewicht**:
• In 30 Tagen: **${projected30.toStringAsFixed(1)} kg** (${weightChange30Days > 0 ? '-' : '+'}${weightChange30Days.abs().toStringAsFixed(1)} kg)
• In 60 Tagen: **${projected60.toStringAsFixed(1)} kg**

💡 *Tipp*: Achte darauf, dein Proteinziel von **${profile.targetProteinG.round()} g/Tag** einzuhalten, um Muskelmasse zu schützen.
''';
    }

    if (queryLower.contains('protein') || queryLower.contains('eiweiß')) {
      return '''
Dein Ziel für Protein liegt bei **${profile.targetProteinG.round()} g/Tag** (ca. 1,8 g/kg Körpergewicht).

Gute Proteinquellen in deiner täglichen Ernährung:
• Hähnchen- / Putenbrust
• Magerquark & Hüttenkäse
• Eier & Eiklar
• Tofu, Linsen & Kichererbsen
• Whey / Veganes Protein-Pulver
''';
    }

    if (queryLower.contains('tipp') || queryLower.contains('abnehmen') || queryLower.contains('aufbau')) {
      return '''
Hier sind 3 effektive Tipps für dein Ziel:

1. **Konsequentes Logging**: Erfasse Soßen, Öle und Snacks – dort verstecken sich oft unbemerkt 200–400 kcal.
2. **Volumen-Food**: Nutze viel Gemüse und Ballaststoffe, um die Magenfüllung bei niedrigem Kaloriendichte zu erhöhen.
3. **Ausreichend Wasser**: Trinke mindestens 2,5 Liter Wasser täglich für optimale Regeneration und Sättigung.
''';
    }

    return '''
Hallo! Ich bin dein lokaler NutriLocal AI Coach. 

Basierend auf deinen Daten liegt dein täglicher Bedarf bei **${profile.tdee.round()} kcal** (Ziel: **${profile.targetKcal.round()} kcal**).

Du kannst mich alles fragen zu:
• Thermodynamischen Gewichtsprognosen (30 / 60 / 90 Tage)
• Protein- und Makro-Empfehlungen
• Optimierung deiner täglichen Mahlzeiten
''';
  }
}
