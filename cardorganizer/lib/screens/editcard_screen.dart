import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/playing_card.dart';
import '../repositories/card_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final Folder folder;
  final PlayingCard? existing; // null = add, not null = edit

  const AddEditCardScreen({
    super.key,
    required this.folder,
    this.existing,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = CardRepository();

  late TextEditingController _nameController;
  late String _selectedSuit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.cardName ?? '');
    _selectedSuit = widget.existing?.suit ?? widget.folder.folderName; // default matches folder
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _imageForSuit(String suit) {
    // You said you're using asset images (jpg). We’ll keep using those paths.
    if (suit.toLowerCase() == 'hearts') return 'assets/cards/hearts.jpg';
    if (suit.toLowerCase() == 'spades') return 'assets/cards/spades.jpg';
    return 'assets/cards/hearts.jpg';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final card = PlayingCard(
      id: widget.existing?.id,
      cardName: _nameController.text.trim(),
      suit: _selectedSuit,
      imageUrl: _imageForSuit(_selectedSuit),
      folderId: widget.folder.id!,
    );

    if (widget.existing == null) {
      await _repo.insertCard(card);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added')),
        );
      }
    } else {
      await _repo.updateCard(card);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card updated')),
        );
      }
    }

    if (mounted) Navigator.pop(context, true); // return "changed"
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Card' : 'Add Card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Card Name (A, 2..10, J, Q, K)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Card name required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSuit,
                decoration: const InputDecoration(
                  labelText: 'Suit',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Hearts', child: Text('Hearts')),
                  DropdownMenuItem(value: 'Spades', child: Text('Spades')),
                ],
                onChanged: (v) => setState(() => _selectedSuit = v ?? _selectedSuit),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(isEdit ? 'Save Changes' : 'Add Card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}