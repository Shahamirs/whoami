import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../domain/models/models.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../../data/data_sources/characters.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final String roomId;
  const LobbyScreen({super.key, required this.roomId});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {

  void _startGame(GameRoom room) async {
    final repo = ref.read(gameRepositoryProvider);
    if (room.mode == GameMode.manual) {
      await repo.startPreparation(room.id);
    } else {
      // Auto assign characters
      final category = room.category ?? 'Movies';
      final chars = List<String>.from(dummyCharacters[category] ?? dummyCharacters['Movies']!);
      chars.shuffle();
      
      for (int i = 0; i < room.players.length; i++) {
        await repo.submitCharacter(room.id, room.players[i].id, chars[i % chars.length]);
      }
      await repo.startGame(room.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<GameRoom?>>(roomProvider(widget.roomId), (previous, next) {
      final room = next.value;
      if (room == null) return;

      if (room.status == RoomStatus.preparing && room.mode == GameMode.manual) {
        context.go('/prep/${widget.roomId}');
      } else if (room.status == RoomStatus.playing) {
        context.go('/game/${widget.roomId}');
      }
    });

    final roomAsync = ref.watch(roomProvider(widget.roomId));
    final currentPlayer = ref.watch(authProvider)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.roomId));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room code copied!')));
            },
            tooltip: 'Copy Room Code',
          ),
        ],
      ),
      body: roomAsync.when(
        data: (room) {
          if (room == null) return const Center(child: Text('Room not found'));
          
          final isHost = room.hostId == currentPlayer.id;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text('Room Code', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          room.id,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Players (${room.players.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      if (!isHost) const CircularProgressIndicator.adaptive(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: room.players.length,
                      itemBuilder: (context, index) {
                        final player = room.players[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: player.id == currentPlayer.id 
                                ? Theme.of(context).colorScheme.primary 
                                : Theme.of(context).colorScheme.surface,
                            child: Text(player.name[0]),
                          ),
                          title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: player.isHost ? const Icon(Icons.star, color: Colors.amber) : null,
                        );
                      },
                    ),
                  ),
                  
                  if (isHost)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: room.players.length > 1 ? () => _startGame(room) : null,
                        child: Text(
                          room.players.length > 1 ? 'Start Game' : 'Waiting for players...', 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (!isHost)
                     const Text('Waiting for the host to start the game...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
