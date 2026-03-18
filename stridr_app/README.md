# STRIDR — Flutter App

The Flutter source for STRIDR, a minimalistic running app with a neon-purple dark theme.

## Quick Start

```bash
flutter pub get
flutter run
```

## Architecture

MVVM + Riverpod with clean separation of concerns:

```
lib/
  main.dart          # Hive init, ProviderScope, app bootstrap
  app.dart           # MaterialApp.router with GoRouter
  core/
    theme/           # AppColors (#0A0A0A bg, #A020F0 accent), AppTheme
    constants/       # GPS, goal, streak, animation constants
    utils/           # Pace, distance, duration formatters
  models/            # RunRecord, WeeklyGoal, StreakData, Suggestion + Hive adapters
  services/          # Business logic (GPS tracking, goal, streak, suggestions, storage)
  providers/         # Riverpod StateNotifiers bridging services to views
  views/
    home/            # Dashboard: goal ring, streak flame, suggestions, start run
    run/             # Live tracking: dark map, neon route, stats, controls
    summary/         # Post-run: route map, stats, milestone card
    insights/        # Charts: weekly mileage bars, pace trend line, streak stats
    goal/            # Edit weekly mileage target via slider
    widgets/         # NeonProgressRing, StreakFlame, SuggestionCard, StatTile
```

## Dependencies

| Purpose | Package |
|---|---|
| State management | flutter_riverpod |
| Local storage | hive, hive_flutter |
| Maps | flutter_map, latlong2 |
| GPS | geolocator, permission_handler |
| Charts | fl_chart |
| Navigation | go_router |
| Fonts | google_fonts |
| IDs | uuid |

## Screens

- **Home** — Weekly goal ring, streak flame, smart suggestions, start run button
- **Run** — Full-screen dark map with neon-purple route, live distance/time/pace, pause/resume/end
- **Summary** — Static route map, key stats, milestone achievement cards
- **Insights** — Weekly mileage bar chart, pace trend line, current/longest streak, run history
- **Goal** — Slider to set weekly mileage target (1–100 mi) with live ring preview

## Building for iOS

Requires macOS. Use a cloud CI service from Windows:

- Codemagic
- GitHub Actions with `macos-latest` runner
- MacStadium / MacInCloud
