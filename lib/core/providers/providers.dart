import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/game_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/repositories/mock_game_repository.dart';
import '../../domain/models/models.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return MockAuthRepository();
});

final gameRepositoryProvider = Provider<IGameRepository>((ref) {
  return MockGameRepository();
});

class AuthNotifier extends Notifier<Player?> {
  @override
  Player? build() => null;

  void setPlayer(Player player) {
    state = player;
  }
  
  void logout() {
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, Player?>(() {
  return AuthNotifier();
});

final roomProvider = StreamProvider.family<GameRoom?, String>((ref, roomId) {
  final repo = ref.watch(gameRepositoryProvider);
  return repo.watchRoom(roomId);
});

