import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../domain/models/models.dart';

class ManualPrepScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ManualPrepScreen({super.key, required this.roomId});

  @override
  ConsumerState<ManualPrepScreen> createState() => _ManualPrepScreenState();
}

class _ManualPrepScreenState extends ConsumerState<ManualPrepScreen> {
  final _characterController = TextEditingController();
  bool _submitted = false;

  void _submitCharacter(GameRoom room, Player targetPlayer, String meId) async {
    final charName = _characterController.text.trim();
    if (charName.isEmpty) return;

    setState(() => _submitted = true);
    final repo = ref.read(gameRepositoryProvider);
    await repo.submitCharacter(room.id, targetPlayer.id, charName);
    
    // If I'm the host, check if all submitted, if yes, start. But wait, any player can submit.
    // The host should have a button to start, or auto-start when all submitted.
    // In our mock, characters are filled in Player.characterName.
    // Let's do host-only manual start or auto-start. We'll show a "Waiting for others" text.
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<GameRoom?>>(roomProvider(widget.roomId), (previous, next) {
      final room = next.value;
      if (room != null && room.status == RoomStatus.playing) {
        context.go('/game/${widget.roomId}');
      }
    });

    final roomAsync = ref.watch(roomProvider(widget.roomId));
    final currentPlayer = ref.watch(authProvider)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Preparation')),
      body: roomAsync.when(
        data: (room) {
          if (room == null) return const Center(child: Text('Room not found'));

          final myIndex = room.players.indexWhere((p) => p.id == currentPlayer.id);
          if (myIndex == -1) return const Center(child: Text('You are not in this room!'));

          final targetPlayer = room.players[(myIndex + 1) % room.players.length];
          final isHost = room.hostId == currentPlayer.id;
          
          final allSubmitted = room.players.every((p) => p.characterName != null && p.characterName!.isNotEmpty);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology, size: 80, color: Colors.grey),
                  const SizedBox(height: 32),
                  if (!_submitted) ...[
                    Text(
                      'Who should ${targetPlayer.name} be?',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _characterController,
                      decoration: InputDecoration(
                        hintText: "Enter a character name...",
                        helperText: "E.g. Spider-Man, Albert Einstein",
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _submitCharacter(room, targetPlayer, currentPlayer.id),
                        child: const Text('Submit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Character submitted!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Waiting for other players...',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    if (isHost)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: allSubmitted 
                            ? () => ref.read(gameRepositoryProvider).startGame(room.id) 
                            : null,
                          child: Text(
                            allSubmitted ? 'Start Game' : 'Waiting for ${room.players.where((p) => p.characterName == null).length} more',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                  ],
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
