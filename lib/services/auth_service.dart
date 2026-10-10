import 'dart:math';

import '../config/firebase_runtime_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No interactive sign-in: Firebase anonymous auth gives each installation a
/// private UID so Firestore rules can protect that player's cloud save.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool firebaseReady = false;
  String? initializationError;

  User? get firebaseUser =>
      firebaseReady ? FirebaseAuth.instance.currentUser : null;

  Future<void> initialize() async {
    if (!FirebaseRuntimeConfig.isConfigured) {
      firebaseReady = false;
      initializationError =
          'Firebase configuration is missing; saves are local-only.';
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

  /// Creates/reuses an anonymous Firebase user without showing a login UI.
  /// If Firebase is unavailable, preserves offline play with a local device ID.
  Future<String> continueAsGuest() async {
    if (firebaseReady) {
      try {
        final current = FirebaseAuth.instance.currentUser;
        final user = current ?? (await FirebaseAuth.instance.signInAnonymously()).user;
        if (user != null) return user.uid;
      } on FirebaseAuthException catch (error) {
        initializationError = '${error.code}: ${error.message ?? error.toString()}';
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
}
