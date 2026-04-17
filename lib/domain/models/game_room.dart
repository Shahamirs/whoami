import 'package:freezed_annotation/freezed_annotation.dart';
import 'player.dart';
import 'enums.dart';

part 'game_room.freezed.dart';
part 'game_room.g.dart';

@freezed
abstract class TurnMessage with _$TurnMessage {
  const factory TurnMessage({
    required String id,
    required String playerId,
    required String text,
    @Default(false) bool isQuestion,
    bool? answerWasYes,
  }) = _TurnMessage;

  factory TurnMessage.fromJson(Map<String, dynamic> json) => _$TurnMessageFromJson(json);
}

@freezed
abstract class GameRoom with _$GameRoom {
  const factory GameRoom({
    required String id,
    required String hostId,
    @Default(RoomStatus.waiting) RoomStatus status,
    @Default(GameMode.manual) GameMode mode,
    String? category,
    @Default([]) List<Player> players,
    String? currentTurnPlayerId,
    @Default([]) List<TurnMessage> turnMessages,
  }) = _GameRoom;

  factory GameRoom.fromJson(Map<String, dynamic> json) => _$GameRoomFromJson(json);
}
