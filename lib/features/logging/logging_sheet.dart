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
  final _noteController = TextEditingController();
  final _barcodeController = TextEditingController();
  bool _isLoading = false;
  String _selectedMealType = 'Frühstück';
  int _photoCount = 0;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(localRepositoryProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mahlzeit erfassen 🍎', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 14),

            // Meal Type Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Frühstück', 'Mittagessen', 'Abendessen', 'Snacks'].map((type) {
                final isSel = _selectedMealType == type;
                return ChoiceChip(
                  label: Text(type, style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                  selected: isSel,
                  selectedColor: AppColors.lightAccentSoft,
                  onSelected: (sel) {
                    if (sel) setState(() => _selectedMealType = type);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // Text Input with Voice mic button
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Freitext eingeben (z.B. "2 Eier, 100g Haferflocken, Apfel")...',
                prefixIcon: const Icon(Icons.search, color: AppColors.lightAccent),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic, color: AppColors.carbs),
                      tooltip: 'Stimmeingabe',
                      onPressed: () {
                        _textController.text = '200g Putenbrust, 150g Reis, Brokkoli';
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sprache erkannt: "200g Putenbrust, 150g Reis, Brokkoli" 🎙️')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.lightAccent),
                      onPressed: _analyzeText,
                    ),
                  ],
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),

            const SizedBox(height: 12),

            // Optional Meal Note
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Optionale Notiz (z.B. "Halbe Portion gegessen", "Ohne Soße")...',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.photo_camera_outlined, color: AppColors.lightAccent),
                          label: Text(_photoCount > 0 ? 'Fotos ($_photoCount/10)' : 'Kamera / Fotos'),
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('Manuell eintragen', style: TextStyle(fontWeight: FontWeight.bold)),
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

            if (repo.favorites.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Favoriten ⭐', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: repo.favorites.length,
                  itemBuilder: (context, idx) {
                    final fav = repo.favorites[idx];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
                        label: Text(fav.name),
                        onPressed: () {
                          _navigateToReview([fav], 'favorite', fav.name);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _analyzeText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final note = _noteController.text.trim();
    final combinedInput = note.isNotEmpty ? '$text (Notiz: $note)' : text;

    setState(() => _isLoading = true);
    final repo = ref.read(localRepositoryProvider);
    final items = await AIService.analyzeTextOrPhotos(
      textInput: combinedInput,
      base64Images: [],
      config: repo.aiConfig,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      _navigateToReview(items, 'ai_text', text);
    }
  }

  void _analyzePhoto() async {
    final note = _noteController.text.trim();
    setState(() {
      _photoCount = (_photoCount + 1).clamp(1, 10);
      _isLoading = true;
    });

    final repo = ref.read(localRepositoryProvider);
    final items = await AIService.analyzeTextOrPhotos(
      textInput: note.isNotEmpty ? 'Foto Mahlzeit (Notiz: $note)' : 'Foto Mahlzeit',
      base64Images: [],
      config: repo.aiConfig,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      _navigateToReview(items, 'ai_photo', 'Foto Analyse');
    }
  }

  void _showBarcodeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Barcode Scannen (Open Food Facts)'),
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
    _navigateToReview([manualItem], 'manual', 'Manuelle Eingabe');
  }

  void _navigateToReview(List<FoodItem> items, String source, String defaultTitle) {
    Navigator.pushReplacement(
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
