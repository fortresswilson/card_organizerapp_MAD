import '../db/database_helper.dart';
import '../models/playing_card.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<PlayingCard>> getCardsByFolder(int folderId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'id ASC',
    );

    return result.map((m) => PlayingCard.fromMap(m)).toList();
  }

  Future<void> deleteCard(int cardId) async {
    final db = await _dbHelper.database;
    await db.delete('cards', where: 'id = ?', whereArgs: [cardId]);
  }
  Future<int> insertCard(PlayingCard card) async {
  final db = await _dbHelper.database;
  return db.insert('cards', card.toMap());
}

Future<int> updateCard(PlayingCard card) async {
  final db = await _dbHelper.database;
  return db.update(
    'cards',
    card.toMap(),
    where: 'id = ?',
    whereArgs: [card.id],
  );
}
}
