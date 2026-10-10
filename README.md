# FITA Mahjong — mobile foundation

Flutter starter for Android and iOS with a cozy nature-and-garden visual direction.

## Implemented in this commit
- Responsive Flutter app shell and nature-inspired home screen.
- Guest entry path; no account required to enter the prototype.
- Google and Apple sign-in buttons as clearly labelled UI placeholders.
- Playable local pair-matching prototype.
- Settings sheet with sound and haptics toggles (session-only state).
- Flutter package configuration; no external runtime packages required.

## Not implemented yet
- Real Google/Apple authentication, OAuth credentials, or secure session handling.
- Persistent guest saves/settings.
- Online leaderboards, matchmaking, and live multiplayer.
- 10,000 authored and solver-validated levels.
- Full layered Mahjong rules, special tiles, production audio/particles, accessibility QA.
- Native Android/iOS project folders, signing configuration, or release builds.

## Run locally
Install the Flutter SDK. In the repository root run:

```sh
flutter create . --platforms=android,ios
flutter pub get
flutter run
```

Flutter will generate the native `android/` and `ios/` project folders. Review any overwrite prompts carefully and keep `lib/main.dart` and `pubspec.yaml`. Alternatively, create a fresh project with `flutter create fita_mahjong --platforms=android,ios` and copy this repository's `lib/` and `pubspec.yaml` into it.

Before publishing, configure the Android application ID, iOS bundle identifier, signing keys/profiles, OAuth client IDs, privacy disclosures, and store assets. An APK or IPA has **not** been built by this repository commit.
