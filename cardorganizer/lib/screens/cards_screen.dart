import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/playing_card.dart';
import '../repositories/card_repository.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;

  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _repo = CardRepository();
  late Future<List<PlayingCard>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _cardsFuture = _repo.getCardsByFolder(widget.folder.id!);
  }

  Future<void> _confirmDeleteCard(PlayingCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card?'),
        content: Text('Delete ${card.cardName} of ${card.suit}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && card.id != null) {
      await _repo.deleteCard(card.id!);
      setState(() => _reload());
    }
  }

  Widget _cardImage(String assetPath) {
    return Image.asset(
      assetPath,
      width: 46,
      height: 46,
      fit: BoxFit.contain,
      
      errorBuilder: (context, error, stack) {
        return const Icon(Icons.image_not_supported, size: 46);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final folderName = widget.folder.folderName;

    return Scaffold(
      appBar: AppBar(title: Text('$folderName Cards')),
      body: FutureBuilder<List<PlayingCard>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cards = snapshot.data ?? [];
          if (cards.isEmpty) {
            return const Center(child: Text('No cards found.'));
          }

          return ListView.separated(
            itemCount: cards.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final card = cards[index];

              return ListTile(
                leading: _cardImage(card.imageUrl), // hearts.jpg / spades.jpg
                title: Text('${card.cardName} of ${card.suit}'),
                subtitle:  Text(card.imageUrl),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDeleteCard(card),
                ),
              );
            },
          );
        },
      ),
    );
  }
}