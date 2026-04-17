import 'dart:ui';
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

class _GameScreenState extends ConsumerState<GameScreen> with SingleTickerProviderStateMixin {
  final _questionController = TextEditingController();
  final _guessController = TextEditingController();
  
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _guessController.dispose();
    _animController.dispose();
    super.dispose();
  }

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
    
    final ansMsg = TurnMessage(
      id: const Uuid().v4(),
      playerId: ref.read(authProvider)!.id,
      text: yes ? 'Yes!' : 'No!',
      isQuestion: false,
    );
    await repo.sendTurnMessage(room.id, ansMsg);
    
    if (!yes) {
      final currentIndex = room.players.indexWhere((p) => p.id == room.currentTurnPlayerId);
      int nextIndex = (currentIndex + 1) % room.players.length;
      
      while (room.players[nextIndex].isGuessed) {
        nextIndex = (nextIndex + 1) % room.players.length;
        if (nextIndex == currentIndex) break;
      }
      
      await repo.nextTurn(room.id, room.players[nextIndex].id);
    }
  }

  void _guessCharacter(GameRoom room, Player myPlayer) async {
    final guess = _guessController.text.trim();
    if (guess.isEmpty) return;
    _guessController.clear();
    Navigator.of(context).pop();

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
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Guess your character', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _guessController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter character name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.cyan), borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.cyanAccent), borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
             style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
             onPressed: () => _guessCharacter(room, myPlayer), 
             child: const Text('Guess', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<GameRoom?>>(roomProvider(widget.roomId), (previous, next) {
      final room = next.value;
      if (room != null && room.status == RoomStatus.finished) {
         if (context.mounted && GoRouterState.of(context).matchedLocation != '/result/${widget.roomId}') {
             context.go('/result/${widget.roomId}');
         }
      }
    });

    final roomAsync = ref.watch(roomProvider(widget.roomId));
    final currentPlayer = ref.watch(authProvider)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Who Am I', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: roomAsync.when(
        data: (room) {
          if (room == null) return const Center(child: Text('Room not found', style: TextStyle(color: Colors.white)));
          
          final me = room.players.firstWhere((p) => p.id == currentPlayer.id, orElse: () => room.players.first);
          final isMyTurn = room.currentTurnPlayerId == me.id;
          final turnPlayer = room.players.firstWhere((p) => p.id == room.currentTurnPlayerId, orElse: () => room.players.first);

          bool isPendingQuestion = false;
          TurnMessage? lastQuestion;
          if (room.turnMessages.isNotEmpty) {
            final lastMsg = room.turnMessages.last;
            if (lastMsg.isQuestion) {
              isPendingQuestion = true;
              lastQuestion = lastMsg;
            }
          }

          return Stack(
            children: [
              // Dynamic Background
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                       colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
                    )
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                   return Positioned(
                      top: -100 + (50 * _animController.value),
                      left: -50,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           color: isMyTurn ? Colors.cyan.withOpacity(0.15) : Colors.purpleAccent.withOpacity(0.1),
                           boxShadow: [
                             BoxShadow(color: isMyTurn ? Colors.cyan.withOpacity(0.3) : Colors.purpleAccent.withOpacity(0.2), blurRadius: 100, spreadRadius: 50)
                           ]
                        ),
                      )
                   );
                }
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Turn Indicator (Glassmorphism)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(isMyTurn ? 0.6 : 0.2), width: isMyTurn ? 2 : 1),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1), 
                            Colors.white.withOpacity(0.05)
                          ]
                        ),
                        boxShadow: isMyTurn ? [const BoxShadow(color: Colors.cyanAccent, blurRadius: 20, spreadRadius: -5)] : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  isMyTurn ? "IT'S YOUR TURN" : "WAITING FOR ${turnPlayer.name.toUpperCase()}",
                                  style: TextStyle(
                                     fontSize: 18, 
                                     fontWeight: FontWeight.w900,
                                     letterSpacing: 2,
                                     color: isMyTurn ? Colors.cyanAccent : Colors.white70,
                                  ),
                                ),
                                if (me.isGuessed) 
                                  const Padding(
                                     padding: EdgeInsets.only(top: 8.0),
                                     child: Text("You already guessed your character!", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Players List
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: room.players.length,
                        itemBuilder: (context, index) {
                          final p = room.players[index];
                          final isMe = p.id == me.id;
                          final showChar = !isMe || p.isGuessed;
                          final charName = showChar ? (p.characterName ?? '?') : '???';
                          final isTheirTurn = p.id == room.currentTurnPlayerId;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 110,
                            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                 color: isTheirTurn ? Colors.cyanAccent : (p.isGuessed ? Colors.greenAccent : Colors.white.withOpacity(0.1)),
                                 width: isTheirTurn ? 2 : 1
                              ),
                              boxShadow: isTheirTurn ? [const BoxShadow(color: Colors.cyan, blurRadius: 15, spreadRadius: -5)] : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: p.isGuessed ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                                            child: p.isGuessed 
                                               ? const Icon(Icons.check, color: Colors.greenAccent) 
                                               : Text(p.name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                          ),
                                          if (isTheirTurn) 
                                             const SizedBox(
                                                width: 52, height: 52, 
                                                child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2)
                                             ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white), overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text(charName, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis, maxLines: 1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Chat History
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: room.turnMessages.length,
                            itemBuilder: (context, index) {
                              final msg = room.turnMessages[index];
                              final p = room.players.firstWhere((p) => p.id == msg.playerId, orElse: () => room.players.first);
                              final isSelf = p.id == me.id;
                              
                              if (!msg.isQuestion) {
                                // Answer message
                                final isYes = msg.text.toLowerCase().contains('yes');
                                final isCorrect = msg.text.toLowerCase().contains('correct');
                                final isWrong = msg.text.toLowerCase().contains('wrong');
                                
                                Color tagColor = Colors.grey;
                                if (isYes || isCorrect) tagColor = Colors.greenAccent;
                                else if (isWrong || msg.text.toLowerCase().contains('no')) tagColor = Colors.redAccent;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: tagColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: tagColor.withOpacity(0.5)),
                                      ),
                                      child: Text(
                                         "${p.name} -> ${msg.text}", 
                                         style: TextStyle(color: tagColor, fontWeight: FontWeight.bold, fontSize: 12)
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!isSelf) ...[
                                      CircleAvatar(radius: 14, backgroundColor: Colors.white24, child: Text(p.name[0], style: const TextStyle(fontSize: 12, color: Colors.white))),
                                      const SizedBox(width: 8),
                                    ],
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelf ? Colors.cyan.withOpacity(0.8) : Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(20),
                                            topRight: const Radius.circular(20),
                                            bottomLeft: Radius.circular(isSelf ? 20 : 4),
                                            bottomRight: Radius.circular(isSelf ? 4 : 20),
                                          ),
                                        ),
                                        child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Action Area
                    if (!me.isGuessed) 
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                           color: Colors.black.withOpacity(0.4),
                           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -5))]
                        ),
                        child: SafeArea(
                          top: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isMyTurn && !isPendingQuestion) ...[
                                 Row(
                                   children: [
                                     Expanded(
                                       child: TextField(
                                         controller: _questionController,
                                         style: const TextStyle(color: Colors.white),
                                         decoration: InputDecoration(
                                           hintText: 'Ask a yes/no question...',
                                           hintStyle: TextStyle(color: Colors.white54),
                                           filled: true,
                                           fillColor: Colors.white.withOpacity(0.05),
                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                           contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                         ),
                                         onSubmitted: (_) => _askQuestion(room, me.id),
                                       ),
                                     ),
                                     const SizedBox(width: 12),
                                     Container(
                                       decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.cyan),
                                       child: IconButton(
                                         icon: const Icon(Icons.send_rounded),
                                         color: Colors.black,
                                         onPressed: () => _askQuestion(room, me.id),
                                       ),
                                     ),
                                   ],
                                 ),
                                 const SizedBox(height: 16),
                                 OutlinedButton.icon(
                                   icon: const Icon(Icons.psychology_alt, color: Colors.cyanAccent),
                                   label: const Text('GUESS MY CHARACTER', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                                   style: OutlinedButton.styleFrom(
                                     padding: const EdgeInsets.symmetric(vertical: 16),
                                     side: const BorderSide(color: Colors.cyanAccent),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                   ),
                                   onPressed: () => _showGuessDialog(room, me),
                                 ),
                              ] else if (isPendingQuestion && !isMyTurn) ...[
                                 Text('Can you answer ${turnPlayer.name}\'s question?', style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 14), textAlign: TextAlign.center),
                                 const SizedBox(height: 16),
                                 Row(
                                   children: [
                                     Expanded(
                                       child: ElevatedButton(
                                         style: ElevatedButton.styleFrom(
                                           backgroundColor: Colors.greenAccent.withOpacity(0.2),
                                           foregroundColor: Colors.greenAccent,
                                           side: const BorderSide(color: Colors.greenAccent),
                                           padding: const EdgeInsets.symmetric(vertical: 16),
                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                                         ),
                                         onPressed: () => _answerQuestion(room, lastQuestion!, true),
                                         child: const Text('YES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
                                       ),
                                     ),
                                     const SizedBox(width: 16),
                                     Expanded(
                                       child: ElevatedButton(
                                         style: ElevatedButton.styleFrom(
                                           backgroundColor: Colors.redAccent.withOpacity(0.2),
                                           foregroundColor: Colors.redAccent,
                                           side: const BorderSide(color: Colors.redAccent),
                                           padding: const EdgeInsets.symmetric(vertical: 16),
                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                                         ),
                                         onPressed: () => _answerQuestion(room, lastQuestion!, false),
                                         child: const Text('NO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
                                       ),
                                     ),
                                   ],
                                 ),
                              ] else if (isMyTurn && isPendingQuestion) ...[
                                 const Center(
                                   child: Padding(
                                     padding: EdgeInsets.all(16.0),
                                     child: Text('Waiting for an answer...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white54, fontSize: 16, letterSpacing: 1.2)),
                                   ),
                                 ),
                              ] else ...[
                                 const Center(
                                   child: Padding(
                                     padding: EdgeInsets.all(16.0),
                                     child: Text('Watch the conversation above...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white54, fontSize: 14)),
                                   ),
                                 ),
                              ]
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }
}
