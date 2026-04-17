// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TurnMessage {

 String get id; String get playerId; String get text; bool get isQuestion; bool? get answerWasYes;
/// Create a copy of TurnMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TurnMessageCopyWith<TurnMessage> get copyWith => _$TurnMessageCopyWithImpl<TurnMessage>(this as TurnMessage, _$identity);

  /// Serializes this TurnMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TurnMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.text, text) || other.text == text)&&(identical(other.isQuestion, isQuestion) || other.isQuestion == isQuestion)&&(identical(other.answerWasYes, answerWasYes) || other.answerWasYes == answerWasYes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,playerId,text,isQuestion,answerWasYes);

@override
String toString() {
  return 'TurnMessage(id: $id, playerId: $playerId, text: $text, isQuestion: $isQuestion, answerWasYes: $answerWasYes)';
}


}

/// @nodoc
abstract mixin class $TurnMessageCopyWith<$Res>  {
  factory $TurnMessageCopyWith(TurnMessage value, $Res Function(TurnMessage) _then) = _$TurnMessageCopyWithImpl;
@useResult
$Res call({
 String id, String playerId, String text, bool isQuestion, bool? answerWasYes
});




}
/// @nodoc
class _$TurnMessageCopyWithImpl<$Res>
    implements $TurnMessageCopyWith<$Res> {
  _$TurnMessageCopyWithImpl(this._self, this._then);

  final TurnMessage _self;
  final $Res Function(TurnMessage) _then;

/// Create a copy of TurnMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? playerId = null,Object? text = null,Object? isQuestion = null,Object? answerWasYes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isQuestion: null == isQuestion ? _self.isQuestion : isQuestion // ignore: cast_nullable_to_non_nullable
as bool,answerWasYes: freezed == answerWasYes ? _self.answerWasYes : answerWasYes // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [TurnMessage].
extension TurnMessagePatterns on TurnMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TurnMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TurnMessage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TurnMessage value)  $default,){
final _that = this;
switch (_that) {
case _TurnMessage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TurnMessage value)?  $default,){
final _that = this;
switch (_that) {
case _TurnMessage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String playerId,  String text,  bool isQuestion,  bool? answerWasYes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TurnMessage() when $default != null:
return $default(_that.id,_that.playerId,_that.text,_that.isQuestion,_that.answerWasYes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String playerId,  String text,  bool isQuestion,  bool? answerWasYes)  $default,) {final _that = this;
switch (_that) {
case _TurnMessage():
return $default(_that.id,_that.playerId,_that.text,_that.isQuestion,_that.answerWasYes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String playerId,  String text,  bool isQuestion,  bool? answerWasYes)?  $default,) {final _that = this;
switch (_that) {
case _TurnMessage() when $default != null:
return $default(_that.id,_that.playerId,_that.text,_that.isQuestion,_that.answerWasYes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TurnMessage implements TurnMessage {
  const _TurnMessage({required this.id, required this.playerId, required this.text, this.isQuestion = false, this.answerWasYes});
  factory _TurnMessage.fromJson(Map<String, dynamic> json) => _$TurnMessageFromJson(json);

@override final  String id;
@override final  String playerId;
@override final  String text;
@override@JsonKey() final  bool isQuestion;
@override final  bool? answerWasYes;

/// Create a copy of TurnMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TurnMessageCopyWith<_TurnMessage> get copyWith => __$TurnMessageCopyWithImpl<_TurnMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TurnMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TurnMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.text, text) || other.text == text)&&(identical(other.isQuestion, isQuestion) || other.isQuestion == isQuestion)&&(identical(other.answerWasYes, answerWasYes) || other.answerWasYes == answerWasYes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,playerId,text,isQuestion,answerWasYes);

@override
String toString() {
  return 'TurnMessage(id: $id, playerId: $playerId, text: $text, isQuestion: $isQuestion, answerWasYes: $answerWasYes)';
}


}

/// @nodoc
abstract mixin class _$TurnMessageCopyWith<$Res> implements $TurnMessageCopyWith<$Res> {
  factory _$TurnMessageCopyWith(_TurnMessage value, $Res Function(_TurnMessage) _then) = __$TurnMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String playerId, String text, bool isQuestion, bool? answerWasYes
});




}
/// @nodoc
class __$TurnMessageCopyWithImpl<$Res>
    implements _$TurnMessageCopyWith<$Res> {
  __$TurnMessageCopyWithImpl(this._self, this._then);

  final _TurnMessage _self;
  final $Res Function(_TurnMessage) _then;

/// Create a copy of TurnMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? playerId = null,Object? text = null,Object? isQuestion = null,Object? answerWasYes = freezed,}) {
  return _then(_TurnMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isQuestion: null == isQuestion ? _self.isQuestion : isQuestion // ignore: cast_nullable_to_non_nullable
as bool,answerWasYes: freezed == answerWasYes ? _self.answerWasYes : answerWasYes // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$GameRoom {

 String get id; String get hostId; RoomStatus get status; GameMode get mode; String? get category; List<Player> get players; String? get currentTurnPlayerId; List<TurnMessage> get turnMessages;
/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameRoomCopyWith<GameRoom> get copyWith => _$GameRoomCopyWithImpl<GameRoom>(this as GameRoom, _$identity);

  /// Serializes this GameRoom to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.players, players)&&(identical(other.currentTurnPlayerId, currentTurnPlayerId) || other.currentTurnPlayerId == currentTurnPlayerId)&&const DeepCollectionEquality().equals(other.turnMessages, turnMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hostId,status,mode,category,const DeepCollectionEquality().hash(players),currentTurnPlayerId,const DeepCollectionEquality().hash(turnMessages));

@override
String toString() {
  return 'GameRoom(id: $id, hostId: $hostId, status: $status, mode: $mode, category: $category, players: $players, currentTurnPlayerId: $currentTurnPlayerId, turnMessages: $turnMessages)';
}


}

/// @nodoc
abstract mixin class $GameRoomCopyWith<$Res>  {
  factory $GameRoomCopyWith(GameRoom value, $Res Function(GameRoom) _then) = _$GameRoomCopyWithImpl;
@useResult
$Res call({
 String id, String hostId, RoomStatus status, GameMode mode, String? category, List<Player> players, String? currentTurnPlayerId, List<TurnMessage> turnMessages
});




}
/// @nodoc
class _$GameRoomCopyWithImpl<$Res>
    implements $GameRoomCopyWith<$Res> {
  _$GameRoomCopyWithImpl(this._self, this._then);

  final GameRoom _self;
  final $Res Function(GameRoom) _then;

/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hostId = null,Object? status = null,Object? mode = null,Object? category = freezed,Object? players = null,Object? currentTurnPlayerId = freezed,Object? turnMessages = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RoomStatus,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,currentTurnPlayerId: freezed == currentTurnPlayerId ? _self.currentTurnPlayerId : currentTurnPlayerId // ignore: cast_nullable_to_non_nullable
as String?,turnMessages: null == turnMessages ? _self.turnMessages : turnMessages // ignore: cast_nullable_to_non_nullable
as List<TurnMessage>,
  ));
}

}


/// Adds pattern-matching-related methods to [GameRoom].
extension GameRoomPatterns on GameRoom {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameRoom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameRoom() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameRoom value)  $default,){
final _that = this;
switch (_that) {
case _GameRoom():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameRoom value)?  $default,){
final _that = this;
switch (_that) {
case _GameRoom() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String hostId,  RoomStatus status,  GameMode mode,  String? category,  List<Player> players,  String? currentTurnPlayerId,  List<TurnMessage> turnMessages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameRoom() when $default != null:
return $default(_that.id,_that.hostId,_that.status,_that.mode,_that.category,_that.players,_that.currentTurnPlayerId,_that.turnMessages);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String hostId,  RoomStatus status,  GameMode mode,  String? category,  List<Player> players,  String? currentTurnPlayerId,  List<TurnMessage> turnMessages)  $default,) {final _that = this;
switch (_that) {
case _GameRoom():
return $default(_that.id,_that.hostId,_that.status,_that.mode,_that.category,_that.players,_that.currentTurnPlayerId,_that.turnMessages);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String hostId,  RoomStatus status,  GameMode mode,  String? category,  List<Player> players,  String? currentTurnPlayerId,  List<TurnMessage> turnMessages)?  $default,) {final _that = this;
switch (_that) {
case _GameRoom() when $default != null:
return $default(_that.id,_that.hostId,_that.status,_that.mode,_that.category,_that.players,_that.currentTurnPlayerId,_that.turnMessages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameRoom implements GameRoom {
  const _GameRoom({required this.id, required this.hostId, this.status = RoomStatus.waiting, this.mode = GameMode.manual, this.category, final  List<Player> players = const [], this.currentTurnPlayerId, final  List<TurnMessage> turnMessages = const []}): _players = players,_turnMessages = turnMessages;
  factory _GameRoom.fromJson(Map<String, dynamic> json) => _$GameRoomFromJson(json);

@override final  String id;
@override final  String hostId;
@override@JsonKey() final  RoomStatus status;
@override@JsonKey() final  GameMode mode;
@override final  String? category;
 final  List<Player> _players;
@override@JsonKey() List<Player> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

@override final  String? currentTurnPlayerId;
 final  List<TurnMessage> _turnMessages;
@override@JsonKey() List<TurnMessage> get turnMessages {
  if (_turnMessages is EqualUnmodifiableListView) return _turnMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_turnMessages);
}


/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameRoomCopyWith<_GameRoom> get copyWith => __$GameRoomCopyWithImpl<_GameRoom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameRoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._players, _players)&&(identical(other.currentTurnPlayerId, currentTurnPlayerId) || other.currentTurnPlayerId == currentTurnPlayerId)&&const DeepCollectionEquality().equals(other._turnMessages, _turnMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hostId,status,mode,category,const DeepCollectionEquality().hash(_players),currentTurnPlayerId,const DeepCollectionEquality().hash(_turnMessages));

@override
String toString() {
  return 'GameRoom(id: $id, hostId: $hostId, status: $status, mode: $mode, category: $category, players: $players, currentTurnPlayerId: $currentTurnPlayerId, turnMessages: $turnMessages)';
}


}

/// @nodoc
abstract mixin class _$GameRoomCopyWith<$Res> implements $GameRoomCopyWith<$Res> {
  factory _$GameRoomCopyWith(_GameRoom value, $Res Function(_GameRoom) _then) = __$GameRoomCopyWithImpl;
@override @useResult
$Res call({
 String id, String hostId, RoomStatus status, GameMode mode, String? category, List<Player> players, String? currentTurnPlayerId, List<TurnMessage> turnMessages
});




}
/// @nodoc
class __$GameRoomCopyWithImpl<$Res>
    implements _$GameRoomCopyWith<$Res> {
  __$GameRoomCopyWithImpl(this._self, this._then);

  final _GameRoom _self;
  final $Res Function(_GameRoom) _then;

/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hostId = null,Object? status = null,Object? mode = null,Object? category = freezed,Object? players = null,Object? currentTurnPlayerId = freezed,Object? turnMessages = null,}) {
  return _then(_GameRoom(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RoomStatus,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,currentTurnPlayerId: freezed == currentTurnPlayerId ? _self.currentTurnPlayerId : currentTurnPlayerId // ignore: cast_nullable_to_non_nullable
as String?,turnMessages: null == turnMessages ? _self._turnMessages : turnMessages // ignore: cast_nullable_to_non_nullable
as List<TurnMessage>,
  ));
}


}

// dart format on
