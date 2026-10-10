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

## Configure Firebase before real sign-in/cloud sync

Follow the detailed checklist in [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md). The repo includes [`firebase.local.example.json`](firebase.local.example.json); copy it to `firebase.local.json`, fill in the values from Firebase / Google Cloud, and run `flutter run --dart-define-from-file=firebase.local.json`. The local file is ignored by Git. The app deliberately stays in local-only guest mode when the required Firebase runtime values are absent.

## Required setup before real sign-in/cloud sync can work

The integration code is committed, but this repository does **not** contain credentials or a Firebase project configuration. Provider sign-in and cloud sync are therefore not verified as operational yet.

1. Create a Firebase project and register the Android app using the final Android application ID.
2. Register the iOS app using the final bundle identifier.
3. Enable **Authentication → Sign-in method → Anonymous, Google, and Apple** as appropriate.
4. Follow [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md) for Google OAuth IDs, Android SHA-1/SHA-256 fingerprints, and the required reversed-client-ID URL scheme in `ios/Runner/Info.plist`. This repository initializes Firebase with Dart runtime options, so native Firebase config files are not required for initialization; the iOS Google callback URL scheme is still required.
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
