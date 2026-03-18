# STRYDER

A bold, minimalistic running app built with Flutter for iOS.

## Features

- **Live Run Tracking** — Real-time GPS tracking with a dark map and animated neon-purple route line
- **Weekly Mileage Goal** — Circular neon progress ring with editable weekly target
- **Streak System** — Geometric flame icon that grows with consecutive run days
- **Smart Suggestions** — Pace-based longer run suggestions and rest day reminders
- **Run Summary** — Post-run route map, key stats, and milestone cards
- **Trends & Insights** — Weekly mileage bar chart, pace trend line, streak history, and run log
- **Local Storage** — All data stored on-device via Hive (no cloud, no accounts)

## Tech Stack

- **Framework:** Flutter (Dart)
- **Architecture:** MVVM + Riverpod
- **State Management:** flutter_riverpod
- **Local Storage:** Hive
- **Maps:** flutter_map (CartoDB dark tiles)
- **GPS:** geolocator
- **Charts:** fl_chart
- **Navigation:** go_router
- **Fonts:** Inter, JetBrains Mono (via google_fonts)

## Project Structure

```
stridr_app/lib/
  main.dart              # Entry point, Hive init, ProviderScope
  app.dart               # GoRouter navigation, MaterialApp
  core/
    theme/               # AppColors, AppTheme (dark + neon purple)
    constants/           # App-wide constants
    utils/               # Formatters (pace, distance, duration)
  models/                # RunRecord, WeeklyGoal, StreakData, Suggestion
  services/              # RunTracking, Goal, Streak, Suggestion, Storage
  providers/             # Riverpod providers and StateNotifiers
  views/
    home/                # Dashboard screen
    run/                 # Live run tracking screen
    summary/             # Post-run summary screen
    insights/            # Trends and charts screen
    goal/                # Weekly goal edit screen
    widgets/             # NeonProgressRing, StreakFlame, SuggestionCard, StatTile
```

## Getting Started

### Prerequisites

- Flutter SDK 3.32+
- Dart 3.8+

### Setup

```bash
cd stridr_app
flutter pub get
flutter run
```

### iOS Build (from Windows)

Since native iOS builds require macOS, use a cloud build service:

- Codemagic
- GitHub Actions (macOS runner)
- MacStadium / MacInCloud

## Design

- Dark backgrounds (`#0A0A0A`, `#141414`)
- Neon purple accents (`#A020F0`, `#C45CFF`)
- Monospaced stat digits, smooth animations, haptic feedback

## License

Private — not published.
