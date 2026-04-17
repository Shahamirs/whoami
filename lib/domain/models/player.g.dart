// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  name: json['name'] as String,
  characterName: json['characterName'] as String?,
  isGuessed: json['isGuessed'] as bool? ?? false,
  score: (json['score'] as num?)?.toInt() ?? 0,
  isHost: json['isHost'] as bool? ?? false,
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'characterName': instance.characterName,
  'isGuessed': instance.isGuessed,
  'score': instance.score,
  'isHost': instance.isHost,
};
