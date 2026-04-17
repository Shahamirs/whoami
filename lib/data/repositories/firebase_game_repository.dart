import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/game_repository.dart';

class FirebaseGameRepository implements IGameRepository {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final _uuid = const Uuid();

  DatabaseReference get _rooms => _database.ref('rooms');

  Map<String, dynamic>? _normalize(Object? value) {
    if (value == null) return null;
    return jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
  }

  @override
  Future<String> createRoom(String hostId, GameMode mode, {String? category}) async {
    final roomId = _uuid.v4().substring(0, 6).toUpperCase();
    
    final room = GameRoom(
      id: roomId,
      hostId: hostId,
      mode: mode,
      category: category,
      players: [],
    );

    await _rooms.child(roomId).set(room.toJson());
    // Also disconnect handler for host if possible? We'll leave it for now.
    return roomId;
  }

  @override
  Future<void> joinRoom(String roomId, Player player) async {
    final docRef = _rooms.child(roomId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) throw Exception('Room not found');

    final data = _normalize(snapshot.value);
    if (data == null) return;
    
    final room = GameRoom.fromJson(data);
    
    if (!room.players.any((p) => p.id == player.id)) {
      final isHost = room.hostId == player.id;
      final newPlayer = player.copyWith(isHost: isHost);
      final updatedPlayers = [...room.players, newPlayer];
      
      await docRef.update({
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
      });
      
      // Basic presence
      docRef.child('players').onDisconnect().cancel();
      // On real multiplayer apps we use presence, skipping for MVP
    }
  }

  @override
  Future<void> leaveRoom(String roomId, String playerId) async {
    final docRef = _rooms.child(roomId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;
    
    final data = _normalize(snapshot.value);
    if (data == null) return;
    final room = GameRoom.fromJson(data);
    
    final updatedPlayers = room.players.where((p) => p.id != playerId).toList();
    
    await docRef.update({
      'players': updatedPlayers.map((p) => p.toJson()).toList(),
    });
  }

  @override
  Stream<GameRoom?> watchRoom(String roomId) {
    return _rooms.child(roomId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return null;
      try {
        final data = _normalize(event.snapshot.value);
        if (data == null) return null;
        return GameRoom.fromJson(data);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> startPreparation(String roomId) async {
    await _rooms.child(roomId).update({
      'status': RoomStatus.preparing.name,
    });
  }

  @override
  Future<void> submitCharacter(String roomId, String targetPlayerId, String characterName) async {
    final docRef = _rooms.child(roomId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = _normalize(snapshot.value);
    if (data == null) return;
    final room = GameRoom.fromJson(data);

    final updatedPlayers = room.players.map((p) {
      if (p.id == targetPlayerId) {
        return p.copyWith(characterName: characterName);
      }
      return p;
    }).toList();

    await docRef.update({
      'players': updatedPlayers.map((p) => p.toJson()).toList(),
    });
  }

  @override
  Future<void> startGame(String roomId) async {
    final docRef = _rooms.child(roomId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = _normalize(snapshot.value);
    if (data == null) return;
    final room = GameRoom.fromJson(data);
    
    if (room.players.isEmpty) return;

    await docRef.update({
      'status': RoomStatus.playing.name,
      'currentTurnPlayerId': room.players.first.id,
    });
  }

  @override
  Future<void> sendTurnMessage(String roomId, TurnMessage message) async {
    final docRef = _rooms.child(roomId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = _normalize(snapshot.value);
    if (data == null) return;
    final room = GameRoom.fromJson(data);

    final updatedMessages = [...room.turnMessages, message];
    await docRef.update({
      'turnMessages': updatedMessages.map((m) => m.toJson()).toList(),
    });
  }

  @override
  Future<void> nextTurn(String roomId, String nextPlayerId) async {
    await _rooms.child(roomId).update({
      'currentTurnPlayerId': nextPlayerId,
    });
  }

  @override
  Future<void> guessCharacter(String roomId, String playerId, bool success) async {
    final docRef = _rooms.child(roomId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = _normalize(snapshot.value);
    if (data == null) return;
    final room = GameRoom.fromJson(data);

    if (success) {
      final updatedPlayers = room.players.map((p) {
        if (p.id == playerId) {
          return p.copyWith(isGuessed: true);
        }
        return p;
      }).toList();

      final allGuessed = updatedPlayers.every((p) => p.isGuessed);

      await docRef.update({
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
        'status': allGuessed ? RoomStatus.finished.name : room.status.name,
      });
    }
  }
}
