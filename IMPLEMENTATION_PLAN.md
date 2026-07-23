# IMPLEMENTATION_PLAN.md - NutriLocal

## 0. Meta

### 0.1 Zweck dieser Datei
Diese Datei ist der vollständige Produkt-, Architektur- und Implementierungsplan für eine lokale, private, moderne Kalorien- und Ernährungstracking-App für Android und iOS.

Sie ist als Eingabedokument für eine AI-IDE (z. B. Google Antigravity IDE) gedacht, um das Projekt vollautonom zu strukturieren, zu erstellen und als finale APK zu builden.

### 0.2 Projektname
Arbeitsname: **NutriLocal** (inspiriert von Fud AI, lokal-first, deutsch-optimiert)

### 0.3 Dokumentversion
Version: 1.1 (Erweitert um Fud AI Benchmark-Features)  
Datum: 23.07.2026  
Status: Implementation Readiness

### 0.4 Zielsystem
- Android (.apk Build & Release ready)
- iOS
- Eine gemeinsame Codebasis (Flutter 3.x / Dart)
- Native Mobile App, kein Web-First-Produkt

### 0.5 Primäre Sprache
- Deutsch zuerst (UI & AI Prompts standardmäßig Deutsch)
- Erweiterbar um Englisch, Französisch, Italienisch, Spanisch

### 0.6 Zielmarkt
- Deutschland, Österreich, Schweiz (DACH), Europäische Union

### 0.7 Produktcharakter
- Lokal-first (SQLite via Drift)
- Privat (Keine Cloud, kein Account, keine Telemetrie)
- Schnell & Elegant (Apple-inspiriertes Fluid Liquid-Glass Design)
- BYOK (Bring Your Own Key für KI: Gemini, OpenAI, Claude, OpenRouter, Groq, Ollama uvm.)
- Ohne Cloud-Zwang, ohne Werbung, ohne Abo

### 0.8 Wichtigste Einschränkung
Die App MUSS ohne KI-API-Key voll nutzbar sein (Manuell, Barcode/Open Food Facts, lokale Lebensmittel-Datenbank). KI ist ein optionaler Beschleuniger.

---

## 1. Produktziel & Fud AI Benchmark Features

NutriLocal bietet extrem schnelles, privates Ernährungstracking kombiniert mit fortschrittlicher KI-Unterstützung und Fitness-Tracking.

### Unterstützte Eingabemethoden:
1. **Manuelle Eingabe** (Mit Makro- & Mikronährstoff-Feldern)
2. **Barcode-Scan** (Kamera / Open Food Facts DACH/EU Integration)
3. **Texteingabe** (Freitext-Analyse via KI)
4. **Multi-Fotoanalyse** (Bis zu 10 Fotos gleichzeitig + optionale Freitext-Notiz, z.B. "halbe Portion gegessen")
5. **Spracheingabe** (Diktat / Speech-to-Text)
6. **Gespeicherte Mahlzeiten, Favoriten & Letzte Mahlzeiten** (Mit Quick-Log)

### Exklusive & erweiterte Fud AI High-Value Features:
- **Review-Screen mit "What-If" Impaktschätzung**: Vor dem Speichern wird angezeigt, wie die Mahlzeit die heutigen Rest-Kalorien/Makros verändert + KI-Optimierungstipp.
- **AI Coach Chat (Lokaler KI-Berater)**: Multi-Turn-Chat mit Zugriff auf lokales Profil, Gewichtsverlauf und Ernährungsdaten. Erstellt thermodynamische Gewichtsprognosen (30 / 60 / 90 Tage) und empfiehlt Makroanpassungen mit Goal-Chips (Abnehmen, Halten, Aufbauen).
- **Fallback AI Provider**: Option zum Konfigurieren eines primären KI-Keys (z. B. Gemini) und eines automatischen Fallbacks (z. B. OpenRouter / Groq / OpenAI) bei Rate Limits oder Serverfehlern.
- **Custom System Prompt Instructions**: Anpassbare Standard-Instruktionen in den Einstellungen (z. B. "Ich lebe in Deutschland, kaufe bei ALDI/REWE, mache Kraftsport").
- **Optionales Wassertracking**: Tagesziel, Quick-Log (Glas/Flasche/Custom ml), Fortschrittsanzeige und visuelle Widgets.
- **Workout & Übungs-Log**: Integriertes Workout-Tagebuch für Krafttraining (Übungen, Sätze, Wdh, Gewicht, RPE, geschätzter Kalorienverbrauch) inkl. integrierter Übungsbibliothek.
- **Adaptive Kalorienziele**: Automatische wöchentliche Feinjustierung des Kalorien-Ziels basierend auf der tatsächlichen Gewichtsentwicklung.

