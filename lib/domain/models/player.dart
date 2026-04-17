import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
abstract class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    String? characterName,
    @Default(false) bool isGuessed,
    @Default(0) int score,
    @Default(false) bool isHost,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
