import '../models/models.dart';

abstract class IGameRepository {
  Future<String> createRoom(String hostId, GameMode mode, {String? category});
  Future<void> joinRoom(String roomId, Player player);
  Future<void> leaveRoom(String roomId, String playerId);
  Stream<GameRoom?> watchRoom(String roomId);
  Future<void> startPreparation(String roomId);
  Future<void> submitCharacter(String roomId, String targetPlayerId, String characterName);
  Future<void> startGame(String roomId);
  Future<void> sendTurnMessage(String roomId, TurnMessage message);
  Future<void> nextTurn(String roomId, String nextPlayerId);
  Future<void> guessCharacter(String roomId, String playerId, bool success);
}