---

## 2. Nicht-Ziele

- Eigene Cloud / Server-Backend
- Registrierung / Login / E-Mail-Pflicht
- Werbung / Tracker / Social Feed
- Gamification-Druck / Streaks
- Abos / In-App-Käufe
- Zwanghafter KI-Upload ohne Bestätigung

---

## 3. Tech-Stack & Architektur

### 3.1 Tech-Stack
- **Framework**: Flutter (Dart 3)
- **State Management**: `flutter_riverpod` (v2+)
- **Immutable Models**: `freezed` & `json_annotation`
- **Lokale Datenbank**: `drift` (SQLite) mit Reactive Streams & DAOs
- **Navigation**: `go_router`
- **Key Storage**: `flutter_secure_storage` (Android EncryptedSharedPreferences / iOS Keychain)
- **Barcode Scanner**: `mobile_scanner`
- **Charts**: `fl_chart`
- **Media**: `image_picker`, `flutter_image_compress`
- **Sync/Health**: Abstraktion für Health Connect (Android) & HealthKit (iOS)

### 3.2 Projektstruktur (Feature-First)
```
lib/
  main.dart
  app/
    app.dart
    router/
    providers/
  core/
    config/
    constants/
    theme/ (Liquid Glass Design System, Dark/Light Mode, Custom Accents)
    utils/
    storage/
  domain/
    entities/
    repositories/
    services/ (NutritionCalculator, WeightForecaster, GoalEngine)
  data/
    db/ (Drift tables & DAOs)
    repositories/
    datasources/ (Local, OFF API, AI Providers)
  ai/
    abstractions/ (AIProvider, AIRequest, AIResponse)
    providers/ (GeminiProvider, OpenRouterProvider, OpenAIProvider, GroqProvider, OllamaProvider)
    prompts/ (German optimized prompts with custom instruction injection)
    parsers/ (Structured JSON output parser with fallback)
  features/
    onboarding/
    dashboard/
    logging/ (Manual, Barcode, Text, Multi-Photo, Voice)
    review/ (Nutrition Lock, What-If Impact, AI Optimization Tips)
    diary/
    coach/ (AI Coach Multi-Turn Chat)
    water/ (Water Tracking)
    workout/ (Workout Diary & Exercise Library)
    progress/ (Weight, Macro & Forecast Charts)
    goals/ (Adaptive Goals & Macro Config)
    settings/ (BYOK Keys, Fallback Provider, Custom Prompt, Export/Import, Reset)
```

---

## 4. Datenmodell (Drift Tables)

1. **UserProfile**: Height, weight, birthYear, sex, activityLevel, pace, dietaryPref.
2. **Goal**: Target Kcal, proteinG, carbG, fatG, fiberG, waterMl, effectiveFrom, adaptiveEnabled.
3. **MealEntry**: Timestamp, dateKey, mealType (Breakfast, Lunch, Dinner, Snack), title, notes, source (Manual, Barcode, AI_Text, AI_Photo).
4. **FoodItem**: MealEntryId, name, brand, portionQuantity, portionUnit, portionGrams, energyKcal, proteinG, carbG, fatG, fiberG, sugarG, sodiumMg, confidence.
5. **WaterEntry**: Timestamp, dateKey, amountMl.
6. **WorkoutEntry**: Timestamp, dateKey, name, durationMinutes, energyBurnedKcal, notes.
7. **WorkoutSet**: WorkoutEntryId, exerciseName, setOrder, weightKg, reps, rpe.
8. **WeightEntry**: Date, weightKg, bodyFatPercentage, note.
9. **AIProviderConfig**: PrimaryProvider, PrimaryApiKey, PrimaryModel, FallbackProvider, FallbackApiKey, CustomInstructions.

---

## 5. UI/UX Specification (Liquid Glass Design System)

