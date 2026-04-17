import '../models/models.dart';

abstract class IAuthRepository {
  Future<Player> login(String nickname);
  Future<Player?> getCurrentPlayer();
  Future<void> logout();
}
