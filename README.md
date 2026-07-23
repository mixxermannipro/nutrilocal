# 🍏 NutriLocal – Lokaler, Privater & KI-Gestützter Kalorientracker

<p align="center">
  <strong>Lokales, Privates & KI-Gestütztes Ernährungstracking für Android und iOS</strong><br>
  Fotografieren, Sprechen oder Tippen — Die KI erledigt den Rest.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Android-8.0+-green?logo=android" alt="Android">
  <img src="https://img.shields.io/badge/iOS-17.6+-blue?logo=apple" alt="iOS">
  <img src="https://img.shields.io/badge/Flutter-3.22-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Privacy-100%25%20Local-brightgreen" alt="Privacy">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <a href="https://github.com/mixxermannipro/nutrilocal/releases"><img src="https://img.shields.io/github/v/release/mixxermannipro/nutrilocal?color=2FA36B&style=for-the-badge" alt="Release"></a>
</p>

---

Open-Source, lokaler und datenschutzfreundlicher Kalorientracker für Android und iOS basierend auf der **Fud AI Benchmark-Architektur**. Nutze deinen eigenen KI-Anbieter — 13 unterstützte Provider inklusive **Google Gemini**, **OpenAI**, **Anthropic Claude**, **xAI Grok**, **Groq**, **Hugging Face**, **Fireworks AI**, **DeepInfra**, **Mistral**, **Ollama (lokal)** und **Custom OpenAI-kompatible Endpunkte**. Erfasse bis zu 10 Speisenfotos gleichzeitig, scanne Barcodes via Open Food Facts DACH, sprich deine Mahlzeiten ein oder erstelle Workouts mit automatischer Progressive Overload Erinnerung. Kein Nutzerkonto, kein Cloud-Zwang, keine Werbung — 100% kostenlos und lokal.

---

## 🔄 Funktionsweise & Datenfluss (How It Works)

```
Foto(s) / Text / Stimme
        │
        ▼
  BYOK Provider API (Gemini / OpenAI / Claude / Grok / Groq / etc.)
        │
        ├── BYOK Fallback-Provider (falls konfiguriert)
        └── Native On-Device Fallback
        │
        ▼
  JSON Nährwert-Antwort
        │
        ▼
  Nutzer überprüft & editiert (Review & Lock)
        │
        ▼
  LocalRepository  ──▶  Lokaler Speicher + Health Connect / Apple Health (optional)
```

---

## 🤖 13 KI-Provider (LLM BYOK Providers)

