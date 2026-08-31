# Campus Navigation System

## Getting Started
# GITAM Maps — Campus Navigation System

A cross-platform Flutter app for navigating the GITAM campus using an interactive Google Map: view your location, browse points of interest, and (soon) search for destinations across campus.

## Features

- Interactive Google Map centered and bounded to the campus area
- Custom markers for key campus locations (e.g. landmarks, buildings)
- Search bar UI for finding destinations
- Custom map styling via `assets/maps_style.json`
- Runs on Android, iOS, Web, Windows, macOS, and Linux from a single codebase

## Tech Stack

- [Flutter](https://flutter.dev/) / Dart
- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) for the map
- [flutter_svg](https://pub.dev/packages/flutter_svg) for vector icons
- Custom Poppins font family

## Project Structure

```
lib/
├── main.dart          # App entry point
└── pages/
    └── home.dart       # Map screen: app bar, search field, markers

assets/
├── maps_style.json     # Custom Google Maps styling
└── icons/               # SVG icons (search, settings, etc.)

android/ ios/ web/ windows/ macos/ linux/   # Platform-specific project files
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.12.2` — see `pubspec.yaml`)
- A Google Maps API key ([get one here](https://developers.google.com/maps/documentation/android-sdk/get-api-key))

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Samuel-Suraganaa/Navigation.git
   cd Navigation
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add your Google Maps API key**
   - **Android**: add your key to `android/app/src/main/AndroidManifest.xml`
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY" />
     ```
   - **iOS**: add your key to `ios/Runner/AppDelegate.swift`
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY")
     ```
   - **Web**: add your key to `web/index.html`
     ```html
     <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Roadmap

- [ ] Wire up the search bar to filter/find destinations
- [ ] Add turn-by-turn or route directions between campus points
- [ ] Expand marker set to cover all major buildings and landmarks
- [ ] Add a settings/menu screen (icons are already in place)

## Contributing

Issues and pull requests are welcome. If you plan a larger change, please open an issue first to discuss what you'd like to change.