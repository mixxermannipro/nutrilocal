import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/open_food_facts_service.dart';
import '../../ai/ai_service.dart';
import '../../data/repositories/local_repository.dart';
import '../../domain/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../review/review_screen.dart';

class LoggingSheet extends ConsumerStatefulWidget {
  const LoggingSheet({super.key});

  @override
  ConsumerState<LoggingSheet> createState() => _LoggingSheetState();
}

class _LoggingSheetState extends ConsumerState<LoggingSheet> {
  final _textController = TextEditingController();
  final _barcodeController = TextEditingController();
  bool _isLoading = false;
  String _selectedMealType = 'Frühstück';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mahlzeit erfassen 🍎', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 12),

          // Meal Type Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Frühstück', 'Mittagessen', 'Abendessen', 'Snacks'].map((type) {
              final isSel = _selectedMealType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSel,
                selectedColor: AppColors.lightAccentSoft,
                onSelected: (sel) {
                  if (sel) setState(() => _selectedMealType = type);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Text / Voice Input Field
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Freitext eingeben (z.B. "2 Eier, 100g Haferflocken, Apfel")...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: AppColors.lightAccent),
                onPressed: _analyzeText,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),

          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.camera_alt, color: AppColors.lightAccent),
                        label: const Text('Foto (Multi)'),
                        onPressed: _analyzePhoto,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.qr_code_scanner, color: AppColors.carbs),
                        label: const Text('Barcode'),
                        onPressed: _showBarcodeDialog,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Manuell eintragen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _openManualEntry,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _analyzeText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);
    final repo = ref.read(localRepositoryProvider);
    final items = await AIService.analyzeTextOrPhotos(
      textInput: text,
      base64Images: [],
      config: repo.aiConfig,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      _navigateToReview(items, 'ai_text', text);
    }
  }

  void _analyzePhoto() async {
    setState(() => _isLoading = true);
    final repo = ref.read(localRepositoryProvider);
    final items = await AIService.analyzeTextOrPhotos(
      textInput: 'Foto Mahlzeit',
      base64Images: [],
      config: repo.aiConfig,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      _navigateToReview(items, 'ai_photo', 'Foto Analyse');
    }
  }

  void _showBarcodeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Barcode eingeben / scannen'),
        content: TextField(
          controller: _barcodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'EAN Code (z.B. 4000521001000)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              final code = _barcodeController.text.trim();
              Navigator.pop(ctx);
              if (code.isNotEmpty) {
                setState(() => _isLoading = true);
                final item = await OpenFoodFactsService.fetchByBarcode(code);
                setState(() => _isLoading = false);

                if (mounted) {
                  Navigator.pop(context);
                  _navigateToReview(
                    item != null ? [item] : [],
                    'barcode',
                    'Barcode Product',
                  );
                }
              }
            },
            child: const Text('Suchen'),
          ),
        ],
      ),
    );
  }

  void _openManualEntry() {
    final manualItem = FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Eigene Mahlzeit',
      portionQuantity: 1,
      portionUnit: 'Portion',
      portionGrams: 200,
      energyKcal: 400,
      proteinG: 25,
      carbohydrateG: 45,
      fatG: 12,
    );
    Navigator.pop(context);
    _navigateToReview([manualItem], 'manual', 'Manuelle Eingabe');
  }

  void _navigateToReview(List<FoodItem> items, String source, String defaultTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ReviewScreen(
          initialItems: items,
          source: source,
          mealType: _selectedMealType,
          defaultTitle: defaultTitle,
        ),
      ),
    );
  }
}
