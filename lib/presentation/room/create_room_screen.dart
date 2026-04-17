import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../domain/models/models.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  GameMode _selectedMode = GameMode.manual;
  bool _isLoading = false;

  void _createRoom() async {
    if (_selectedMode == GameMode.auto) {
      // Go to category selection first
      context.push('/categories');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(gameRepositoryProvider);
      final player = ref.read(authProvider)!;
      final roomId = await repo.createRoom(player.id, _selectedMode);
      await repo.joinRoom(roomId, player);
      
      if (mounted) {
        context.go('/lobby/$roomId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Game Room')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Game Mode',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              _ModeCard(
                title: 'Manual Mode',
                description: 'Players write characters for each other.',
                icon: Icons.edit_note,
                isSelected: _selectedMode == GameMode.manual,
                onTap: () => setState(() => _selectedMode = GameMode.manual),
              ),
              const SizedBox(height: 16),
              
              _ModeCard(
                title: 'Auto Mode',
                description: 'Characters are randomly assigned from a category.',
                icon: Icons.auto_awesome,
                isSelected: _selectedMode == GameMode.auto,
                onTap: () => setState(() => _selectedMode = GameMode.auto),
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createRoom,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_selectedMode == GameMode.auto ? 'Next: Choose Category' : 'Create Room', 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(color: Colors.grey, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
