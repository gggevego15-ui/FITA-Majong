import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

/// Local-first progress storage. Cloud writes are attempted only when Firebase
/// is configured and an authenticated Firebase user exists.
class ProgressStore {
  ProgressStore._();
  static final ProgressStore instance = ProgressStore._();

  static const _levelKey = 'fita.progress.level';
  static const _soundKey = 'fita.settings.sound';
  static const _hapticsKey = 'fita.settings.haptics';

  Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    var result = <String, dynamic>{
      'level': prefs.getInt(_levelKey) ?? 1,
      'sound': prefs.getBool(_soundKey) ?? true,
      'haptics': prefs.getBool(_hapticsKey) ?? true,
    };

    final auth = AuthService.instance;
    final user = auth.firebaseUser;
    if (auth.firebaseReady && user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final cloud = snapshot.data();
        if (cloud != null) {
          final cloudLevel = (cloud['level'] as num?)?.toInt() ?? 1;
          if (cloudLevel > (result['level'] as int)) {
            result['level'] = cloudLevel;
            await prefs.setInt(_levelKey, cloudLevel);
          }
          // Cloud preferences are restored on sign-in; local changes are
          // uploaded by save() after the player changes them.
          if (cloud['sound'] is bool) {
            result['sound'] = cloud['sound'];
            await prefs.setBool(_soundKey, cloud['sound'] as bool);
          }
          if (cloud['haptics'] is bool) {
            result['haptics'] = cloud['haptics'];
            await prefs.setBool(_hapticsKey, cloud['haptics'] as bool);
          }
        } else {
          await _upload(user, result);
        }
      } catch (_) {
        // A network/rules error must not block offline play.
      }
    }
    return result;
  }

  Future<void> save({
    required int level,
    required bool sound,
    required bool haptics,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, level);
    await prefs.setBool(_soundKey, sound);
    await prefs.setBool(_hapticsKey, haptics);

    final user = AuthService.instance.firebaseUser;
    if (AuthService.instance.firebaseReady && user != null) {
      await _upload(user, {
        'level': level,
        'sound': sound,
        'haptics': haptics,
      });
    }
  }

  Future<void> _upload(User user, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
      'schemaVersion': 1,
    }, SetOptions(merge: true));
  }
}
