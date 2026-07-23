import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/models.dart';

class OpenFoodFactsService {
  static Future<FoodItem?> fetchByBarcode(String barcode) async {
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
      final response = await http.get(url, headers: {'User-Agent': 'NutriLocalApp/1.0 (German DACH)'}).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          final nutriments = product['nutriments'] ?? {};

          final name = product['product_name_de'] ?? product['product_name'] ?? 'Unbekanntes Produkt';
          final brand = product['brands'];
          final kcal = (nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'] ?? 0.0).toDouble();
          final protein = (nutriments['proteins_100g'] ?? 0.0).toDouble();
          final carbs = (nutriments['carbohydrates_100g'] ?? 0.0).toDouble();
          final fat = (nutriments['fat_100g'] ?? 0.0).toDouble();
          final fiber = (nutriments['fiber_100g'] ?? 0.0).toDouble();
          final sugar = (nutriments['sugars_100g'] ?? 0.0).toDouble();
          final sodium = (nutriments['sodium_100g'] ?? 0.0).toDouble() * 1000;

          return FoodItem(
            id: 'off_$barcode',
            name: name,
            brand: brand,
            portionQuantity: 100,
            portionUnit: 'g',
            portionGrams: 100,
            energyKcal: kcal,
            proteinG: protein,
            carbohydrateG: carbs,
            fatG: fat,
            fiberG: fiber,
            sugarG: sugar,
            sodiumMg: sodium,
            confidence: 0.95,
          );
        }
      }
    } catch (_) {
      // Fallback or network offline
    }
    return null;
  }
}
