# 🍏 NutriLocal – Lokaler, Privater & KI-Gestützter Kalorientracker

[![GitHub release](https://img.shields.io/github/v/release/mixxermannipro/nutrilocal?color=2FA36B&style=for-the-badge)](https://github.com/mixxermannipro/nutrilocal/releases)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Local-orange?style=for-the-badge)](SECURITY.md)

**NutriLocal** ist eine moderne, private und KI-gestützte Kalorien- und Ernährungstracking-App für Android und iOS. Die App kombiniert maximale Privatsphäre (100% lokale Speicherung, kein Nutzerkonto, keine Werbung) mit den besten Funktionen moderner KI-Modelle (**Google Gemini 2.0 / 1.5 Flash**, **OpenAI GPT-4o**, **OpenRouter**, **Groq**, **Ollama**) und einer extrem intuitiven Benutzerführung.

---

## ✨ Hauptmerkmale (Features)

### 📸 1. Smarte Multi-Modale Ernährungserfassung
- **Kamera & Galerie (Multi-Foto 1-10)**: Erfasse bis zu 10 Fotos gleichzeitig für die KI-Nährwertanalyse inklusive optionaler Notizfeld-Instruktionen (*"Halbe Portion gegessen"*, *"Ohne Dressing"*).
- **Barcode-Scan (Open Food Facts DACH)**: Hintergrund-Abfrage der freien europäischen Lebensmitteldatenbank für exakte Nährwertangaben.
- **Stimmeingabe & Freitext**: Diktieren per Sprachbefehl 🎙️ oder Freitext-Eingabe (*"2 Eier, 100g Haferflocken, Apfel"*).
- **Manuelle Eingabe & Favoriten**: 1-Klick-Übernahme von Lieblingsspeisen und Kopieren von Mahlzeiten des Vortags (*"Copy from Yesterday"*).

### 🤖 2. BYOK (Bring Your Own Key) & Modellwahl
- **Google Gemini**: Wähle dein bevorzugtes Modell (`gemini-2.0-flash`, `gemini-1.5-flash`, `gemini-1.5-pro`).
- **OpenAI**: Modelle wie `gpt-4o`, `gpt-4o-mini`, `o3-mini`.
- **OpenRouter & Groq**: Freie und ultraschnelle Modelle (`llama-3.3-70b-instruct`, `mixtral-8x7b`).
- **Ollama**: Volle Offline-Unterstützung mit lokalen Modellen auf deinem eigenen Gerät.
- **Fallback-Protokoll**: Automatische Umschaltung auf den Fallback-Provider bei Netzwerkstörungen.

### 🏋️‍♂️ 3. Minimalistisches Workout-Tagebuch mit Progression
- **Progressive Overload Speicher**: Beim Ausführen und Eingeben einer Übung (*z.B. "Pull-ups"*) zeigt NutriLocal automatisch dein letztes Trainingsergebnis an:  
  👉 **`Letztes Mal: 10 kg Zusatzgewicht × 6 WDH`**
- Verfolgung von Wiederholungen, Zusatzgewichten und Kalorienverbrauch ohne unübersichtliche Menüs.

### 📈 4. Thermodynamische Körperwerte & Health Connect Sync
- **Fud AI Engine Integration**: Berechnet thermodynamische **30 / 60 / 90 Tage Gewichtsprognosen** auf Basis der physikalischen Fettschmelz-Konstante ($7.700\text{ kcal} = 1\text{ kg Körperfett}$).
- **7-Tage EMA Glättung**: Entfernt tägliche Wassertagsschwankungen für ein reales Bild des Fettabbaus.
- **Health Connect Integration**: Automatische Synchronisierung von Gewicht und Körperfettanteil.

---

## 🚀 Installation & Downloads

Lade die aktuellste Android APK direkt aus den GitHub Releases herunter:

👉 **[Aktuellsten Release v1.0.9 herunterladen (APK)](https://github.com/mixxermannipro/nutrilocal/releases/latest)**

---

## 🛠 Architektur & Projektstruktur

```
nutrilocal/
├── android/                   # Native Android Konfiguration & Manifest
├── fud-ai/                    # Fud AI Referenz-Codebase (Referenzarchitektur)
├── lib/                       # Flutter Quellcode
│   ├── ai/                    # KI-Analyse, Vision-Payload & AI Coach Chat Engine
│   ├── app/                   # App-Routing & Hauptmenü
│   ├── core/                  # Design System, Liquid Glass Tokens & AppTheme
│   ├── data/                  # Repository & Open Food Facts DataSources
│   ├── domain/                # Datenmodelle (UserProfile, MealEntry, WorkoutSet)
│   └── features/              # Feature-Module (Dashboard, Logging, Review, Workout, Progress, Settings)
├── pubspec.yaml               # Flutter Abhängigkeiten
└── README.md                  # Dokumentation
```

---

## 🔒 Privatsphäre & Sicherheit

1. **Keine Server, keine Cloud**: Deine Daten verbleiben auf deinem Smartphone.
2. **Kein Tracking, keine Werbung**: Es werden keinerlei Telemetrie- oder Analysedaten erhoben.
3. **Open Source**: Der gesamte Quellcode ist einsehbar und überprüfbar.

---

## 📄 Lizenz

Dieses Projekt steht unter der [MIT Lizenz](LICENSE).