Nutze einen beliebigen der **13 LLM Provider** für Foto-Analysen, "What-If" Nährwertschätzungen und AI Coach Chats. Kostenlose Gemini Keys gibt es unter [aistudio.google.com/apikey](https://aistudio.google.com/apikey). Anfragen gehen direkt von deinem Gerät an den von dir gewählten Provider.

| Provider | Format | Highlight | API Key erforderlich |
|----------|--------|-----------|:---:|
| **Google Gemini** | Gemini API | Gemini 3.5 Flash-Lite (default) / 3.6 Flash / 3.5 Flash | Ja |
| **OpenAI** | OpenAI | GPT-5.4 Mini (default) / 5.5 / 5.4 Nano | Ja |
| **Anthropic Claude** | Messages API | Sonnet 5 (default) / Opus 4.8 / Haiku 4.5 | Ja |
| **xAI Grok** | OpenAI-kompatibel | Grok 4.3 | Ja |
| **OpenRouter** | OpenAI-kompatibel | Beliebiges Modell, Freitext-IDs | Ja |
| **Together AI** | OpenAI-kompatibel | Qwen 3.5, Gemma 4, MiniMax M3 | Ja |
| **Groq** | OpenAI-kompatibel | Qwen 3.6, extrem schnell | Ja |
| **Hugging Face** | OpenAI-kompatibel | Gemma 4 / 3 und Qwen 3.5 / 2.5 VL | Ja |
| **Fireworks AI** | OpenAI-kompatibel | Qwen 3.7 Plus, MiniMax M3, Kimi K2.6 | Ja |
| **DeepInfra** | OpenAI-kompatibel | Gemma 4 / 3 Vision Modelle | Ja |
| **Mistral** | OpenAI-kompatibel | Mistral Small / Medium, Ministral 14B | Ja |
| **Ollama** | OpenAI-kompatibel (lokal) | Qwen 3 VL, Gemma 4, Llama 3.2 Vision, LLaVA, Moondream | Nein |
| **Custom** | OpenAI-kompatibel | Freie Einstellbarkeit von Base URL + Modellname | Optional |

---

## 🎙️ Speech-to-Text Provider (6 STT Optionen)

Wähle, wie deine Spracheingaben transkribiert werden. **Native iOS / Android (On-Device)** ist der Standard — kostenlos, lokal und in Echtzeit.

| Provider | Hinweise |
|----------|----------|
| **Native iOS / Android (On-Device)** | Kostenlos, offline bei unterstützter Sprache, Echtzeit-Ergebnisse |
| **Gemini Audio** | Batch Audio Transkription über Gemini |
| **OpenAI Whisper** | Whisper-1 via `/v1/audio/transcriptions` |
| **Groq (Whisper)** | `whisper-large-v3`, extrem schnell mit kostenloser Stufe |
| **Deepgram** | `Nova-3`, schnell und hochpräzise |
| **AssemblyAI** | Universal-Modell mit hoher Genauigkeit |

---

## ✨ Features im Überblick

### 🍎 1. Erfassung & Logging
- **Multi-Foto Kamera**: Erfasse bis zu 10 Fotos gleichzeitig mit Notizfeld (*"Halbe Portion gegessen"*).
- **Barcode Lookup**: Scannen von Produkten mit Open Food Facts DACH Datenbank im Hintergrund.
- **Stimmeingabe**: Sprechen von Mahlzeiten über 6 verschiedene STT-Provider.
- **Texteingabe & Manuell**: Freitext oder manuelle Kalorien- & Makroeingabe.
- **Review & Lock**: Nährwerte sperren/entsperren und Portionsgrößen dynamisch skalieren.
- **"What-If?" Impakt-Vorschau**: Zeigt die Auswirkungen auf deine verbleibenden Tages-Restkalorien VOR dem Speichern.
- **Favoriten & Gestern kopieren**: 1-Klick Übernahme aus Recents/Favoriten oder Kopieren des Vortags.

### 🤖 2. KI Coach & Thermodynamische Prognose
- **Thermodynamische Gewichtsprognose**: Erwartetes Gewicht in **30 / 60 / 90 Tagen**, berechnet mit der physikalischen Fettschmelz-Konstante ($7.700\text{ kcal} = 1\text{ kg Fett}$).
- **Under-Logging Erkennung**: System warnt bei unvollständiger Mahlzeitenerfassung.
- **AI Coach Chat**: Multi-Turn Chat mit lokalem Gedächtnis und deutschen Prompt-Chips (*Abnehmen / Halten / Muskelaufbau*).

### 🏋️‍♂️ 3. Minimalistisches Workout Tagebuch (Progressive Overload)
- **Progressiver Speicher**: Beim Erfassen einer Übung (*z.B. "Pull-ups"*) wird automatisch das letzte Trainingsergebnis angezeigt:  
  👉 **`Letztes Mal: 10 kg Zusatzgewicht × 6 WDH`**
- **Health Connect Integration**: Synchronisiert berechnete Kalorienverbrennung und Trainingsdaten.

---

## 📦 Installation & Download

Die neuste kompilierte APK kann direkt auf GitHub heruntergeladen werden:

👉 **[Neuesten Release NutriLocal v1.0.10 herunterladen (APK)](https://github.com/mixxermannipro/nutrilocal/releases/latest)**

---

## 🔒 Privatsphäre

Keine Accounts, kein Cloud-Zwang, keine Werbung. API Keys werden lokal verschlüsselt gespeichert und Anfragen gehen direkt von deinem Smartphone an den gewählten Provider. **Alle Daten löschen** setzt die gesamte lokale Installation unwiderruflich zurück.

---

## 📄 Lizenz

MIT License. Siehe [LICENSE](LICENSE).
