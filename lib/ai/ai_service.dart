import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/models.dart';

class AIService {
  static Future<List<FoodItem>> analyzeTextOrPhotos({
    required String textInput,
    required List<String> base64Images,
    required AIProviderConfig config,
  }) async {
    // Attempt 1: Primary provider
    try {
      final items = await _callProvider(
        provider: config.primaryProvider,
        apiKey: config.primaryApiKey,
        model: config.primaryModel,
        textInput: textInput,
        base64Images: base64Images,
        customInstructions: config.customInstructions,
      );
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Primary failed, attempt fallback provider if available
    }

    // Attempt 2: Fallback provider
    if (config.fallbackApiKey.isNotEmpty) {
      try {
        final items = await _callProvider(
          provider: config.fallbackProvider,
          apiKey: config.fallbackApiKey,
          model: 'openrouter/free',
          textInput: textInput,
          base64Images: base64Images,
          customInstructions: config.customInstructions,
        );
        if (items.isNotEmpty) return items;
      } catch (_) {}
    }

    // Local Fallback simulation if no API key or network error
    return _generateLocalFallback(textInput);
  }

  static Future<List<FoodItem>> _callProvider({
    required String provider,
    required String apiKey,
    required String model,
    required String textInput,
    required List<String> base64Images,
    required String customInstructions,
  }) async {
    if (apiKey.isEmpty) throw Exception('Kein API Key hinterlegt');

    final prompt = '''
Du bist ein präziser Ernährungsassistent für den deutschen Markt.
Analysiere die folgende Eingabe (Text / Bilder) und schätze Lebensmittel, Portionsgrößen (in Grammen), Kalorien und Makros.
Zusätzliche Benutzer-Anweisungen: $customInstructions

Eingabetext: $textInput
Anzahl übergebener Bilder: ${base64Images.length}

Antworte AUSSCHLIESSLICH als korrektes JSON-Array von Objekten im folgenden Format:
[
  {
    "name": "Lebensmittel Name",
    "brand": "Marke (falls bekannt oder null)",
    "portionQuantity": 1,
    "portionUnit": "Portion",
    "portionGrams": 150,
    "energyKcal": 250,
    "proteinG": 20.0,
    "carbohydrateG": 30.0,
    "fatG": 5.0,
    "fiberG": 3.0,
    "sugarG": 2.0,
    "sodiumMg": 300,
    "confidence": 0.85
  }
]
''';

    Uri url;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> payload = {};

    if (provider == 'gemini') {
      url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');
      List parts = [{'text': prompt}];
      for (var img in base64Images) {
        parts.add({
          'inline_data': {'mime_type': 'image/jpeg', 'data': img}
        });
      }
      payload = {
        'contents': [{'parts': parts}]
      };
    } else {
      // OpenAI / OpenRouter / Groq / Custom compatible endpoint
      url = Uri.parse(provider == 'openrouter' ? 'https://openrouter.ai/api/v1/chat/completions' : 'https://api.openai.com/v1/chat/completions');
      headers['Authorization'] = 'Bearer $apiKey';
      payload = {
        'model': model.isNotEmpty ? model : 'gpt-4o-mini',
        'messages': [
          {'role': 'user', 'content': prompt}
        ]
      };
    }

    final res = await http.post(url, headers: headers, body: jsonEncode(payload)).timeout(const Duration(seconds: 25));
    if (res.statusCode == 200) {
      final resJson = jsonDecode(res.body);
      String rawText = '';
      if (provider == 'gemini') {
        rawText = resJson['candidates'][0]['content']['parts'][0]['text'];
      } else {
        rawText = resJson['choices'][0]['message']['content'];
      }
      return _parseJsonResponse(rawText);
    }
    throw Exception('API Fehler: ${res.statusCode}');
  }

  static List<FoodItem> _parseJsonResponse(String text) {
    try {
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final List parsed = jsonDecode(cleanText);
      return parsed.map((item) {
        return FoodItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: item['name'] ?? 'Lebensmittel',
          brand: item['brand'],
          portionQuantity: (item['portionQuantity'] ?? 1.0).toDouble(),
          portionUnit: item['portionUnit'] ?? 'Portion',
          portionGrams: (item['portionGrams'] ?? 100.0).toDouble(),
          energyKcal: (item['energyKcal'] ?? 100.0).toDouble(),
          proteinG: (item['proteinG'] ?? 5.0).toDouble(),
          carbohydrateG: (item['carbohydrateG'] ?? 10.0).toDouble(),
          fatG: (item['fatG'] ?? 2.0).toDouble(),
          fiberG: (item['fiberG'] ?? 0.0).toDouble(),
          sugarG: (item['sugarG'] ?? 0.0).toDouble(),
          sodiumMg: (item['sodiumMg'] ?? 0.0).toDouble(),
          confidence: (item['confidence'] ?? 0.80).toDouble(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static List<FoodItem> _generateLocalFallback(String textInput) {
    final query = textInput.toLowerCase().trim();
    if (query.contains('ei') || query.contains('eier')) {
      return [
        FoodItem(
          id: 'fb_1',
          name: 'Hühnereier (Größe M)',
          portionQuantity: 2,
          portionUnit: 'Stück',
          portionGrams: 110,
          energyKcal: 155,
          proteinG: 13.0,
          carbohydrateG: 0.7,
          fatG: 11.2,
          confidence: 0.90,
        )
      ];
    } else if (query.contains('apfel')) {
      return [
        FoodItem(
          id: 'fb_2',
          name: 'Apfel (frisch)',
          portionQuantity: 1,
          portionUnit: 'Stück',
          portionGrams: 180,
          energyKcal: 95,
          proteinG: 0.5,
          carbohydrateG: 25.0,
          fatG: 0.3,
          fiberG: 4.4,
          confidence: 0.95,
        )
      ];
    }

    return [
      FoodItem(
        id: 'fb_gen',
        name: query.isNotEmpty ? textInput : 'Mahlzeit Entwurf',
        portionQuantity: 1,
        portionUnit: 'Portion',
        portionGrams: 200,
        energyKcal: 350,
        proteinG: 20,
        carbohydrateG: 40,
        fatG: 10,
        confidence: 0.70,
      )
    ];
  }
}