- **Aesthetic**: Premium Apple-inspired Liquid Glass UI.
- **Farben**: Dark Mode (#0B0D10 Canvas, #1A1D22 Surface Glass, #4CC38A Accent Green) & Light Mode (#F6F7F9 Canvas, #FFFFFF Surface Glass, #2FA36B Accent).
- **Makro-Visualisierung**: Protein (Blau #3B82F6), Kohlenhydrate (Bernstein #F59E0B), Fett (Violett #8B5CF6), Wasser (Türkis #06B6D4).
- **Dashboard Ring & Bars**: Interaktiver Kalorien-Kreisdiagramm-Ring mit Restkalorien-Anzeige & Makro-Balken.
- **Review Screen**: Übersichtliche Karten für erkannte Lebensmittel, Editierbarkeit aller Werte, "What-If" Balken-Vorschau auf die verbleibenden Tages-Makros.

---

## 6. Implementation Plan & Execution Tasks

### Task 1: Repository & Base Structure Setup
- Flutter Projekt initialisieren mit `pubspec.yaml` (Riverpod, Drift, GoRouter, Freezed, FlChart, MobileScanner, SecureStorage).
- Grundstruktur `lib/` anlegen.

### Task 2: Core Domain & Data Layer (SQLite Drift DB)
- Drift Schema definieren (`UserProfile`, `Goal`, `MealEntry`, `FoodItem`, `WaterEntry`, `WorkoutEntry`, `WeightEntry`).
- DAOs & Repositories für CRUD-Zugriff bauen.

### Task 3: Design System & Liquid Glass Components
- ThemeData für Dark & Light Mode mit BackdropBlur, GlassCard, Custom Macro Colors und Custom Accent Picker.
- Reusable UI Components: `GlassCard`, `CalorieRing`, `MacroBar`, `PrimaryButton`, `UndoSnackbar`.

### Task 4: Dashboard & Navigation
- GoRouter Bottom Navigation Shell (Heute, Tagebuch, Coach, Workout, Fortschritt, Einstellungen).
- Dashboard Screen mit Kalorienring, Makrobalken, Wasser-Quick-Log, Heutige Mahlzeiten und Gewichtseingabe.

### Task 5: Manual Logging & Open Food Facts Barcode Integration
- Manuelles Eingabe-Formular mit Gramm-Skalierung.
- Barcode Scanner via `mobile_scanner` + Open Food Facts API Integration mit lokalem Cache.

### Task 6: Multi-Photo & Text AI Pipeline (BYOK)
- SecureStorage Provider für API Keys (Gemini, OpenRouter, OpenAI, Groq, Ollama).
- Multi-Photo Selector (bis zu 10 Fotos + Notiz).
- Robustes JSON AI Parsing mit Retry & Fallback-Provider-Kette.

### Task 7: Review Screen ("What-If" & Lock Mode)
- Review UI nach KI/Barcode-Analyse.
- "What-If" Impakt-Vorschau (Zeigt Tagesrestwerte VOR & NACH dem Speichern).
- Editierbarkeit aller Nährwerte & Mengen.

### Task 8: AI Coach & Thermodynamischer Gewichtsprognose-Engine
- AI Coach Tab mit persistentem lokalen Chatverlauf.
- System Prompt Context-Builder (injiziert BMR/TDEE, Gewichtsverlauf der letzten 30 Tage, Ernährungs-Logs).
- Berechnet 30/60/90 Tage Prognosen und schlägt Goal Chips vor (Abnehmen, Halten, Aufbauen).

### Task 9: Workout Diary & Übungsbibliothek
- Krafttraining-Logger (Übung wählen, Sätze, Gewicht, Reps, RPE erfassen).
- Übungsbibliothek (Brust, Rücken, Beine, Schultern, Arme, Core).
- Kalorienverbrauch-Schätzung für Workouts.

### Task 10: Progress Charts & Adaptive Goals
- FlChart Integration für Gewichtstrend, 7-Tage-Gewichtsdurchschnitt, Kalorien- und Makroverlauf.
- Adaptive Ziele Engine (Wöchentlicher Kalorien-Check basierend auf Gewichts-Änderung).

### Task 11: Settings, Data Export/Import & Reset
- API-Key Management (Primary & Fallback Provider).
- Custom AI Instructions Textfeld.
- Datenexport als JSON / CSV & "Alle Daten löschen" Button.

### Task 12: Android APK Build & GitHub Action Release Setup
- Android Release Build Konfiguration (`build.gradle.kts`, Permissions).
- Build der Android Release APK (`flutter build apk --release`).
- Git Repository Push & GitHub Release Assets Upload.

---

## 7. Verification & Definition of Done
- App lässt sich fehlerfrei auf Android und iOS kompilieren.
- offline-first Funktionalität ist zu 100% gewährleistet (Ohne KI & Ohne Netz voll nutzbar).
- APK wird erfolgreich generiert und im Release bereitgestellt.
