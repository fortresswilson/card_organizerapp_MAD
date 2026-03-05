import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _repo = FolderRepository();
  late Future<List<Folder>> _foldersFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _foldersFuture = _repo.getFolders();
  }

  IconData _iconForFolder(String name) {
    switch (name.toLowerCase()) {
      case 'hearts':
        return Icons.favorite;
      case 'spades':
        return Icons.change_history; // simple placeholder icon
      default:
        return Icons.folder;
    }
  }

  Future<void> _confirmDeleteFolder(Folder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text(
          'This will delete "${folder.folderName}" and ALL cards inside it.\n\n'
          'Because of cascade delete, the cards will be removed automatically.',
        ),
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

    if (confirmed == true && folder.id != null) {
      await _repo.deleteFolder(folder.id!);
      setState(() => _reload());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suit Folders')),
      body: FutureBuilder<List<Folder>>(
        future: _foldersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final folders = snapshot.data ?? [];
          if (folders.isEmpty) {
            return const Center(child: Text('No folders found.'));
          }

          return ListView.separated(
            itemCount: folders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final folder = folders[index];

              return FutureBuilder<int>(
                future: folder.id == null ? Future.value(0) : _repo.getCardCount(folder.id!),
                builder: (context, countSnapshot) {
                  final count = countSnapshot.data ?? 0;

                  return ListTile(
                    leading: Icon(_iconForFolder(folder.folderName)),
                    title: Text(folder.folderName),
                    subtitle: Text('$count cards'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteFolder(folder),
                    ),
                    onTap: () {
                      if (folder.id == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CardsScreen(folder: folder),
                        ),
                      ).then((_) {
                        // refresh counts when returning
                        setState(() => _reload());
                      });
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}