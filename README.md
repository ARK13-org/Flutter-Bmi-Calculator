# BMI Tracker – Flutter Frontend

A BMI calculator and tracker built with Flutter. This version uses simulated in-memory services; it does not connect to a real backend.

## Features
- BMI calculation with input validation
- BMI category result
- Comparison with the previous measurement
- BMI history and a simple trend chart
- Profile viewing and editing
- Navigation drawer
- Simulated loading delays for mock service calls

## Project structure

```text
lib/
├── main.dart
├── models/
│   ├── user_model.dart
│   └── bmi_record.dart
├── services/
│   ├── mock_user_service.dart
│   └── mock_bmi_service.dart
├── screens/
│   ├── homepage.dart
│   ├── profile_screen.dart
│   ├── history_screen.dart
│   ├── settings_screen.dart
│   └── about_screen.dart
├── widgets/
│   ├── app_drawer.dart
│   ├── bmi_result_card.dart
│   ├── bmi_comparison_card.dart
│   └── bmi_chart.dart
└── theme/
    └── app_theme.dart
```

## Run
Copy the `lib/` folder into an existing Flutter project, keeping your existing `pubspec.yaml`, then run:

```bash
flutter pub get
flutter run
```

No additional package dependencies are required beyond Flutter.

## Mock data behavior
`MockUserService` and `MockBmiService` simulate future API calls with short delays. BMI records and profile changes are held in memory and reset when the app process restarts. The services are intentionally separated from the UI so they can later be replaced with HTTP/API implementations.

## Notes
BMI is a screening measure, not a diagnosis. Interpret results in context; BMI alone does not determine an individual's health.
