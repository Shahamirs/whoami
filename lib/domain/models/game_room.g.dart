// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TurnMessage _$TurnMessageFromJson(Map<String, dynamic> json) => _TurnMessage(
  id: json['id'] as String,
  playerId: json['playerId'] as String,
  text: json['text'] as String,
  isQuestion: json['isQuestion'] as bool? ?? false,
  answerWasYes: json['answerWasYes'] as bool?,
);

Map<String, dynamic> _$TurnMessageToJson(_TurnMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playerId': instance.playerId,
      'text': instance.text,
      'isQuestion': instance.isQuestion,
      'answerWasYes': instance.answerWasYes,
    };

_GameRoom _$GameRoomFromJson(Map<String, dynamic> json) => _GameRoom(
  id: json['id'] as String,
  hostId: json['hostId'] as String,
  status:
      $enumDecodeNullable(_$RoomStatusEnumMap, json['status']) ??
      RoomStatus.waiting,
  mode: $enumDecodeNullable(_$GameModeEnumMap, json['mode']) ?? GameMode.manual,
  category: json['category'] as String?,
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currentTurnPlayerId: json['currentTurnPlayerId'] as String?,
  turnMessages:
      (json['turnMessages'] as List<dynamic>?)
          ?.map((e) => TurnMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$GameRoomToJson(_GameRoom instance) => <String, dynamic>{
  'id': instance.id,
  'hostId': instance.hostId,
  'status': _$RoomStatusEnumMap[instance.status]!,
  'mode': _$GameModeEnumMap[instance.mode]!,
  'category': instance.category,
  'players': instance.players,
  'currentTurnPlayerId': instance.currentTurnPlayerId,
  'turnMessages': instance.turnMessages,
};

const _$RoomStatusEnumMap = {
  RoomStatus.waiting: 'waiting',
  RoomStatus.preparing: 'preparing',
  RoomStatus.playing: 'playing',
  RoomStatus.finished: 'finished',
};

const _$GameModeEnumMap = {GameMode.manual: 'manual', GameMode.auto: 'auto'};
