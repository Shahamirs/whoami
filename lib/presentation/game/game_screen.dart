import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/providers.dart';
import '../../domain/models/models.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String roomId;
  const GameScreen({super.key, required this.roomId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final _questionController = TextEditingController();
  final _guessController = TextEditingController();

  void _askQuestion(GameRoom room, String myId) async {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;

    final repo = ref.read(gameRepositoryProvider);
    final msg = TurnMessage(
      id: const Uuid().v4(),
      playerId: myId,
      text: text,
      isQuestion: true,
    );
    await repo.sendTurnMessage(room.id, msg);
    _questionController.clear();
  }

  void _answerQuestion(GameRoom room, TurnMessage msg, bool yes) async {
    final repo = ref.read(gameRepositoryProvider);
    final updatedMsg = msg.copyWith(answerWasYes: yes);
    
    // Replace msg in list
    // In our mock, we just add an answer message, or update. Actually, sendTurnMessage just appends. 
    // Let's add an answer append.
    final ansMsg = TurnMessage(
      id: const Uuid().v4(),
      playerId: ref.read(authProvider)!.id,
      text: yes ? 'Yes!' : 'No!',
      isQuestion: false,
    );
    await repo.sendTurnMessage(room.id, ansMsg);
    
    if (!yes) {
      // Next turn
      final currentIndex = room.players.indexWhere((p) => p.id == room.currentTurnPlayerId);
      int nextIndex = (currentIndex + 1) % room.players.length;
      
      // Skip players who already guessed their character
      while (room.players[nextIndex].isGuessed) {
        nextIndex = (nextIndex + 1) % room.players.length;
        if (nextIndex == currentIndex) break; // Everyone guessed
      }
      
      await repo.nextTurn(room.id, room.players[nextIndex].id);
    }
  }

  void _guessCharacter(GameRoom room, Player myPlayer) async {
    final guess = _guessController.text.trim();
    if (guess.isEmpty) return;
    _guessController.clear();
    Navigator.of(context).pop(); // close dialog

    final actChar = myPlayer.characterName?.toLowerCase() ?? '';
    final isCorrect = guess.toLowerCase() == actChar;
    
    final repo = ref.read(gameRepositoryProvider);
    final ansMsg = TurnMessage(
      id: const Uuid().v4(),
      playerId: myPlayer.id,
      text: 'Guessed: $guess - ${isCorrect ? "CORRECT!" : "WRONG!"}',
      isQuestion: false,
    );
    await repo.sendTurnMessage(room.id, ansMsg);

    if (isCorrect) {
      await repo.guessCharacter(room.id, myPlayer.id, true);
    }
    
    // Always pass turn after a guess
    final currentIndex = room.players.indexWhere((p) => p.id == room.currentTurnPlayerId);
    int nextIndex = (currentIndex + 1) % room.players.length;
    while (room.players[nextIndex].isGuessed && nextIndex != currentIndex) {
      nextIndex = (nextIndex + 1) % room.players.length;
    }
    await repo.nextTurn(room.id, room.players[nextIndex].id);
  }

  void _showGuessDialog(GameRoom room, Player myPlayer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guess your character'),
        content: TextField(
          controller: _guessController,
          decoration: const InputDecoration(hintText: 'Enter character name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => _guessCharacter(room, myPlayer), child: const Text('Guess')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<GameRoom?>>(roomProvider(widget.roomId), (previous, next) {
      final room = next.value;
      if (room != null && room.status == RoomStatus.finished) {
        context.go('/result/${widget.roomId}');
      }
    });

    final roomAsync = ref.watch(roomProvider(widget.roomId));
    final currentPlayer = ref.watch(authProvider)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: roomAsync.when(
        data: (room) {
          if (room == null) return const Center(child: Text('Room not found'));
          
          final me = room.players.firstWhere((p) => p.id == currentPlayer.id);
          final isMyTurn = room.currentTurnPlayerId == me.id;
          final turnPlayer = room.players.firstWhere((p) => p.id == room.currentTurnPlayerId, orElse: () => room.players.first);

          // Check if the last message is an unanswered question
          bool isPendingQuestion = false;
          TurnMessage? lastQuestion;
          if (room.turnMessages.isNotEmpty) {
            final lastMsg = room.turnMessages.last;
            if (lastMsg.isQuestion) {
              isPendingQuestion = true;
              lastQuestion = lastMsg;
            }
          }

          return SafeArea(
            child: Column(
              children: [
                // Turn Indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: isMyTurn ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Text(
                        isMyTurn ? "It's your turn!" : "It's ${turnPlayer.name}'s turn",
                        style: TextStyle(
                           fontSize: 24, 
                           fontWeight: FontWeight.bold,
                           color: isMyTurn ? Theme.of(context).colorScheme.primary : Colors.white,
                        ),
                      ),
                      if (me.isGuessed) 
                        const Padding(
                           padding: EdgeInsets.only(top: 8.0),
                           child: Text("You already guessed your character!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        )
                    ],
                  ),
                ),
                
                // Players List (Horizontal)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: room.players.length,
                    itemBuilder: (context, index) {
                      final p = room.players[index];
                      // Don't reveal my own character to me, unless I guessed it
                      final isMe = p.id == me.id;
                      final showChar = !isMe || p.isGuessed;
                      final charName = showChar ? (p.characterName ?? '?') : '???';

                      return Container(
                        width: 120,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: p.id == room.currentTurnPlayerId ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: p.id == room.currentTurnPlayerId ? Theme.of(context).colorScheme.primary : Colors.grey.shade800),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: p.isGuessed ? Colors.green : Colors.grey.shade800,
                              child: p.isGuessed ? const Icon(Icons.check, color: Colors.white) : Text(p.name[0]),
                            ),
                            const SizedBox(height: 8),
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                            Text(charName, style: TextStyle(color: Colors.grey.shade400, fontSize: 12), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),

                // Chat / Questions History
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: room.turnMessages.length,
                    itemBuilder: (context, index) {
                      final msg = room.turnMessages[index];
                      final p = room.players.firstWhere((p) => p.id == msg.playerId, orElse: () => room.players.first);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${p.name}: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            Expanded(child: Text(msg.text, style: TextStyle(color: msg.isQuestion ? Colors.white : Theme.of(context).colorScheme.secondary))),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Action Area
                if (!me.isGuessed) 
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.surface,
                       border: Border(top: BorderSide(color: Colors.grey.shade800)),
                    ),
                    child: Column(
                      children: [
                        if (isMyTurn && !isPendingQuestion) ...[
                           Row(
                             children: [
                               Expanded(
                                 child: TextField(
                                   controller: _questionController,
                                   decoration: const InputDecoration(hintText: 'Ask a yes/no question...'),
                                   onSubmitted: (_) => _askQuestion(room, me.id),
                                 ),
                               ),
                               const SizedBox(width: 8),
                               IconButton(
                                 icon: const Icon(Icons.send),
                                 color: Theme.of(context).colorScheme.primary,
                                 onPressed: () => _askQuestion(room, me.id),
                               ),
                             ],
                           ),
                           const SizedBox(height: 16),
                           SizedBox(
                             width: double.infinity,
                             child: OutlinedButton(
                               onPressed: () => _showGuessDialog(room, me),
                               child: const Text('Guess Character'),
                             ),
                           ),
                        ] else if (isPendingQuestion && !isMyTurn) ...[
                           Text('${turnPlayer.name} asks: "${lastQuestion!.text}"'),
                           const SizedBox(height: 16),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                             children: [
                               ElevatedButton(
                                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                 onPressed: () => _answerQuestion(room, lastQuestion!, true),
                                 child: const Text('YES'),
                               ),
                               ElevatedButton(
                                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                 onPressed: () => _answerQuestion(room, lastQuestion!, false),
                                 child: const Text('NO'),
                               ),
                             ],
                           ),
                        ] else if (isMyTurn && isPendingQuestion) ...[
                           const Text('Waiting for an answer...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                        ]
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
