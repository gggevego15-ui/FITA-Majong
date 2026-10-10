import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

class MultiplayerRoom {
  final String code;
  final int seed;
  final String playerUid;
  const MultiplayerRoom({required this.code, required this.seed, required this.playerUid});
}

class MultiplayerService {
  MultiplayerService._();
  static final MultiplayerService instance = MultiplayerService._();

  bool get isAvailable => AuthService.instance.firebaseReady;

  Future<String> _uid() async {
    if (!isAvailable) {
      throw StateError('Онлайн-игра недоступна: сначала настрой Firebase для приложения.');
    }
    await AuthService.instance.continueAsGuest();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Не удалось войти в Firebase. Проверь анонимную авторизацию.');
    return uid;
  }

  int _seedFor(String code) {
    var value = 23;
    for (final unit in code.codeUnits) {
      value = (value * 37 + unit) & 0x7fffffff;
    }
    return value;
  }

  Future<MultiplayerRoom> createRoom() async {
    final uid = await _uid();
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final rooms = FirebaseFirestore.instance.collection('matches');
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = List.generate(6, (_) => alphabet[random.nextInt(alphabet.length)]).join();
      final ref = rooms.doc(code);
      try {
        final existing = await ref.get();
        if (existing.exists) continue;
      } on FirebaseException catch (error) {
        // A collision with a room the current player cannot read is retried.
        if (error.code == 'permission-denied') continue;
        rethrow;
      }
      final seed = _seedFor(code);
      await ref.set({
        'code': code,
        'seed': seed,
        'hostUid': uid,
        'guestUid': null,
        'hostPairs': 72,
        'guestPairs': 72,
        'hostWon': false,
        'guestWon': false,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return MultiplayerRoom(code: code, seed: seed, playerUid: uid);
    }
    throw StateError('Не удалось создать комнату. Попробуй ещё раз.');
  }

  Future<MultiplayerRoom> joinRoom(String rawCode) async {
    final uid = await _uid();
    final code = rawCode.trim().toUpperCase();
    if (!RegExp(r'^[A-HJ-NP-Z2-9]{6}$').hasMatch(code)) {
      throw const FormatException('Введи шестизначный код комнаты.');
    }
    final ref = FirebaseFirestore.instance.collection('matches').doc(code);
    final seed = await FirebaseFirestore.instance.runTransaction<int>((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) throw StateError('Комната не найдена.');
      if (data['hostUid'] == uid) {
        return (data['seed'] as num).toInt();
      }
      if (data['guestUid'] != null && data['guestUid'] != uid) {
        throw StateError('В комнате уже два игрока.');
      }
      if (data['status'] == 'finished') throw StateError('Этот матч уже завершён.');
      tx.update(ref, {
        'guestUid': uid,
        'guestPairs': 72,
        'guestWon': false,
        'status': 'playing',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return (data['seed'] as num).toInt();
    });
    return MultiplayerRoom(code: code, seed: seed, playerUid: uid);
  }

  Stream<Map<String, dynamic>?> watchRoom(String code) =>
      FirebaseFirestore.instance.collection('matches').doc(code).snapshots().map((s) => s.data());

  Future<void> updateProgress({
    required String code,
    required String uid,
    required int pairsLeft,
    required bool won,
  }) async {
    final ref = FirebaseFirestore.instance.collection('matches').doc(code);
    final snap = await ref.get();
    final data = snap.data();
    if (data == null) return;
    final isHost = data['hostUid'] == uid;
    if (!isHost && data['guestUid'] != uid) return;
    await ref.update({
      isHost ? 'hostPairs' : 'guestPairs': pairsLeft,
      isHost ? 'hostWon' : 'guestWon': won,
      'status': won ? 'finished' : (data['guestUid'] == null ? 'waiting' : 'playing'),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
