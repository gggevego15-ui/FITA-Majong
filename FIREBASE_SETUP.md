# Firebase setup for FITA Majong online multiplayer

This repository contains the Firebase client integration, anonymous authentication, Firestore room service, and restrictive Firestore rules. **A real Firebase project has not been connected or tested from this repository-editing session.** Do not treat online multiplayer as ready until the checklist at the end passes on two devices.

## Values needed from your Firebase project

Create or select a project in the [Firebase Console](https://console.firebase.google.com/). Do not invent values: copy each one from **Project settings → General**.

### Required for Android online multiplayer

| Value | Where to find it | GitHub Actions repository variable |
|---|---|---|
| Firebase Project ID | Project settings → General → Project ID | `FITA_FIREBASE_PROJECT_ID` |
| Project number / Sender ID | Project settings → General → Project number | `FITA_FIREBASE_MESSAGING_SENDER_ID` |
| Android Firebase API key | Android app details in Project settings | `FITA_FIREBASE_ANDROID_API_KEY` |
| Android Firebase App ID | Android app details in Project settings | `FITA_FIREBASE_ANDROID_APP_ID` |

First register an Android app in Firebase. The current CI workflow generates the Android project with the default application ID `com.example.fita_mahjong`. Register that exact ID if you intend to keep it. For a public release, choose a permanent unique application ID first, change the native build configuration to match it, and register the same ID in Firebase. Do not register a guessed ID.

### Optional values for iOS

Register the iOS app using the exact bundle ID chosen for the app. Then set:

- `FITA_FIREBASE_IOS_API_KEY`
- `FITA_FIREBASE_IOS_APP_ID`
- `FITA_IOS_BUNDLE_ID`

These are used for iOS runtime configuration; the current GitHub Actions workflow only builds Android.

## Enable the Firebase services

1. In Firebase Console → **Authentication → Sign-in method**, enable **Anonymous**.
2. Create a **Cloud Firestore** database.
3. In this repository, `firebase.json` points the Firebase CLI at `firestore.rules`. Deploy the rules below before testing multiplayer.
4. Check the Firebase project is not restricted by API-key restrictions that block Firebase Authentication or Cloud Firestore requests from this app.

No Google/Apple OAuth provider, service-account key, or server secret is required for anonymous sign-in. Never put service-account private keys or Admin SDK credentials in the mobile app, in `firebase.local.json`, or in GitHub repository variables used as Dart defines.

## Configure local Android testing

Copy `firebase.local.example.json` to `firebase.local.json` and replace every `replace-...` placeholder with the real value from Firebase Console. The real local file is ignored by Git.

```sh
flutter pub get
flutter run --dart-define-from-file=firebase.local.json
```

The same file can be used to build an Android APK:

```sh
flutter build apk --release --dart-define-from-file=firebase.local.json
```

Do not commit the filled-in local file. Firebase client API keys are app configuration, not a substitute for Firestore security rules.

## Configure GitHub Actions

Open the repository on GitHub → **Settings → Secrets and variables → Actions → Variables → New repository variable**. Add the four Android values listed above. Add the three iOS values only if you also need iOS configuration.

The workflow checks whether the required Android values are present without printing their values. If they are missing, the build can still produce an offline/local-play APK, but **that APK is not configured for online multiplayer**.

## Deploy Firestore rules

From the repository root, with Firebase CLI installed and authenticated:

```sh
firebase login
firebase use YOUR_REAL_FIREBASE_PROJECT_ID
firebase deploy --only firestore:rules
```

Replace `YOUR_REAL_FIREBASE_PROJECT_ID` with the actual Project ID copied from Firebase Console. The repository does not contain a `.firebaserc` because the project ID is not known yet.

The rules restrict cloud saves to each authenticated UID and allow room access to the host, guest, or a player attempting to join a waiting room. Never replace them with public rules such as `allow read, write: if true`.

## Verification checklist

- [ ] Android app registered with the exact application ID used by the build.
- [ ] Four required Android GitHub Actions variables are present (or the local Dart-defines file is complete).
- [ ] Anonymous Authentication is enabled.
- [ ] Firestore database exists.
- [ ] `firebase deploy --only firestore:rules` completes successfully against the intended project.
- [ ] Run the app with valid config and tap Play; Firebase Console → Authentication → Users shows an anonymous user.
- [ ] On device A, create a room and share the six-character code.
- [ ] On device B, join using that code; the host should see the guest join.
- [ ] Make matches on both devices; each device should see the opponent's pair count update.
- [ ] Complete a match and verify the finished status is shown.
- [ ] Test that an unrelated third anonymous user cannot read or update an active room.
- [ ] Repeat on iOS only after its bundle ID and iOS Firebase values are configured.

A green Flutter build only verifies compilation; it does not prove Firebase credentials, Firestore rules, room creation, or real-time multiplayer work. Anonymous users are tied to the app installation and do not provide cross-device save recovery.
