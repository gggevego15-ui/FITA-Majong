import 'dart:convert';
import 'dart:math';

import '../config/firebase_runtime_config.dart';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Firebase initialization is deliberately non-fatal: local guest play remains
/// available before Firebase platform files and OAuth clients are configured.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool firebaseReady = false;
  String? initializationError;

  Future<void> initialize() async {
    if (!FirebaseRuntimeConfig.isConfigured) {
      firebaseReady = false;
      initializationError =
          'Firebase configuration is missing; local guest mode is available.';
      return;
    }
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseRuntimeConfig.currentPlatform,
        );
      }
      firebaseReady = true;
      initializationError = null;
    } on FirebaseException catch (error) {
      firebaseReady = false;
      initializationError = '${error.code}: ${error.message ?? error.toString()}';
    } catch (error) {
      firebaseReady = false;
      initializationError = error.toString();
    }
  }

  User? get firebaseUser => firebaseReady ? FirebaseAuth.instance.currentUser : null;
  bool get isGuest => firebaseUser?.isAnonymous ?? true;
  String? get displayName => firebaseUser?.displayName;
  String? get email => firebaseUser?.email;

  Future<String> continueAsGuest() async {
    if (firebaseReady) {
      try {
        final user = FirebaseAuth.instance.currentUser ??
            (await FirebaseAuth.instance.signInAnonymously()).user;
        if (user != null) return user.uid;
      } on FirebaseAuthException {
        // Fall back to a persistent device-local guest identity.
      }
    }
    final prefs = await SharedPreferences.getInstance();
    var guestId = prefs.getString('fita.local_guest_id');
    if (guestId == null) {
      final random = Random.secure();
      guestId = List<int>.generate(24, (_) => random.nextInt(256))
          .map((v) => v.toRadixString(16).padLeft(2, '0'))
          .join();
      await prefs.setString('fita.local_guest_id', guestId);
    }
    return guestId;
  }

  Future<UserCredential> signInWithGoogle() async {
    _requireFirebase();
    final google = GoogleSignIn(
      clientId: FirebaseRuntimeConfig.googleIosClientId.isEmpty
          ? null
          : FirebaseRuntimeConfig.googleIosClientId,
      serverClientId: FirebaseRuntimeConfig.googleServerClientId.isEmpty
          ? null
          : FirebaseRuntimeConfig.googleServerClientId,
    );
    final account = await google.signIn();
    if (account == null) {
      throw const AuthFlowCancelled();
    }
    final tokens = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: tokens.accessToken,
      idToken: tokens.idToken,
    );
    return _signInOrLink(credential);
  }

  Future<UserCredential> signInWithApple() async {
    _requireFirebase();
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      nonce: hashedNonce,
    );
    final oauth = OAuthProvider('apple.com').credential(
      idToken: apple.identityToken,
      rawNonce: rawNonce,
    );
    final result = await _signInOrLink(oauth);
    // Apple only returns the name on the first consent. Keep it if Firebase has
    // no display name yet; never overwrite an existing profile.
    final nameParts = [apple.givenName, apple.familyName]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (nameParts.isNotEmpty && (result.user?.displayName?.isEmpty ?? true)) {
      await result.user?.updateDisplayName(nameParts.join(' '));
    }
    return result;
  }

  Future<UserCredential> _signInOrLink(AuthCredential credential) async {
    final current = FirebaseAuth.instance.currentUser;
    if (current != null && current.isAnonymous) {
      try {
        return await current.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        // If the provider account already exists, sign into it instead. The
        // existing account's data is not merged automatically; that requires
        // an explicit product-level migration flow.
        if (error.code != 'credential-already-in-use' &&
            error.code != 'email-already-in-use') {
          rethrow;
        }
      }
    }
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (!firebaseReady) return;
    await FirebaseAuth.instance.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // Firebase sign-out has already completed.
    }
  }

  void _requireFirebase() {
    if (!firebaseReady) {
      throw StateError(
        'Firebase is not configured. Follow FIREBASE_SETUP.md, provide the '
        'required FITA_FIREBASE_* values, and enable providers in Firebase Console. '
        '${initializationError ?? ''}',
      );
    }
  }

  String _generateNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

class AuthFlowCancelled implements Exception {
  const AuthFlowCancelled();
}
