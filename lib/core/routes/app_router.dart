import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/room/create_room_screen.dart';
import '../../presentation/room/category_screen.dart';
import '../../presentation/room/lobby_screen.dart';
import '../../presentation/room/manual_prep_screen.dart';
import '../../presentation/game/game_screen.dart';
import '../../presentation/game/result_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create-room',
        builder: (context, state) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryScreen(),
      ),
      GoRoute(
        path: '/lobby/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          return LobbyScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/prep/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          return ManualPrepScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/game/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          return GameScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/result/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          return ResultScreen(roomId: roomId);
        },
      ),
    ],
  );
});
