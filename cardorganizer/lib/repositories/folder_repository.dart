import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/folder.dart';

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Folder>> getFolders() async {
    final db = await _dbHelper.database;

    final result = await db.query('folders');

    return result.map((map) => Folder.fromMap(map)).toList();
  }

  Future<int> getCardCount(int folderId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE folder_id = ?',
      [folderId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteFolder(int folderId) async {
    final db = await _dbHelper.database;

    await db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [folderId],
    );
  }
}