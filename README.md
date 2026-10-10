# FITA Mahjong — mobile foundation

Flutter starter for Android and iOS with a cozy nature-and-garden visual direction.

## Implemented in source

- Firebase Authentication integration for Google and Apple sign-in.
- Guest play: Firebase anonymous account when configured; otherwise a persistent device-local guest ID.
- Anonymous-to-provider account linking is attempted so cloud guest progress can follow the account.
- Local-first progress/settings persistence with SharedPreferences.
- Firestore sync for level and preferences when Firebase is configured and reachable.
- Firestore rules limiting each signed-in user to their own `users/{uid}` document.
- Cozy nature home screen and local pair-matching prototype.

## Required setup before real sign-in/cloud sync can work

The integration code is committed, but this repository does **not** contain credentials or a Firebase project configuration. Provider sign-in and cloud sync are therefore not verified as operational yet.

1. Create a Firebase project and register the Android app using the final Android application ID.
2. Register the iOS app using the final bundle identifier.
3. Enable **Authentication → Sign-in method → Anonymous, Google, and Apple** as appropriate.
4. Add the Firebase Android config file `android/app/google-services.json` and iOS config file `ios/Runner/GoogleService-Info.plist`.
5. Follow the current Firebase Flutter setup instructions for the Google Services Gradle plugin, iOS URL schemes, and platform-specific OAuth settings. For Google, configure the required SHA fingerprints and OAuth client IDs. For Apple, enable Sign in with Apple for the Apple Developer App ID and configure the Firebase Apple provider.
6. Create the Firestore database and deploy `firestore.rules`. Do not use open/public Firestore rules.
7. Review Apple sign-in entitlement and capability settings in the iOS project before testing on a real device.

Guest mode is designed to remain usable without Firebase, but cloud syncing requires Firebase to initialize successfully. Local guest progress is device-local and does not automatically migrate to a different device. If an existing provider account already exists, Firebase does not automatically merge its cloud data with an anonymous account; a deliberate migration flow is still needed.

## Current sync behavior and limitations

- Progress and preferences are written locally first.
- When Firebase is ready and a Firebase user exists, the app attempts to sync the current level and preferences to `users/{uid}`.
- Network/Firestore errors should not block local play. A later save/load can retry, but there is not yet a background retry queue or real-time conflict-resolution protocol.
- This is a small prototype. It does not yet provide email/password login, account deletion UI, profile management, privacy/consent screens, or automated auth tests.

## Run locally

Install Flutter, then from the repository root:

```sh
flutter create . --platforms=android,ios
flutter pub get
flutter run
```

Review any overwrite prompts carefully and keep `lib/main.dart`, `lib/services/`, `pubspec.yaml`, and `firestore.rules`. Alternatively, create a fresh project with `flutter create fita_mahjong --platforms=android,ios` and copy this repository's app files into it.

## Build and verification status

No successful Flutter compile, APK, or IPA build has been verified for this change yet. The current execution environment used for editing did not have Flutter/Dart available. Do not treat the presence of integration code as proof that OAuth credentials, platform configuration, Firestore rules, or builds are working.
