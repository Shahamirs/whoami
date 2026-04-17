import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/game_repository.dart';

class MockGameRepository implements IGameRepository {
  // Статические (общие для всего приложения) хранилища.
  // Это позволяет нескольким вкладкам одного браузера видеть одни и те же комнаты.
  static final Map<String, GameRoom> _rooms = {};
  static final Map<String, StreamController<GameRoom?>> _roomControllers = {};
  final _uuid = const Uuid();

  void _notify(String roomId) {
    if (_roomControllers.containsKey(roomId)) {
      _roomControllers[roomId]?.add(_rooms[roomId]);
    }
  }

  @override
  Future<String> createRoom(String hostId, GameMode mode, {String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final roomId = _uuid.v4().substring(0, 6).toUpperCase(); // Short code
    
    _rooms[roomId] = GameRoom(
      id: roomId,
      hostId: hostId,
      mode: mode,
      category: category,
      players: [],
    );
    _roomControllers[roomId] = StreamController<GameRoom?>.broadcast();
    _notify(roomId);
    return roomId;
  }

  @override
  Future<void> joinRoom(String roomId, Player player) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final room = _rooms[roomId];
    if (room == null) throw Exception('Room not found');
    
    // Add player if not already in
    if (!room.players.any((p) => p.id == player.id)) {
      final isHost = room.hostId == player.id;
      final newPlayer = player.copyWith(isHost: isHost);
      _rooms[roomId] = room.copyWith(
        players: [...room.players, newPlayer],
      );
      _notify(roomId);
    }
  }

  @override
  Future<void> leaveRoom(String roomId, String playerId) async {
    final room = _rooms[roomId];
    if (room == null) return;
    
    final updatedPlayers = room.players.where((p) => p.id != playerId).toList();
    _rooms[roomId] = room.copyWith(players: updatedPlayers);
    _notify(roomId);
  }

  @override
  Stream<GameRoom?> watchRoom(String roomId) async* {
    if (!_roomControllers.containsKey(roomId)) {
      _roomControllers[roomId] = StreamController<GameRoom?>.broadcast();
    }
    yield _rooms[roomId];
    yield* _roomControllers[roomId]!.stream;
  }

  @override
  Future<void> startPreparation(String roomId) async {
    final room = _rooms[roomId];
    if (room == null) return;
    _rooms[roomId] = room.copyWith(status: RoomStatus.preparing);
    _notify(roomId);
  }

  @override
  Future<void> submitCharacter(String roomId, String targetPlayerId, String characterName) async {
    final room = _rooms[roomId];
    if (room == null) return;
    
    final updatedPlayers = room.players.map((p) {
      if (p.id == targetPlayerId) {
        return p.copyWith(characterName: characterName);
      }
      return p;
    }).toList();
    
    _rooms[roomId] = room.copyWith(players: updatedPlayers);
    _notify(roomId);
  }

  @override
  Future<void> startGame(String roomId) async {
    final room = _rooms[roomId];
    if (room == null || room.players.isEmpty) return;
    
    _rooms[roomId] = room.copyWith(
      status: RoomStatus.playing,
      currentTurnPlayerId: room.players.first.id,
    );
    _notify(roomId);
  }

  @override
  Future<void> sendTurnMessage(String roomId, TurnMessage message) async {
    final room = _rooms[roomId];
    if (room == null) return;
    
    _rooms[roomId] = room.copyWith(
      turnMessages: [...room.turnMessages, message],
    );
    _notify(roomId);
  }

  @override
  Future<void> nextTurn(String roomId, String nextPlayerId) async {
     final room = _rooms[roomId];
    if (room == null) return;
    
    _rooms[roomId] = room.copyWith(
      currentTurnPlayerId: nextPlayerId,
    );
    _notify(roomId);
  }

  @override
  Future<void> guessCharacter(String roomId, String playerId, bool success) async {
     final room = _rooms[roomId];
    if (room == null) return;
    
    if (success) {
      final updatedPlayers = room.players.map((p) {
        if (p.id == playerId) {
          return p.copyWith(isGuessed: true);
        }
        return p;
      }).toList();
      
      final allGuessed = updatedPlayers.every((p) => p.isGuessed);
      
      _rooms[roomId] = room.copyWith(
        players: updatedPlayers,
        status: allGuessed ? RoomStatus.finished : room.status,
      );
    }
    _notify(roomId);
  }
}
