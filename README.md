# 🍏 NutriLocal – Privater, Lokaler & KI-Gestützter Kalorientracker (v1.0.13)

<p align="center">
  <strong>100% Lokales, Privates & KI-Gestütztes Ernährungstracking für Android</strong><br>
  Local-First • SQLite Persistenz • Secure Storage • Echter Barcode- & Foto-Scan • BYOK KI-Anbindung
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Android-8.0+-green?logo=android" alt="Android">
  <img src="https://img.shields.io/badge/Flutter-3.22-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Database-SQLite%20Persistenz-blue" alt="SQLite">
  <img src="https://img.shields.io/badge/Privacy-100%25%20Local-brightgreen" alt="Privacy">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <a href="https://github.com/mixxermannipro/nutrilocal/releases"><img src="https://img.shields.io/github/v/release/mixxermannipro/nutrilocal?color=2FA36B&style=for-the-badge" alt="Release"></a>
</p>

---

## 📌 Status & Ehrliches Projektprofil

NutriLocal ist eine **Local-First Flutter-App** für Android. Das Projekt wurde nach höchsten Architektur- und Datenschutzstandards entwickelt und bietet **echte lokale SQLite-Persistenz**, **sichere API-Key-Verschlüsselung**, **echte Foto- und Kamera-Scan-Integration** sowie **intelligente BYOK KI-Anbindungen**.

- **Datenschutz by Default**: 100% lokale Datenhaltung auf dem Gerät. Keine eigene Cloud, kein Nutzerkonto, keine Werbung, keine Analytics, keine Telemetrie.
- **Sichere Key-Verwaltung**: API-Keys werden ausschließlich im **Android Keystore / Secure Storage** verschlüsselt gespeichert – niemals im Klartext, niemals in der Datenbank und niemals im Daten-Export.
- **Refactoring & Lizenz-Isolierung**: Sämtlicher Fremd-Referenzcode ist sauber im Unterordner `reference/` isoliert und mit expliziter Lizenz gekennzeichnet ([ATTRIBUTION.md](ATTRIBUTION.md)).

---

## ✨ Tatsächlich Implementierte Features

### 🍏 1. Erfassung & Nährwert-Logging
- **Kamera- & Galerie-Scan (`image_picker`)**: Echte Foto-Auswahl, Bildkomprimierung & lokale Speicherung.
- **Echter Barcode-Scan (`mobile_scanner`)**: Kamera-Scanner mit EAN-8 / EAN-13 Erkennung & automatischer Open Food Facts DACH Datenbank-Abfrage.
- **Freitext & Stimmeingabe**: Diktieren per Sprachfunktion oder Freitext-Eingabe (*"2 Eier, 100g Haferflocken, Apfel"*).
- **Review & What-If Impakt**: Nährwerte entsperren/bearbeiten, Portionsgramm anpassen und Kalorieneinfluss auf das Tagesziel im Voraus prüfen.
- **Favoriten & Kopieren von Gestern**: 1-Klick-Übernahme häufiger Speisen.

### 🤖 2. 13 BYOK KI-Provider & 6 Speech-to-Text Engines
- **13 LLM Provider**: Google Gemini (`gemini-2.0-flash`, `gemini-1.5-flash`), OpenAI (`gpt-4o`, `gpt-4o-mini`), Anthropic Claude, xAI Grok, OpenRouter, Together AI, Groq, Hugging Face, Fireworks AI, DeepInfra, Mistral, Ollama (lokal offline), Custom.
- **6 Speech-to-Text Provider**: Native Android Spracherkennung, Gemini Audio, OpenAI Whisper, Groq Whisper (`whisper-large-v3`), Deepgram (`Nova-3`), AssemblyAI.
- **Consent-Dialog**: Klare Bestätigung vor der ersten KI-Kommunikation.

### 🏋️‍♂️ 3. Workout-Tagebuch mit Überlastungs-Progression
- Erfassung von Übungen, Gewichten, Wiederholungen & Sätzen.
- **Progressiver Speicher**: Zeigt beim Auswählen einer Übung automatisch das letzte Trainingsergebnis an (*"Letztes Mal: 10 kg Zusatzgewicht × 6 WDH"*).

### 📈 4. Körperwerte & Thermodynamische Prognose
- Berechnet 30 / 60 / 90 Tage Gewichtsprognosen nach physikalischer Fettschmelz-Konstante ($7.700\text{ kcal} = 1\text{ kg Fett}$).
- 7-Tage Exponentially Weighted Moving Average (EMA) zur Glättung täglicher Gewichtsschwankungen.

### ⚙️ 5. In-App Auto-Updater & Sicherer Export
- **Automatische Update-Prüfung**: Prüft beim Start im Hintergrund auf neue GitHub Releases und bietet 1-Klick-Installations-Banners.
- **JSON-Export**: Vollständiger Datenexport ohne vertrauliche Keys.
- **Vollständiges Löschen (Delete All)**: Löscht SQLite-Datenbank, Dateien & Secure Storage unwiderruflich.

---

## 🛠 Architektur & Dateistruktur (`lib/`)

```text
lib/
├── main.dart                  # Einstiegspunkt & App-Bootstrapping
├── app/                       # App-Routing & Hauptmenü (NutriLocalApp)
├── core/                      # Design System, Liquid Glass Tokens & AppTheme
├── data/
│   ├── db/                    # Native SQLite Persistenz (SqliteDatabase)
│   ├── datasources/           # SecureStorageService & UpdateService
│   └── repositories/          # LocalRepository State Management
├── domain/                    # Entitäten (UserProfile, MealEntry, WorkoutSet)
│   ├── models/
│   └── services/              # WeightAnalysisService (Thermodynamik & EMA)
├── ai/                        # AIService (Multi-Provider Adapter & JSON Parser)
└── features/                  # UI Feature Module (Dashboard, Logging, Review, Workout, Progress, Settings, Onboarding)
```

---

## 🧪 Tests & Verifikation

Das Projekt enthält automatisierte Unit-Tests für kritische Domänenlogik:

```bash
flutter test
```

- **Nährwertberechnung**: `test/domain/nutrition_calculation_test.dart`
- **Gewichtsprognose & EMA**: `test/domain/weight_analysis_service_test.dart`
- **KI-Modell-ID Bereinigung**: `test/ai/ai_service_test.dart`

---

## 📦 Download & Installation

Lade die aktuellste kompilierte Android APK direkt aus den GitHub Releases herunter:

👉 **[Neuesten Release NutriLocal v1.0.13 herunterladen (APK)](https://github.com/mixxermannipro/nutrilocal/releases/latest)**

---

## 📄 Lizenz & Dritte Parteien

- **NutriLocal**: Lizenziert unter der [MIT Lizenz](LICENSE).
- **Referenz-Codebase**: `reference/fud-ai/` ist unter MIT von Apoorv Darshan lizenziert. Siehe [ATTRIBUTION.md](ATTRIBUTION.md).
- **Open Food Facts**: Nährwertdaten lizenziert unter ODbL.
