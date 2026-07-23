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
  int _currentStep = 0;
  double _heightCm = 178;
  double _weightKg = 75;
  int _birthYear = 1995;
  String _sex = 'male';
  double _activityLevel = 1.55;
  String _pace = 'maintain';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: AppColors.lightAccent, size: 28),
                  const SizedBox(width: 8),
                  const Text('NutriLocal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('Schritt ${_currentStep + 1} von 3', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _buildStepContent(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Zurück'),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(_currentStep == 2 ? 'Starten' : 'Weiter'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Willkommen bei NutriLocal 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('100% lokal, privat, ohne Cloud & ohne Werbung. Passe deine Körperdaten an:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Text('Größe: ${_heightCm.round()} cm'),
            Slider(
              value: _heightCm,
              min: 140,
              max: 220,
              divisions: 80,
              onChanged: (v) => setState(() => _heightCm = v),
            ),
            const SizedBox(height: 16),
            Text('Gewicht: ${_weightKg.toStringAsFixed(1)} kg'),
            Slider(
              value: _weightKg,
              min: 40,
              max: 160,
              divisions: 240,
              onChanged: (v) => setState(() => _weightKg = v),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aktivität & Ziel 🎯', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<double>(
              value: _activityLevel,
              decoration: const InputDecoration(labelText: 'Aktivitätslevel'),
              items: const [
                DropdownMenuItem(value: 1.2, child: Text('Sitzend (Wenig Sport)')),
                DropdownMenuItem(value: 1.375, child: Text('Leicht aktiv (1-3 Tage Sport)')),
                DropdownMenuItem(value: 1.55, child: Text('Moderat aktiv (3-5 Tage Sport)')),
                DropdownMenuItem(value: 1.725, child: Text('Sehr aktiv (6-7 Tage Sport)')),
              ],
              onChanged: (v) => setState(() => _activityLevel = v!),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _pace,
              decoration: const InputDecoration(labelText: 'Ernährungsziel'),
              items: const [
                DropdownMenuItem(value: 'lose_fast', child: Text('Aggressiv Abnehmen (-20%)')),
                DropdownMenuItem(value: 'lose_slow', child: Text('Moderat Abnehmen (-15%)')),
                DropdownMenuItem(value: 'maintain', child: Text('Gewicht Halten')),
                DropdownMenuItem(value: 'gain_slow', child: Text('Moderat Zunehmen (+10%)')),
              ],
              onChanged: (v) => setState(() => _pace = v!),
            ),
          ],
        );
      case 2:
      default:
        final tempProfile = UserProfile(
          id: 'u1',
          heightCm: _heightCm,
          weightKg: _weightKg,
          birthYear: _birthYear,
          sex: _sex,
          activityLevel: _activityLevel,
          pace: _pace,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deine berechneten Ziele 📊', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Täglicher Kalorienbedarf:'),
                        Text('${tempProfile.targetKcal.round()} kcal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.lightAccent)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Protein Target:'),
                        Text('${tempProfile.targetProteinG.round()} g', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.protein)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kohlenhydrate Target:'),
                        Text('${tempProfile.targetCarbG.round()} g', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.carbs)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fett Target:'),
                        Text('${tempProfile.targetFatG.round()} g', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.fat)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  void _finishOnboarding() {
    final repo = ref.read(localRepositoryProvider);
    repo.saveUserProfile(UserProfile(
      id: 'user_main',
      heightCm: _heightCm,
      weightKg: _weightKg,
      birthYear: _birthYear,
      sex: _sex,
      activityLevel: _activityLevel,
      pace: _pace,
    ));
    widget.onComplete();
  }
}
