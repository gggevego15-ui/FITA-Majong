# Firebase cloud saves (no login screen)

FITA Mahjong has **no Google/Apple sign-in UI**. The app uses Firebase Authentication's **anonymous sign-in in the background** to get a private UID, so Firestore rules can securely isolate each player's save. Players do not enter an email, choose a provider, or create a visible account.

Cloud saves work only after you configure a Firebase project and enable Anonymous Authentication. Without Firebase config or network, the game remains playable and stores progress on the device.

## 1. Register the apps

1. Open the [Firebase Console](https://console.firebase.google.com/) and create/select a project.
2. Register Android using the exact application ID in the native project. The current CI workflow temporarily generates `com.example.fita_mahjong`; choose a unique final ID before production and use it consistently.
3. Register iOS using your final bundle ID (reverse-DNS format).
4. In Project settings → General, copy Project ID and Project number (Messaging Sender ID). Copy each platform's Firebase App ID and API key.
5. The app initializes Firebase with Dart runtime options, so `google-services.json` and `GoogleService-Info.plist` are not required by this initialization path. No Google OAuth clients, SHA fingerprints, iOS Google URL scheme, Apple Developer capability, or Apple key are required for anonymous cloud saves.

## 2. Configure local runtime values

Copy `firebase.local.example.json` to `firebase.local.json`, replace every `replace-...` value with values from Firebase Console, and keep the local file untracked (it is ignored by Git).

~~~sh
flutter pub get
flutter run --dart-define-from-file=firebase.local.json
~~~

For Android release:

~~~sh
flutter build apk --release --dart-define-from-file=firebase.local.json
~~~

Never put service-account private keys or server credentials in the app or this file. Firebase client API keys are app identifiers, not database security controls.

## 3. Enable anonymous Firebase Authentication

In Firebase Console → Authentication → Sign-in method, enable **Anonymous**. Google and Apple providers can stay disabled.

When the player taps Play, the app silently calls `signInAnonymously()`. Firebase persists that anonymous user's session on the device. Firestore writes use this Firebase UID.

If Anonymous is disabled or Firebase values are incorrect, the app falls back to local-only saves; cloud sync will not be available until configuration is fixed.

## 4. Create Firestore and deploy rules

1. Create a Cloud Firestore database in Firebase Console.
2. From the repository root, install Firebase CLI and sign in if needed.
3. Select your project and deploy the repository rules:

~~~sh
firebase use YOUR_FIREBASE_PROJECT_ID
firebase deploy --only firestore:rules
~~~

The rules restrict each user to their own `users/{uid}` document and validate saved fields. **Do not use public rules** such as `allow read, write: if true`.

## 5. Verify cloud saves

- [ ] Run with a real `firebase.local.json` file on Android.
- [ ] Tap Play; Firebase Console → Authentication → Users should show an anonymous user.
- [ ] Finish a level or change a setting; verify `users/{uid}` is created/updated in Firestore.
- [ ] Restart the app and verify progress/preferences restore.
- [ ] Repeat on iOS with its registered bundle ID and iOS Firebase options.
- [ ] Test with networking disabled: local play should continue.

## Important limitation of no-login cloud saves

An anonymous Firebase UID is not a recoverable identity. It generally stays with that app installation, but if the user clears app data, reinstalls, or changes devices, the anonymous account/save cannot automatically be recovered or linked across devices. Cross-device and recovery support would require an account-linking/recovery feature later. The current implementation has no background retry queue or conflict resolution. No real Firebase project was supplied here, so live cloud writes and device builds have not yet been verified.

## GitHub Actions variables

To pass Firebase config into the Android APK build, set these repository variables at Settings → Secrets and variables → Actions → Variables:

- `FITA_FIREBASE_PROJECT_ID`
- `FITA_FIREBASE_MESSAGING_SENDER_ID`
- `FITA_FIREBASE_ANDROID_API_KEY`
- `FITA_FIREBASE_ANDROID_APP_ID`

The workflow also forwards iOS app values for consistency, but it only builds Android:

- `FITA_FIREBASE_IOS_API_KEY`
- `FITA_FIREBASE_IOS_APP_ID`
- `FITA_IOS_BUNDLE_ID`

A green APK build does not prove Firebase authentication or Firestore access works. Test with your real project and inspect Firebase Console.