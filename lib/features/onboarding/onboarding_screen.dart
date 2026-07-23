import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_repository.dart';
import '../../domain/models/models.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _heightCtrl = TextEditingController(text: '178');
  final _weightCtrl = TextEditingController(text: '75');
  final _yearCtrl = TextEditingController(text: '1995');
  String _sex = 'male';
  double _activityLevel = 1.55;
  String _pace = 'maintain';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriLocal Einrichtung 🍏'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Willkommen bei NutriLocal!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              '100% lokal, privat und ohne Registrierung. Richte jetzt deine Kalorien- & Nährwertziele ein.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Geschlecht
            const Text('Geschlecht', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Männlich')),
                    selected: _sex == 'male',
                    onSelected: (s) => setState(() => _sex = 'male'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Weiblich')),
                    selected: _sex == 'female',
                    onSelected: (s) => setState(() => _sex = 'female'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Körperwerte
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Größe (cm)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Gewicht (kg)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _yearCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Geburtsjahr (z.B. 1995)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // Aktivitätslevel
            const Text('Aktivitätslevel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<double>(
              value: _activityLevel,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 1.2, child: Text('Sitzend (Wenig / kein Sport)')),
                DropdownMenuItem(value: 1.375, child: Text('Leicht aktiv (1-3x Sport/Woche)')),
                DropdownMenuItem(value: 1.55, child: Text('Moderat aktiv (3-5x Sport/Woche)')),
                DropdownMenuItem(value: 1.725, child: Text('Sehr aktiv (6-7x Sport/Woche)')),
                DropdownMenuItem(value: 1.9, child: Text('Extrem aktiv (Harte Arbeit / Leistungssport)')),
              ],
              onChanged: (v) => setState(() => _activityLevel = v!),
            ),
            const SizedBox(height: 20),

            // Ziel
            const Text('Ernährungsziel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _pace,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'lose_fast', child: Text('Schnell Abnehmen (-20% Kcal)')),
                DropdownMenuItem(value: 'lose_slow', child: Text('Moderat Abnehmen (-15% Kcal)')),
                DropdownMenuItem(value: 'maintain', child: Text('Gewicht Halten')),
                DropdownMenuItem(value: 'gain_slow', child: Text('Langsam Aufbauen (+10% Kcal)')),
                DropdownMenuItem(value: 'gain_fast', child: Text('Schnell Aufbauen (+15% Kcal)')),
              ],
              onChanged: (v) => setState(() => _pace = v!),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _completeOnboarding,
                child: const Text('Profil Speichern & Starten', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeOnboarding() {
    final height = double.tryParse(_heightCtrl.text) ?? 178;
    final weight = double.tryParse(_weightCtrl.text) ?? 75;
    final year = int.tryParse(_yearCtrl.text) ?? 1995;

    final profile = UserProfile(
      id: 'user_local',
      heightCm: height,
      weightKg: weight,
      birthYear: year,
      sex: _sex,
      activityLevel: _activityLevel,
      pace: _pace,
    );

    final repo = ref.read(localRepositoryProvider);
    repo.saveUserProfile(profile);
    widget.onComplete();
  }
}
