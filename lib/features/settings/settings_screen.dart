import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/local_repository.dart';
import '../../domain/models/models.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _primaryKeyCtrl;
  late TextEditingController _fallbackKeyCtrl;
  late TextEditingController _customPromptCtrl;
  late String _primaryProvider;
  late String _fallbackProvider;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(localRepositoryProvider);
    final config = repo.aiConfig;
    _primaryProvider = config.primaryProvider;
    _fallbackProvider = config.fallbackProvider;
    _primaryKeyCtrl = TextEditingController(text: config.primaryApiKey);
    _fallbackKeyCtrl = TextEditingController(text: config.fallbackApiKey);
    _customPromptCtrl = TextEditingController(text: config.customInstructions);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(localRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen ⚙️'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('KI / BYOK Einstellungen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Verwende deine eigenen kostenlosen API Keys. Die App bleibt auch ohne Keys vollständig lokal nutzbar.',
                style: TextStyle(color: Colors.grey, fontSize: 13)),

            const SizedBox(height: 16),

            // Primary Provider
            DropdownButtonFormField<String>(
              value: _primaryProvider,
              decoration: const InputDecoration(labelText: 'Primärer KI Provider'),
              items: const [
                DropdownMenuItem(value: 'gemini', child: Text('Google Gemini (Kostenlos)')),
                DropdownMenuItem(value: 'openrouter', child: Text('OpenRouter (Free / Paid)')),
                DropdownMenuItem(value: 'openai', child: Text('OpenAI (GPT-4o)')),
                DropdownMenuItem(value: 'groq', child: Text('Groq (Fast)')),
                DropdownMenuItem(value: 'ollama', child: Text('Ollama (Lokales Modell)')),
              ],
              onChanged: (v) => setState(() => _primaryProvider = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _primaryKeyCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Primärer API Key',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Fallback Provider
            DropdownButtonFormField<String>(
              value: _fallbackProvider,
              decoration: const InputDecoration(labelText: 'Fallback KI Provider (Optional)'),
              items: const [
                DropdownMenuItem(value: 'openrouter', child: Text('OpenRouter (Fallback)')),
                DropdownMenuItem(value: 'openai', child: Text('OpenAI (Fallback)')),
                DropdownMenuItem(value: 'gemini', child: Text('Gemini (Fallback)')),
              ],
              onChanged: (v) => setState(() => _fallbackProvider = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fallbackKeyCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Fallback API Key',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Custom Instructions
            TextField(
              controller: _customPromptCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Eigene KI-Instruktionen (System Prompt)',
                hintText: 'z.B. "Ich lebe in Deutschland, kaufe bei ALDI/REWE, mache Kraftsport"',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _saveSettings,
              child: const Text('Einstellungen Speichern'),
            ),

            const Divider(height: 40),

            const Text('Health Connect & Synchronisation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Health Connect Integration'),
              subtitle: const Text('Ernährungsdaten & Workouts optional spiegeln'),
              value: repo.healthSyncEnabled,
              onChanged: (v) {
                repo.setHealthSyncEnabled(v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(v ? 'Health Connect aktiviert! 💚' : 'Health Connect deaktiviert.')),
                );
              },
            ),

            const Divider(height: 40),

            const Text('Daten & Privatsphäre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.download, color: AppColors.lightAccent),
              title: const Text('Alle Daten als JSON exportieren'),
              subtitle: const Text('Erstellt eine lokale Backupdatei.'),
              onTap: () {
                final exportData = jsonEncode({
                  'userProfile': {
                    'heightCm': repo.userProfile.heightCm,
                    'weightKg': repo.userProfile.weightKg,
                    'tdee': repo.userProfile.tdee,
                  },
                  'exportedAt': DateTime.now().toIso8601String(),
                });
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('JSON Export Bereit'),
                    content: SingleChildScrollView(child: Text(exportData)),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Schließen'))],
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Alle lokalen Daten löschen', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: const Text('Löscht alle Mahlzeiten, Workouts und Gewichtseinträge unwiderruflich.'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Wirklich alle Daten löschen?'),
                    content: const Text('Diese Aktion löscht alle deine lokalen Ernährungseinträge, Workouts und Gewichtsdaten vollständig.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () {
                          repo.deleteAllData();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Alle lokalen Daten wurden zurückgesetzt! 🗑️')),
                          );
                        },
                        child: const Text('Löschen'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    final repo = ref.read(localRepositoryProvider);
    repo.saveAIConfig(AIProviderConfig(
      primaryProvider: _primaryProvider,
      primaryApiKey: _primaryKeyCtrl.text.trim(),
      primaryModel: _primaryProvider == 'gemini' ? 'gemini-1.5-flash' : 'gpt-4o-mini',
      fallbackProvider: _fallbackProvider,
      fallbackApiKey: _fallbackKeyCtrl.text.trim(),
      customInstructions: _customPromptCtrl.text.trim(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Einstellungen wurden sicher gespeichert! 🔒')),
    );
  }
}
