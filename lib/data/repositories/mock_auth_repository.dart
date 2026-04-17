import 'package:uuid/uuid.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements IAuthRepository {
  Player? _currentPlayer;
  final _uuid = const Uuid();

  @override
  Future<Player> login(String nickname) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentPlayer = Player(id: _uuid.v4(), name: nickname);
    return _currentPlayer!;
  }

  @override
  Future<Player?> getCurrentPlayer() async {
    return _currentPlayer;
  }

  @override
  Future<void> logout() async {
    _currentPlayer = null;
  }
}
