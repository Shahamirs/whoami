import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/game_repository.dart';

class FirebaseGameRepository implements IGameRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _rooms => _firestore.collection('rooms');

  @override
  Future<String> createRoom(String hostId, GameMode mode, {String? category}) async {
    // Generate a short 6-character uppercase code
    final roomId = _uuid.v4().substring(0, 6).toUpperCase();
    
    final room = GameRoom(
      id: roomId,
      hostId: hostId,
      mode: mode,
      category: category,
      players: [],
    );

    await _rooms.doc(roomId).set(room.toJson());
    return roomId;
  }

  @override
  Future<void> joinRoom(String roomId, Player player) async {
    return _firestore.runTransaction((transaction) async {
      final docRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Room not found');
      }

      final room = GameRoom.fromJson(snapshot.data()!);
      
      // Prevent duplicates
      if (!room.players.any((p) => p.id == player.id)) {
        final isHost = room.hostId == player.id;
        final newPlayer = player.copyWith(isHost: isHost);
        final updatedPlayers = [...room.players, newPlayer];
        
        transaction.update(docRef, {
          'players': updatedPlayers.map((p) => p.toJson()).toList(),
        });
      }
    });
  }

  @override
  Future<void> leaveRoom(String roomId, String playerId) async {
     final docRef = _rooms.doc(roomId);
     final snapshot = await docRef.get();
     if (!snapshot.exists) return;
     
     final room = GameRoom.fromJson(snapshot.data()!);
     final updatedPlayers = room.players.where((p) => p.id != playerId).toList();
     
     await docRef.update({
       'players': updatedPlayers.map((p) => p.toJson()).toList(),
     });
  }

  @override
  Stream<GameRoom?> watchRoom(String roomId) {
    return _rooms.doc(roomId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return GameRoom.fromJson(snapshot.data()!);
    });
  }

  @override
  Future<void> startPreparation(String roomId) async {
    await _rooms.doc(roomId).update({
      'status': RoomStatus.preparing.name,
    });
  }

  @override
  Future<void> submitCharacter(String roomId, String targetPlayerId, String characterName) async {
    return _firestore.runTransaction((transaction) async {
      final docRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return;

      final room = GameRoom.fromJson(snapshot.data()!);
      final updatedPlayers = room.players.map((p) {
        if (p.id == targetPlayerId) {
          return p.copyWith(characterName: characterName);
        }
        return p;
      }).toList();

      transaction.update(docRef, {
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
      });
    });
  }

  @override
  Future<void> startGame(String roomId) async {
    return _firestore.runTransaction((transaction) async {
      final docRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return;
      final room = GameRoom.fromJson(snapshot.data()!);
      if (room.players.isEmpty) return;

      transaction.update(docRef, {
        'status': RoomStatus.playing.name,
        'currentTurnPlayerId': room.players.first.id,
      });
    });
  }

  @override
  Future<void> sendTurnMessage(String roomId, TurnMessage message) async {
    return _firestore.runTransaction((transaction) async {
      final docRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return;
      final room = GameRoom.fromJson(snapshot.data()!);

      final updatedMessages = [...room.turnMessages, message];
      transaction.update(docRef, {
        'turnMessages': updatedMessages.map((m) => m.toJson()).toList(),
      });
    });
  }

  @override
  Future<void> nextTurn(String roomId, String nextPlayerId) async {
    await _rooms.doc(roomId).update({
      'currentTurnPlayerId': nextPlayerId,
    });
  }

  @override
  Future<void> guessCharacter(String roomId, String playerId, bool success) async {
    return _firestore.runTransaction((transaction) async {
      final docRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return;
      final room = GameRoom.fromJson(snapshot.data()!);

      if (success) {
        final updatedPlayers = room.players.map((p) {
          if (p.id == playerId) {
            return p.copyWith(isGuessed: true);
          }
          return p;
        }).toList();

        final allGuessed = updatedPlayers.every((p) => p.isGuessed);

        transaction.update(docRef, {
          'players': updatedPlayers.map((p) => p.toJson()).toList(),
          'status': allGuessed ? RoomStatus.finished.name : room.status.name,
        });
      }
    });
  }
}
