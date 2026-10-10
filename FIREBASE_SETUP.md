# Firebase setup for FITA Mahjong

This guide configures real Firebase Authentication and Firestore. The source integration is present, but authentication and cloud sync are **not live until you supply a real Firebase project and test on devices**.

## 1. Create/register the Firebase apps

1. Open the [Firebase Console](https://console.firebase.google.com/) and create a project.
2. Add an Android app using the exact Android application ID used by the generated native project. The current CI workflow generates `com.example.fita_mahjong` as a temporary default. Before production, choose a unique final ID and update the Flutter project-generation command plus the Firebase Android registration together. Record its Firebase **App ID** and API key.
3. Add an iOS app using a stable reverse-DNS bundle ID, for example `com.example.fitamahjong` (choose your final ID before release). Record its Firebase **App ID** and API key.
4. In Project settings → General, record the **Project ID** and **Project number** (used as Messaging Sender ID).
5. The runtime config in `lib/config/firebase_runtime_config.dart` initializes Firebase with platform-specific options. Native `google-services.json` / `GoogleService-Info.plist` files are not required by this particular initialization path, but can be added if you later adopt the standard FlutterFire generated configuration. Do not commit service-account credentials or private keys.

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
3. Put the **Web application OAuth client ID** in `FITA_GOOGLE_SERVER_CLIENT_ID`. It must be the client ID, not a client secret.
4. Put the iOS OAuth client ID in `FITA_GOOGLE_IOS_CLIENT_ID` and confirm its bundle ID matches the registered Firebase iOS app.
5. Android: configure the Android OAuth client for the exact package name and add the SHA-1 and SHA-256 fingerprints for each signing certificate you use (debug, CI/release, and Play App Signing where applicable). Google sign-in will not be reliable until those fingerprints and client IDs match.
6. iOS: configure the reversed client-ID URL scheme as required by the Google Sign-In iOS setup. With a Flutter project, verify the URL type in `ios/Runner/Info.plist` and test on a physical device.

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
- [ ] Google sign-in works on Android with the correct signing SHA fingerprints.
- [ ] Google sign-in works on iOS with matching OAuth client IDs and URL scheme.
- [ ] Apple sign-in works on a physical iOS device.
- [ ] A signed-in user's `users/{uid}` document is created/updated.
- [ ] A different signed-in UID cannot read or modify that document.
- [ ] Progress survives app restart and appears after sign-in on a second device.
- [ ] Offline play continues when Firestore is unavailable, then a later save/load syncs again.

## Current limitations

- No Firebase project or OAuth client credentials have been supplied to this repository, so provider flows and cloud sync are not yet verified.
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
