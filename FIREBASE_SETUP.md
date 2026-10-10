# Firebase setup for FITA Mahjong

This guide configures real Firebase Authentication and Firestore. The source integration is present, but authentication and cloud sync are **not live until you supply a real Firebase project and test on devices**.

## 1. Create/register the Firebase apps

1. Open the [Firebase Console](https://console.firebase.google.com/) and create a project.
2. Add an Android app using the exact Android application ID used by the generated native project. The current CI workflow generates `com.example.fita_mahjong` as a temporary default. Before production, choose a unique final ID and update the Flutter project-generation command plus the Firebase Android registration together. Record its Firebase **App ID** and API key.
3. Add an iOS app using a stable reverse-DNS bundle ID, for example `com.example.fitamahjong` (choose your final ID before release). Record its Firebase **App ID** and API key.
4. In Project settings → General, record the **Project ID** and **Project number** (used as Messaging Sender ID).
5. The runtime config in `lib/config/firebase_runtime_config.dart` initializes Firebase with platform-specific options. This source path does not require `google-services.json` or `GoogleService-Info.plist` to initialize Firebase. However, Google Sign-In still needs the OAuth client IDs below, and iOS still needs its reversed-client-ID URL scheme in `ios/Runner/Info.plist`. Do not commit service-account credentials or private keys.

## 2. Set runtime values locally

1. Copy `firebase.local.example.json` to `firebase.local.json`.
2. Replace all `replace-...` values with the corresponding values from Firebase / Google Cloud. Keep `firebase.local.json` out of Git; it is ignored by `.gitignore`.
3. Install Flutter, then run:

```sh
flutter pub get
flutter run --dart-define-from-file=firebase.local.json
```

For a release build, use the same define file with `flutter build apk --release --dart-define-from-file=firebase.local.json`. Never add a service-account private key, Apple `.p8` private key, or other server secret to this file or the mobile app. Firebase client API keys and OAuth client IDs identify the app; they are not substitutes for security rules.

## 3. Enable Firebase Authentication

In Firebase Console → Authentication → Sign-in method, enable **Anonymous**, **Google**, and **Apple**.

### Google OAuth

1. Configure the Google provider in Firebase Authentication.
2. In Google Cloud Console → APIs & Services → Credentials, check the OAuth client IDs created for the Firebase project.
3. Put the **Web application OAuth client ID** in `FITA_GOOGLE_SERVER_CLIENT_ID`. It must end with `.apps.googleusercontent.com`; it is a client ID, not a client secret. The code now stops with a configuration message if this value is missing.
4. Put the iOS OAuth client ID in `FITA_GOOGLE_IOS_CLIENT_ID` and confirm its bundle ID matches the registered Firebase iOS app. The code now stops with a configuration message if this value is missing on iOS.
5. Android: create/check an Android OAuth client for the exact package/application ID and add the SHA-1 and SHA-256 fingerprints for every signing certificate used (debug, CI/release, and Play App Signing where applicable). The current CI-generated package ID is `com.example.fita_mahjong`; use a final unique ID before release and register that exact ID. Because this repo passes `serverClientId` in Dart, a `google-services.json` file is not required solely for Google Sign-In; the Web client ID must still be valid. See [Google Sign-In Android setup](https://github.com/flutter/packages/blob/main/packages/google_sign_in/google_sign_in_android/README.md).
6. iOS: add the reversed iOS client ID as a URL scheme in `ios/Runner/Info.plist`. Even when client IDs are passed from Dart, the URL scheme callback is still required. The plist section must be added inside the existing top-level `dict`; do not create a second `CFBundleURLTypes` key if one already exists:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>REVERSED_IOS_CLIENT_ID_FROM_GOOGLE_CONSOLE</string>
    </array>
  </dict>
</array>
```

Replace the placeholder with the **REVERSED_CLIENT_ID** value associated with the iOS OAuth client / Firebase iOS app (often shaped like `com.googleusercontent.apps....`). Preserve any existing URL schemes. Test on a physical iOS device.

### Apple sign-in

1. Requires an Apple Developer team and an app identifier that has **Sign in with Apple** enabled.
2. In Certificates, Identifiers & Profiles, enable the Sign in with Apple capability for the App ID. Enable the same capability in the Xcode Runner target (Signing & Capabilities).
3. In Firebase Console → Authentication → Apple provider, configure the Apple Team ID, Key ID, Services ID and private key as requested by Firebase. Create/download the Apple key in the Apple Developer portal; store the `.p8` securely and enter it only in the protected Firebase Console field. Never commit it.
4. Configure the required return URL / domain in the Apple Services ID if Firebase Console's setup flow requests it.
5. Test on a real iOS device with the final bundle ID and signing team. Apple may provide name/email only on first consent.

The Apple button is shown only on iOS in the current UI. Apple provider setup cannot be completed solely in source code.

## 4. Create Firestore and deploy secure rules

1. Create a Cloud Firestore database in the Firebase Console.
2. Review `firestore.rules`, then deploy it using Firebase CLI after installing and logging into the CLI:

```sh
firebase use YOUR_FIREBASE_PROJECT_ID
firebase deploy --only firestore:rules
```

Do not deploy public rules such as `allow read, write: if true`. The app stores a document at `users/{Firebase UID}`; rules must require an authenticated request whose UID matches the document ID.

## 5. Test checklist

- [ ] App launches without a Firebase config file and guest mode still works locally.
- [ ] With `firebase.local.json`, anonymous guest sign-in appears in Firebase Authentication.
- [ ] Google sign-in works on Android with the correct application ID, Web client ID, and signing SHA fingerprints.
- [ ] Google sign-in works on iOS with the iOS client ID, Web client ID, and matching reversed-client-ID URL scheme.
- [ ] Apple sign-in works on a physical iOS device.
- [ ] A signed-in user's `users/{uid}` document is created/updated.
- [ ] A different signed-in UID cannot read or modify that document.
- [ ] Progress survives app restart and appears after sign-in on a second device.
- [ ] Offline play continues when Firestore is unavailable, then a later save/load syncs again.

## Current limitations

- No Firebase project or OAuth client credentials have been supplied to this repository, so provider flows and cloud sync are not yet verified. The Google sign-in code now checks for required client IDs and a non-empty ID token, but that validation is not a substitute for device testing.
- The local-only guest ID cannot sync to another device until the guest signs into Firebase. If the player chooses an already-existing Google/Apple account instead of linking the anonymous account, cloud progress migration must be handled explicitly.
- No background retry queue, real-time multi-device conflict resolution, account deletion flow, or automated Firebase Emulator tests are included yet.
- The Android GitHub Actions workflow passes optional Firebase runtime values into the APK build. To enable this, open **Repository → Settings → Secrets and variables → Actions → Variables** and add the exact names below as repository variables (these are client-side app identifiers, not private keys):

- `FITA_FIREBASE_PROJECT_ID`
- `FITA_FIREBASE_MESSAGING_SENDER_ID`
- `FITA_FIREBASE_ANDROID_API_KEY`
- `FITA_FIREBASE_ANDROID_APP_ID`
- `FITA_FIREBASE_IOS_API_KEY`
- `FITA_FIREBASE_IOS_APP_ID`
- `FITA_IOS_BUNDLE_ID`
- `FITA_GOOGLE_SERVER_CLIENT_ID`
- `FITA_GOOGLE_IOS_CLIENT_ID`

The Android build only consumes the Android values plus the shared project/sender/Google server client values. iOS values are prepared for local iOS runs; this workflow does not build an IPA. If the variables are absent, the APK can still compile in local-guest-only mode, so a green CI build alone does not prove OAuth works.
