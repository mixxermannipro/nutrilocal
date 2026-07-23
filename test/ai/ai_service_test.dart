import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilocal/ai/ai_service.dart';

void main() {
  group('AI Service Model Cleaning Tests', () {
    test('Cleans Gemini model display strings to API IDs', () {
      expect(AIService.cleanModelId('Gemini 3.5 Flash-Lite (default)', 'gemini'), equals('gemini-1.5-flash'));
      expect(AIService.cleanModelId('Gemini 2.0 Flash', 'gemini'), equals('gemini-2.0-flash'));
      expect(AIService.cleanModelId('Gemini 1.5 Pro', 'gemini'), equals('gemini-1.5-pro'));
    });

    test('Cleans OpenAI model display strings to API IDs', () {
      expect(AIService.cleanModelId('GPT-5.4 Mini (default)', 'openai'), equals('gpt-4o-mini'));
      expect(AIService.cleanModelId('GPT-4o', 'openai'), equals('gpt-4o'));
    });
  });
}
