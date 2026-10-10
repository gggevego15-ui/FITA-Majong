# FITA Mahjong — mobile foundation

Flutter starter for Android and iOS with a cozy nature-and-garden visual direction.

## Current features

- No Google/Apple login UI or interactive sign-in.
- Silent Firebase anonymous authentication after tapping Play, to give each installation a UID for protected Firestore saves.
- Local-first progress/settings persistence with SharedPreferences.
- Firestore sync for level and preferences when Firebase is configured and reachable.
- Firestore rules restricting each UID to its own `users/{uid}` document.
- Cozy nature home screen and local pair-matching prototype.

## Daily challenge and online multiplayer

- The daily challenge uses a UTC date-based seed, so the board is the same for every player on the same date. A completed daily challenge is recorded on the device.
- Online races use six-character room codes and Firestore real-time updates to compare matched pairs on the same solvable layout.
- To enable multiplayer, configure Firebase as described below, enable Anonymous Authentication, create Firestore, and deploy the current `firestore.rules`. The game falls back to local-only play when Firebase is unavailable; online rooms cannot work until configured.

## Firebase cloud saves

Follow [FIREBASE_SETUP.md](FIREBASE_SETUP.md). Copy `firebase.local.example.json` to `firebase.local.json`, enter the Firebase project/app values, then run:

~~~sh
flutter pub get
flutter run --dart-define-from-file=firebase.local.json
~~~

Enable only **Firebase Authentication → Sign-in method → Anonymous**; Google and Apple OAuth configuration is not used. Create Firestore and deploy `firestore.rules`. The local config file is ignored by Git.

Without valid Firebase config, play and saves remain local-only. Anonymous saves are not recoverable across reinstall/device changes without a future account-linking or recovery feature.

## Build and verification status

No successful Flutter compile, APK, IPA, or real Firestore write has been verified in this editing session. The repository does not yet contain a real Firebase project configuration. Treat the cloud-save integration as implemented in source but pending setup and device verification.